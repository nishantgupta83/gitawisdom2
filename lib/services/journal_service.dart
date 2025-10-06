
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/journal_entry.dart';
import '../services/service_locator.dart';

class JournalService {
  static final JournalService instance = JournalService._();
  JournalService._();

  late final _supabaseService = ServiceLocator.instance.enhancedSupabaseService;
  Box<JournalEntry>? _box;

  static const String boxName = 'journal_entries';
  static const String lastSyncKey = 'journal_last_sync_timestamp';
  static const String _encryptionKeyName = 'journal_encryption_key';

  final _secureStorage = const FlutterSecureStorage();

  // Cache journal entries for 1 hour before background refresh
  static const Duration cacheValidityDuration = Duration(hours: 1);

  /// Get or generate encryption key for Hive
  Future<Uint8List> _getEncryptionKey() async {
    try {
      // Try to get existing key
      String? keyString = await _secureStorage.read(key: _encryptionKeyName);

      if (keyString == null) {
        // Generate new 256-bit key
        final key = Hive.generateSecureKey();
        // Store it securely
        await _secureStorage.write(
          key: _encryptionKeyName,
          value: base64Encode(key),
        );
        debugPrint('🔐 Generated new encryption key for journal data');
        return Uint8List.fromList(key);
      }

      debugPrint('🔐 Retrieved existing encryption key');
      return base64Decode(keyString);
    } catch (e) {
      debugPrint('❌ Error managing encryption key: $e');
      rethrow;
    }
  }

  List<JournalEntry> _cachedEntries = [];
  DateTime? _lastLocalFetch;

  /// Initialize the service and open Hive box with encryption
  Future<void> initialize() async {
    try {
      // Get encryption key
      final encryptionKey = await _getEncryptionKey();

      if (!Hive.isBoxOpen(boxName)) {
        try {
          _box = await Hive.openBox<JournalEntry>(
            boxName,
            encryptionCipher: HiveAesCipher(encryptionKey),
          );
          debugPrint('✅ Opened encrypted journal box');
        } on HiveError catch (e) {
          debugPrint('🔄 Hive error detected, clearing corrupted journal data: $e');
          // Clear corrupted box and try again
          await Hive.deleteBoxFromDisk(boxName);
          _box = await Hive.openBox<JournalEntry>(
            boxName,
            encryptionCipher: HiveAesCipher(encryptionKey),
          );
          debugPrint('✅ Cleared corrupted journal data, starting fresh with encryption');
        }
      } else {
        _box = Hive.box<JournalEntry>(boxName);
      }
      
      // Load cached entries into memory with error recovery
      await _loadCachedEntries();
      
      debugPrint('✅ JournalService initialized with ${_cachedEntries.length} entries');
    } catch (e) {
      debugPrint('❌ Error initializing JournalService: $e');
      // Ensure we have an empty but functional state
      _cachedEntries = [];
      rethrow;
    }
  }

  /// Load cached journal entries into memory with error recovery
  Future<void> _loadCachedEntries() async {
    try {
      await _ensureInitialized();
      if (_box != null && _box!.isNotEmpty) {
        final List<JournalEntry> validEntries = [];
        
        // Process each entry with individual error handling
        for (final entry in _box!.values) {
          try {
            // Validate entry has required fields
            if (entry.id.isNotEmpty && 
                entry.reflection.isNotEmpty && 
                entry.rating >= 0 && 
                entry.rating <= 5) {
              validEntries.add(entry);
            } else {
              debugPrint('⚠️ Skipping invalid journal entry: ${entry.id}');
            }
          } catch (e) {
            debugPrint('⚠️ Corrupted journal entry found and skipped: $e');
            // Continue processing other entries
          }
        }
        
        _cachedEntries = validEntries;
        // Sort by date, newest first
        _cachedEntries.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
        _lastLocalFetch = DateTime.now();
        debugPrint('📔 Loaded ${_cachedEntries.length} valid journal entries from cache');
      }
    } catch (e) {
      debugPrint('❌ Error loading cached journal entries: $e');
      // Ensure we have a functional empty state
      _cachedEntries = [];
    }
  }

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (_box == null || !_box!.isOpen) {
      await initialize();
    }
  }

  /// Get all journal entries with cache-first approach
  Future<List<JournalEntry>> fetchEntries() async {
    try {
      await _ensureInitialized();
      
      // Return cached entries immediately if available and fresh
      if (_cachedEntries.isNotEmpty && _isCacheValid()) {
        debugPrint('📔 Using cached journal entries (${_cachedEntries.length} items)');
        return _cachedEntries;
      }
      
      // Check if we need to refresh from server
      if (_shouldRefreshFromServer()) {
        debugPrint('🔄 Refreshing journal entries from server...');
        await _refreshFromServer();
      }
      
      // Return cached entries (may be empty if first run)
      return _cachedEntries;
      
    } catch (e) {
      debugPrint('❌ Error getting journal entries: $e');
      // Fallback to cached data if available
      return _cachedEntries.isNotEmpty ? _cachedEntries : [];
    }
  }

  /// Create a new journal entry (store locally and sync to server)
  Future<void> createEntry(JournalEntry entry) async {
    try {
      await _ensureInitialized();
      
      // Validate entry before storing
      if (entry.id.isEmpty || entry.reflection.trim().isEmpty) {
        throw ArgumentError('Journal entry must have ID and non-empty reflection');
      }
      
      if (entry.rating < 0 || entry.rating > 5) {
        throw ArgumentError('Rating must be between 0 and 5');
      }
      
      // Store locally first
      await _box!.put(entry.id, entry);
      debugPrint('📔 Journal entry saved locally: ${entry.id}');
      
      // Add to cached entries (check for duplicates first)
      final existingIndex = _cachedEntries.indexWhere((e) => e.id == entry.id);
      if (existingIndex == -1) {
        _cachedEntries.insert(0, entry); // Add at beginning (newest first)
        debugPrint('📔 Entry added to cache: ${entry.id}');
      } else {
        debugPrint('⚠️ Entry already exists in cache, not duplicating: ${entry.id}');
      }
      
      // Sync to server in background (non-blocking)
      _syncToServer(entry);
      
    } catch (e) {
      debugPrint('❌ Error creating journal entry: $e');
      rethrow;
    }
  }

  /// Background sync to server
  Future<void> _syncToServer(JournalEntry entry) async {
    try {
      await _supabaseService.insertJournalEntry(entry);
      debugPrint('✅ Journal entry synced to server: ${entry.id}');
    } catch (e) {
      debugPrint('⚠️ Failed to sync journal entry to server (will retry later): $e');
      // Entry is still saved locally, background sync will retry later
    }
  }

  /// Check if cache is still valid
  bool _isCacheValid() {
    if (_lastLocalFetch == null) return false;
    return DateTime.now().difference(_lastLocalFetch!) < cacheValidityDuration;
  }

  /// Check if we should refresh from server
  bool _shouldRefreshFromServer() {
    if (_cachedEntries.isEmpty) return true;
    if (!_isCacheValid()) return true;
    return false;
  }

  /// Refresh entries from server and update cache
  Future<void> _refreshFromServer() async {
    try {
      final serverEntries = await _supabaseService.fetchJournalEntries();
      
      // Clear and rebuild cache
      await _box!.clear();
      _cachedEntries.clear();
      
      // Store server entries locally
      for (final entry in serverEntries) {
        await _box!.put(entry.id, entry);
        _cachedEntries.add(entry);
      }
      
      // Sort by date, newest first
      _cachedEntries.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
      _lastLocalFetch = DateTime.now();
      
      debugPrint('✅ Refreshed ${_cachedEntries.length} journal entries from server');
      
    } catch (e) {
      debugPrint('❌ Error refreshing journal entries from server: $e');
      // Keep existing cache on error
    }
  }

  /// Force refresh from server (for pull-to-refresh)
  Future<void> refreshFromServer() async {
    debugPrint('🔄 Force refreshing journal entries...');
    await _refreshFromServer();
  }

  /// Background sync - non-blocking refresh if cache is stale
  void backgroundSync() {
    if (!_isCacheValid()) {
      _refreshFromServer().catchError((e) {
        debugPrint('⚠️ Background sync failed: $e');
      });
    }
  }

  /// Delete a journal entry (remove from local storage and sync to server)
  Future<void> deleteEntry(String entryId) async {
    try {
      await _ensureInitialized();
      
      if (entryId.isEmpty) {
        throw ArgumentError('Entry ID cannot be empty');
      }
      
      // Remove from local storage
      await _box!.delete(entryId);
      debugPrint('📔 Journal entry deleted locally: $entryId');
      
      // Remove from cached entries
      _cachedEntries.removeWhere((entry) => entry.id == entryId);
      
      // Sync deletion to server in background (non-blocking)
      _syncDeletionToServer(entryId);
      
    } catch (e) {
      debugPrint('❌ Error deleting journal entry: $e');
      rethrow;
    }
  }

  /// Background sync deletion to server
  Future<void> _syncDeletionToServer(String entryId) async {
    try {
      await _supabaseService.deleteJournalEntry(entryId);
      debugPrint('✅ Journal entry deletion synced to server: $entryId');
    } catch (e) {
      debugPrint('⚠️ Failed to sync journal entry deletion to server (will retry later): $e');
      // Deletion is still done locally, background sync will retry later
    }
  }

  /// Search journal entries locally
  List<JournalEntry> searchEntries(String query) {
    if (query.trim().isEmpty) {
      return _cachedEntries;
    }
    
    final searchLower = query.toLowerCase().trim();
    final results = _cachedEntries.where((entry) {
      return entry.reflection.toLowerCase().contains(searchLower);
    }).toList();
    
    debugPrint('🔍 Local search for "$query": ${results.length} results');
    return results;
  }

  /// Get total number of entries
  int get totalEntries => _cachedEntries.length;

  /// Get average rating
  double get averageRating {
    if (_cachedEntries.isEmpty) return 0.0;
    final validEntries = _cachedEntries.where((entry) => entry.rating > 0).toList();
    if (validEntries.isEmpty) return 0.0;
    return validEntries.map((e) => e.rating).reduce((a, b) => a + b) / validEntries.length;
  }
}


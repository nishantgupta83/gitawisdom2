
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
      String? keyString = await _secureStorage.read(key: _encryptionKeyName);
      if (keyString == null) {
        final key = Hive.generateSecureKey();
        await _secureStorage.write(key: _encryptionKeyName, value: base64Encode(key));
        return Uint8List.fromList(key);
      }
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
      final encryptionKey = await _getEncryptionKey();

      if (!Hive.isBoxOpen(boxName)) {
        try {
          _box = await Hive.openBox<JournalEntry>(
            boxName,
            encryptionCipher: HiveAesCipher(encryptionKey),
          );
        } on HiveError catch (e) {
          debugPrint('🔄 Hive error detected, clearing corrupted journal data: $e');
          await Hive.deleteBoxFromDisk(boxName);
          _box = await Hive.openBox<JournalEntry>(
            boxName,
            encryptionCipher: HiveAesCipher(encryptionKey),
          );
        }
      } else {
        _box = Hive.box<JournalEntry>(boxName);
      }

      await _loadCachedEntries();
    } catch (e) {
      debugPrint('❌ Error initializing JournalService: $e');
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
        for (final entry in _box!.values) {
          try {
            if (entry.id.isNotEmpty &&
                entry.reflection.isNotEmpty &&
                entry.rating >= 0 &&
                entry.rating <= 5) {
              validEntries.add(entry);
            }
          } catch (e) {
            continue;
          }
        }
        _cachedEntries = validEntries;
        _cachedEntries.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
        _lastLocalFetch = DateTime.now();
      }
    } catch (e) {
      debugPrint('❌ Error loading cached journal entries: $e');
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
      if (_cachedEntries.isNotEmpty && _isCacheValid()) {
        return _cachedEntries;
      }
      if (_shouldRefreshFromServer()) {
        await _refreshFromServer();
      }
      return _cachedEntries;
    } catch (e) {
      debugPrint('❌ Error getting journal entries: $e');
      return _cachedEntries.isNotEmpty ? _cachedEntries : [];
    }
  }

  /// Create a new journal entry (store locally and sync to server)
  Future<void> createEntry(JournalEntry entry) async {
    try {
      await _ensureInitialized();

      if (entry.id.isEmpty || entry.reflection.trim().isEmpty) {
        throw ArgumentError('Journal entry must have ID and non-empty reflection');
      }
      if (entry.rating < 0 || entry.rating > 5) {
        throw ArgumentError('Rating must be between 0 and 5');
      }

      await _box!.put(entry.id, entry);

      final existingIndex = _cachedEntries.indexWhere((e) => e.id == entry.id);
      if (existingIndex == -1) {
        _cachedEntries.insert(0, entry);
      }

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
    } catch (e) {
      debugPrint('⚠️ Failed to sync journal entry to server: $e');
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
      await _box!.clear();
      _cachedEntries.clear();
      for (final entry in serverEntries) {
        await _box!.put(entry.id, entry);
        _cachedEntries.add(entry);
      }
      _cachedEntries.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
      _lastLocalFetch = DateTime.now();
    } catch (e) {
      debugPrint('❌ Error refreshing journal entries from server: $e');
    }
  }

  /// Force refresh from server (for pull-to-refresh)
  Future<void> refreshFromServer() async {
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
      await _box!.delete(entryId);
      _cachedEntries.removeWhere((entry) => entry.id == entryId);
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
    } catch (e) {
      debugPrint('⚠️ Failed to sync journal entry deletion to server: $e');
    }
  }

  /// Search journal entries locally
  List<JournalEntry> searchEntries(String query) {
    if (query.trim().isEmpty) return _cachedEntries;

    final searchLower = query.toLowerCase().trim();
    return _cachedEntries.where((entry) {
      return entry.reflection.toLowerCase().contains(searchLower);
    }).toList();
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

  /// Clear local journal cache (called on user sign-out to prevent data leakage)
  Future<void> clearCache() async {
    try {
      await _ensureInitialized();
      await _box!.clear();
      _cachedEntries.clear();
      _lastLocalFetch = null;
    } catch (e) {
      debugPrint('❌ Error clearing journal cache: $e');
    }
  }

  /// Force refresh from server (called on user sign-in to load new user's data)
  Future<void> forceRefreshOnSignIn() async {
    try {
      await clearCache();
      await _refreshFromServer();
    } catch (e) {
      debugPrint('❌ Error force refreshing journal: $e');
      _cachedEntries.clear();
    }
  }
}


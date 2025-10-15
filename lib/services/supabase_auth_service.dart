// lib/services/supabase_auth_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import '../services/journal_service.dart';

/// Real authentication service using Supabase Auth
/// Replaces SimpleAuthService with actual authentication
class SupabaseAuthService extends ChangeNotifier {
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  static SupabaseAuthService get instance => _instance;

  // Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;

  // Internal state
  bool _isLoading = false;
  String? _error;
  User? _currentUser;
  String? _deviceId;
  StreamSubscription<AuthState>? _authStateSubscription;

  // Getters
  bool get isAuthenticated => _currentUser != null;
  bool get isAnonymous => _currentUser == null && _deviceId != null;
  String? get error => _error;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  String? get userEmail => _currentUser?.email;
  String? get userId => _currentUser?.id ?? _deviceId;

  // Get display name from user metadata or email
  String? get displayName {
    if (_currentUser != null) {
      // Try to get name from user metadata
      final metadata = _currentUser!.userMetadata;
      if (metadata != null && metadata['name'] != null) {
        return metadata['name'] as String;
      }
      // Fallback to email username part
      if (_currentUser!.email != null) {
        return _currentUser!.email!.split('@').first;
      }
    }
    return null;
  }

  /// Get user ID for database operations
  /// Returns actual user UUID for authenticated users, device ID for anonymous
  String get databaseUserId {
    if (_currentUser != null) {
      return _currentUser!.id;
    }
    // For anonymous users, use device-based ID with fallback
    return _deviceId ?? 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Initialize the authentication service
  Future<void> initialize() async {
    try {
      // Generate device ID for anonymous users
      _deviceId = await _generateDeviceId();

      // Check for existing session
      final session = _supabase.auth.currentSession;
      if (session != null) {
        _currentUser = session.user;
        debugPrint('✅ Restored session for user: ${_currentUser?.email}');
      }

      // Listen to auth state changes (store subscription for proper disposal)
      _authStateSubscription = _supabase.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        final session = data.session;

        // 🔍 DEBUG: Comprehensive auth state logging
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('🔐 AUTH STATE CHANGE DETECTED');
        debugPrint('   Event: $event');
        debugPrint('   Has session: ${session != null}');
        if (session != null) {
          debugPrint('   User ID: ${session.user.id}');
          debugPrint('   User email: ${session.user.email}');
          debugPrint('   Session valid: ${session.expiresAt != null}');
          debugPrint('   Access token present: ${session.accessToken.isNotEmpty}');
        }
        debugPrint('   Previous user: ${_currentUser?.email ?? "none"}');

        // Track previous user ID to detect user changes
        final previousUserId = _currentUser?.id;

        if (session != null) {
          _currentUser = session.user;
          debugPrint('   ✅ User authenticated: ${_currentUser?.email}');

          // If user changed (different ID), force refresh journal to prevent data leakage
          if (previousUserId != null && previousUserId != _currentUser!.id) {
            debugPrint('   👤 User changed from $previousUserId to ${_currentUser!.id}');
            _forceRefreshJournalOnUserChange();
          }
        } else {
          _currentUser = null;
          debugPrint('   ❌ User signed out');
        }

        debugPrint('   🔔 Notifying listeners...');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        notifyListeners();
      });

      debugPrint('✅ SupabaseAuthService initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize SupabaseAuthService: $e');
      _error = 'Failed to initialize authentication service';
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate input
      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      if (!_isValidPassword(password)) {
        throw Exception('Password must be at least 8 characters with numbers and letters');
      }

      // Sign up with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email.toLowerCase().trim(),
        password: password,
        data: {'name': name}, // Store name in user metadata
        emailRedirectTo: 'com.hub4apps.gitawisdom://login-callback',
      );

      if (response.user == null) {
        throw Exception('Failed to create account. Please try again.');
      }

      _currentUser = response.user;

      // Create initial user settings in database
      await _createUserSettings(response.user!.id, name, email);

      debugPrint('✅ Account created for: $email');

      // Check if email confirmation is required
      if (response.user?.emailConfirmedAt == null) {
        _error = 'Please check your email to verify your account';
        return true; // Account created but needs verification
      }

      return true;
    } on AuthException catch (e) {
      _error = _handleAuthException(e);
      debugPrint('❌ Sign up failed: ${e.message}');
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Sign up error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );

      if (response.user == null) {
        throw Exception('Invalid email or password');
      }

      _currentUser = response.user;

      // Migrate any anonymous data to this user
      await _migrateAnonymousData(response.user!.id);

      debugPrint('✅ Signed in: ${response.user?.email}');
      return true;
    } on AuthException catch (e) {
      _error = _handleAuthException(e);
      debugPrint('❌ Sign in failed: ${e.message}');
      return false;
    } catch (e) {
      _error = 'Failed to sign in. Please check your credentials.';
      debugPrint('❌ Sign in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in anonymously (device-based)
  Future<bool> signInAnonymously() async {
    _setLoading(true);
    _clearError();

    try {
      // For anonymous users, we just use device ID
      // No actual Supabase auth session is created
      _currentUser = null;
      _deviceId = await _generateDeviceId();

      debugPrint('✅ Continuing as anonymous with device ID: $_deviceId');
      return true;
    } catch (e) {
      _error = 'Failed to continue as guest';
      debugPrint('❌ Anonymous sign in failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;

      // Clear journal cache to prevent data leakage between users
      try {
        await JournalService.instance.clearCache();
        debugPrint('✅ Journal cache cleared on sign-out');
      } catch (e) {
        debugPrint('⚠️ Failed to clear journal cache on sign-out: $e');
      }

      debugPrint('👋 User signed out');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Reset password for given email
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      await _supabase.auth.resetPasswordForEmail(
        email.toLowerCase().trim(),
        redirectTo: 'com.hub4apps.gitawisdom://reset-password',
      );

      debugPrint('📧 Password reset email sent to: $email');
      _error = null; // Clear any errors
      return true;
    } on AuthException catch (e) {
      _error = _handleAuthException(e);
      debugPrint('❌ Password reset failed: ${e.message}');
      return false;
    } catch (e) {
      _error = 'Failed to send reset email. Please try again.';
      debugPrint('❌ Password reset error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update password for authenticated user
  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser == null) {
        throw Exception('You must be signed in to change password');
      }

      if (!_isValidPassword(newPassword)) {
        throw Exception('Password must be at least 8 characters with numbers and letters');
      }

      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user != null) {
        debugPrint('✅ Password updated successfully');
        return true;
      }

      throw Exception('Failed to update password');
    } on AuthException catch (e) {
      _error = _handleAuthException(e);
      debugPrint('❌ Password update failed: ${e.message}');
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      debugPrint('❌ Password update error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify OTP from email
  Future<bool> verifyOTP(String email, String token) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email.toLowerCase().trim(),
        token: token,
      );

      if (response.user != null) {
        _currentUser = response.user;
        debugPrint('✅ Email verified for: ${response.user?.email}');
        return true;
      }

      throw Exception('Invalid verification code');
    } on AuthException catch (e) {
      _error = _handleAuthException(e);
      debugPrint('❌ OTP verification failed: ${e.message}');
      return false;
    } catch (e) {
      _error = 'Verification failed. Please check the code.';
      debugPrint('❌ OTP error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete user account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser == null) {
        throw Exception('You must be signed in to delete account');
      }

      // Delete user data from database first
      await _deleteUserData(_currentUser!.id);

      // Then delete the auth account
      // Note: This requires service role key on server side
      // For now, we'll just sign out
      await signOut();

      debugPrint('✅ Account deletion initiated');
      return true;
    } catch (e) {
      // Show the actual error for debugging instead of generic message
      final errorMsg = e.toString();
      if (errorMsg.contains('signed in')) {
        _error = 'You must be signed in to delete your account';
      } else if (errorMsg.contains('permission') || errorMsg.contains('RLS') || errorMsg.contains('policy')) {
        _error = 'Permission denied. Please ensure you are the account owner.';
      } else {
        _error = 'Failed to delete account: ${errorMsg.replaceAll('Exception:', '').trim()}';
      }
      debugPrint('❌ Account deletion error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Stream for auth state changes
  Stream<bool> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((data) {
      return data.session != null;
    });
  }

  // ============= Private Helper Methods =============

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Force refresh journal when user changes (prevents data leakage)
  void _forceRefreshJournalOnUserChange() {
    try {
      // Run in background to avoid blocking auth flow
      JournalService.instance.forceRefreshOnSignIn().catchError((e) {
        debugPrint('⚠️ Failed to force refresh journal on user change: $e');
      });
      debugPrint('✅ Journal refresh initiated for new user');
    } catch (e) {
      debugPrint('⚠️ Failed to initiate journal refresh: $e');
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password strength
  bool _isValidPassword(String password) {
    // At least 8 chars, contains letter and number
    return password.length >= 8 &&
           RegExp(r'[a-zA-Z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password);
  }

  /// Handle Supabase auth exceptions
  String _handleAuthException(AuthException e) {
    switch (e.message.toLowerCase()) {
      case String msg when msg.contains('email already registered'):
        return 'This email is already registered. Please sign in.';
      case String msg when msg.contains('invalid login'):
        return 'Invalid email or password.';
      case String msg when msg.contains('email not confirmed'):
        return 'Please verify your email before signing in.';
      case String msg when msg.contains('user not found'):
        return 'No account found with this email.';
      case String msg when msg.contains('weak password'):
        return 'Password is too weak. Please use a stronger password.';
      case String msg when msg.contains('rate limit'):
        return 'Too many attempts. Please try again later.';
      default:
        return e.message;
    }
  }

  /// Generate device-specific ID for anonymous users
  Future<String> _generateDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceData = '';

      if (!kIsWeb) {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceData = '${androidInfo.id}_${androidInfo.model}';
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceData = '${iosInfo.identifierForVendor}_${iosInfo.model}';
        }
      }

      // Fallback for web or if device info fails
      if (deviceData.isEmpty) {
        deviceData = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // Create SHA256 hash of device data
      final bytes = utf8.encode(deviceData);
      final digest = crypto.sha256.convert(bytes);
      final deviceId = 'device_${digest.toString().substring(0, 16)}';

      return deviceId;
    } catch (e) {
      debugPrint('⚠️ Failed to generate device ID: $e');
      // Fallback to timestamp-based ID
      return 'device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Create initial user settings in database
  Future<void> _createUserSettings(String userId, String name, String email) async {
    try {
      await _supabase.from('user_settings').upsert({
        'id': userId,
        'user_device_id': userId,
        'user_name': name,
        'user_email': email,
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ User settings created for $userId');
    } catch (e) {
      debugPrint('⚠️ Failed to create user settings: $e');
      // Non-critical error - user can still use the app
    }
  }

  /// Migrate anonymous data to authenticated user
  /// Note: Schema uses user_device_id for all tables, no separate user_id column
  Future<void> _migrateAnonymousData(String userId) async {
    try {
      if (_deviceId == null) return;

      // Tables use user_device_id for both anonymous and authenticated users
      // No migration needed - data is already associated with device ID
      // Authenticated users continue using same device ID

      debugPrint('✅ Data already associated with device ID (no migration needed)');
    } catch (e) {
      debugPrint('⚠️ Error in data migration check: $e');
      // Non-critical - user can still access their new account
    }
  }

  /// Delete all user data (for account deletion)
  /// Schema uses user_id for authenticated users, user_device_id for anonymous users
  Future<void> _deleteUserData(String userId) async {
    try {
      final user = _supabase.auth.currentUser;

      if (user != null) {
        // Authenticated user - use user_id column for most tables
        await _supabase.from('journal_entries').delete().eq('user_id', user.id);
        await _supabase.from('user_progress').delete().eq('user_device_id', user.id);
        await _supabase.from('user_settings').delete().eq('user_device_id', user.id);

        // SPECIAL CASE: user_bookmarks only has user_device_id column (not user_id)
        // Authenticated users store their auth.uid in user_device_id field
        await _supabase.from('user_bookmarks').delete().eq('user_device_id', user.id);

        debugPrint('✅ User data deleted for authenticated user: ${user.id}');
      } else if (_deviceId != null) {
        // Anonymous user - use user_device_id column for all tables
        await _supabase.from('journal_entries').delete().eq('user_device_id', _deviceId!);
        await _supabase.from('user_bookmarks').delete().eq('user_device_id', _deviceId!);
        await _supabase.from('user_progress').delete().eq('user_device_id', _deviceId!);
        await _supabase.from('user_settings').delete().eq('user_device_id', _deviceId!);
        debugPrint('✅ User data deleted for anonymous user: $_deviceId');
      } else {
        debugPrint('⚠️ No user or device ID available, skipping Supabase deletion');
      }
    } catch (e) {
      debugPrint('❌ Failed to delete user data: $e');
      throw e;
    }
  }

  /// Check if user exists (for sign up flow)
  Future<bool> checkUserExists(String email) async {
    try {
      // This is handled by Supabase Auth automatically
      // Just return false to allow sign up attempt
      return false;
    } catch (e) {
      debugPrint('❌ Error checking user existence: $e');
      return false;
    }
  }

  /// Clear any existing error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Continue as anonymous user without authentication
  Future<bool> continueAsAnonymous() async {
    try {
      _setLoading(true);
      clearError();

      // Generate device ID for anonymous mode
      _deviceId = await _generateDeviceId();
      debugPrint('✅ Continuing as anonymous user with device ID: $_deviceId');

      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('❌ Failed to continue as anonymous: $e');
      _error = 'Failed to continue as anonymous user';
      _setLoading(false);
      return false;
    }
  }

  // ============= Social Authentication Methods =============

  /// Sign in with Google using Supabase OAuth
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔵 GOOGLE OAUTH: Starting sign-in flow');
    debugPrint('   Timestamp: ${DateTime.now()}');

    try {
      // Google requires the Supabase HTTPS callback URL, not the app deep link
      // The deep link is handled automatically by Supabase after OAuth completes
      debugPrint('📤 GOOGLE OAUTH: Calling Supabase.auth.signInWithOAuth');
      debugPrint('   Provider: google');
      debugPrint('   Launch mode: externalApplication');

      final result = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      debugPrint('📥 GOOGLE OAUTH: signInWithOAuth returned');
      debugPrint('   Result: $result');

      if (result) {
        // Clear error state and notify listeners when OAuth successfully initiates
        // This ensures UI updates immediately to hide any error banners
        _clearError();
        debugPrint('✅ GOOGLE OAUTH: Successfully initiated - browser should open');
        debugPrint('   Waiting for user to complete OAuth in browser...');
        debugPrint('   Deep link callback will be handled by Supabase SDK');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return true;
      }

      throw Exception('Failed to initiate Google sign-in');
    } on AuthException catch (e) {
      _error = _handleAuthException(e);
      debugPrint('❌ GOOGLE OAUTH: AuthException - ${e.message}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return false;
    } catch (e) {
      _error = 'Failed to sign in with Google. Please try again.';
      debugPrint('❌ GOOGLE OAUTH: Error - $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Apple using Supabase OAuth
  Future<bool> signInWithApple() async {
    _setLoading(true);
    _clearError();

    try {
      // Apple requires the Supabase HTTPS callback URL, not the app deep link
      // The deep link is handled automatically by Supabase after OAuth completes
      final result = await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (result) {
        // Clear error state and notify listeners when OAuth successfully initiates
        // This ensures UI updates immediately to hide any error banners
        _clearError();
        debugPrint('✅ Apple sign-in initiated');
        return true;
      }

      throw Exception('Failed to initiate Apple sign-in');
    } on AuthException catch (e) {
      _error = _handleAuthException(e);
      debugPrint('❌ Apple sign-in failed: ${e.message}');
      return false;
    } catch (e) {
      _error = 'Failed to sign in with Apple. Please try again.';
      debugPrint('❌ Apple sign-in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Facebook sign-in removed - not being used in production

  /// Dispose method to cleanup resources and prevent memory leaks
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _authStateSubscription = null;
    debugPrint('🧹 SupabaseAuthService disposed - auth stream subscription cancelled');
    super.dispose();
  }
}
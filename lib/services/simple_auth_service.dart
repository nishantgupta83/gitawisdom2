// Simple authentication service for journal access
import 'package:flutter/foundation.dart';

class SimpleAuthService extends ChangeNotifier {
  static final SimpleAuthService _instance = SimpleAuthService._internal();
  factory SimpleAuthService() => _instance;
  SimpleAuthService._internal();

  static SimpleAuthService get instance => _instance;

  bool _isAuthenticated = false;
  bool _isGuest = false;
  String? _error;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated || _isGuest;
  bool get isAnonymous => _isGuest;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Stream<bool> get authStateChanges => Stream.periodic(
    const Duration(seconds: 1),
    (count) => isAuthenticated,
  ).distinct();

  Future<void> initialize() async {
    // Simple initialization - just ensure service is ready
    debugPrint('✅ SimpleAuthService initialized');
  }

  Future<bool> signInAnonymously() async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate auth
      _isGuest = true;
      _isAuthenticated = false;
      _error = null;
      debugPrint('✅ Signed in as guest');
      return true;
    } catch (e) {
      _error = 'Failed to sign in as guest';
      debugPrint('❌ Guest sign-in failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate auth
      _isAuthenticated = true;
      _isGuest = false;
      _error = null;
      debugPrint('✅ Signed in with email: $email');
      return true;
    } catch (e) {
      _error = 'Failed to sign in with email and password';
      debugPrint('❌ Email sign-in failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate auth
      _isAuthenticated = true;
      _isGuest = false;
      _error = null;
      debugPrint('✅ Signed up with email: $email');
      return true;
    } catch (e) {
      _error = 'Failed to create account';
      debugPrint('❌ Sign-up failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _isGuest = false;
    _error = null;
    notifyListeners();
    debugPrint('👋 Signed out');
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Additional methods for compatibility
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    return await signUp(email, password, name);
  }

  Future<bool> continueAsAnonymous() async {
    return await signInAnonymously();
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('📧 Password reset sent to: $email');
      return true;
    } catch (e) {
      _error = 'Failed to send password reset email';
      debugPrint('❌ Password reset failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
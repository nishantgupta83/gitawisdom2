// test/test_setup.dart
// Centralized test setup and mock implementations

import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

// ============================================================================
// SUPABASE MOCKS
// ============================================================================

class MockSupabaseClient extends Mock implements SupabaseClient {
  @override
  late GoTrueClient auth;

  MockSupabaseClient() {
    auth = MockGoTrueClient();
  }

  @override
  RealtimeClient get realtime => MockRealtimeClient();

  @override
  SupabaseQueryBuilder from(String table) {
    return MockSupabaseQueryBuilder();
  }

  @override
  SupabaseQueryBuilder rpc(String fn, {Map<String, dynamic>? params}) {
    return MockSupabaseQueryBuilder();
  }
}

class MockGoTrueClient extends Mock implements GoTrueClient {
  late Session? _session;

  MockGoTrueClient() {
    _session = null;
  }

  @override
  Session? get currentSession => _session;

  @override
  User? get currentUser => _session?.user;

  @override
  Stream<AuthState> get onAuthStateChange {
    return Stream.value(AuthState(
      event: AuthChangeEvent.initialSession,
      session: _session,
    ));
  }

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    // Mock successful login
    _session = Session(
      accessToken: 'mock_access_token',
      tokenType: 'Bearer',
      expiresIn: 3600,
      refreshToken: 'mock_refresh_token',
      user: User(
        id: 'mock_user_id',
        appMetadata: {},
        userMetadata: {'email': email},
        aud: 'authenticated',
        createdAt: DateTime.now(),
        confirmationSentAt: DateTime.now(),
        email: email,
        emailConfirmedAt: DateTime.now(),
        phone: null,
        phoneConfirmedAt: null,
        lastSignInAt: DateTime.now(),
        role: 'authenticated',
        updatedAt: DateTime.now(),
      ),
    );

    return AuthResponse(session: _session, user: _session?.user);
  }

  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.local}) async {
    _session = null;
  }

  @override
  Future<AuthResponse> signInAnonymously({
    Map<String, dynamic>? data,
  }) async {
    _session = Session(
      accessToken: 'mock_anon_token',
      tokenType: 'Bearer',
      expiresIn: 3600,
      user: User(
        id: 'mock_anon_user_id',
        appMetadata: {},
        userMetadata: data ?? {},
        aud: 'authenticated',
        createdAt: DateTime.now(),
        confirmationSentAt: DateTime.now(),
        email: null,
        emailConfirmedAt: null,
        phone: null,
        phoneConfirmedAt: null,
        lastSignInAt: DateTime.now(),
        role: 'authenticated',
        updatedAt: DateTime.now(),
      ),
    );

    return AuthResponse(session: _session, user: _session?.user);
  }
}

class MockRealtimeClient extends Mock implements RealtimeClient {
  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}
}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {
  late List<Map<String, dynamic>> _mockData = [];

  @override
  SupabaseQueryBuilder select(String columns) {
    return this;
  }

  @override
  SupabaseQueryBuilder eq(String column, dynamic value) {
    return this;
  }

  @override
  SupabaseQueryBuilder neq(String column, dynamic value) {
    return this;
  }

  @override
  SupabaseQueryBuilder gt(String column, dynamic value) {
    return this;
  }

  @override
  SupabaseQueryBuilder lt(String column, dynamic value) {
    return this;
  }

  @override
  SupabaseQueryBuilder gte(String column, dynamic value) {
    return this;
  }

  @override
  SupabaseQueryBuilder lte(String column, dynamic value) {
    return this;
  }

  @override
  SupabaseQueryBuilder filter(String column, String op, dynamic value) {
    return this;
  }

  @override
  SupabaseQueryBuilder order(String column,
      {bool ascending = true, bool nullsFirst = false}) {
    return this;
  }

  @override
  SupabaseQueryBuilder limit(int count) {
    return this;
  }

  @override
  SupabaseQueryBuilder offset(int count) {
    return this;
  }

  @override
  Future<List<Map<String, dynamic>>> get() async {
    return _mockData;
  }

  @override
  Future<Map<String, dynamic>> single() async {
    return _mockData.isNotEmpty ? _mockData.first : {};
  }

  @override
  Future<Map<String, dynamic>> maybeSingle() async {
    return _mockData.isNotEmpty ? _mockData.first : {};
  }

  // Helper method for tests to set mock data
  void setMockData(List<Map<String, dynamic>> data) {
    _mockData = data;
  }
}

// ============================================================================
// HIVE MOCKS
// ============================================================================

class MockHiveBox<E> extends Mock implements Box<E> {
  final Map<dynamic, E> _data = {};

  @override
  String get name => 'mock_box';

  @override
  bool get isOpen => true;

  @override
  Future<void> clear() async {
    _data.clear();
  }

  @override
  Future<void> close() async {
    _data.clear();
  }

  @override
  Future<int> add(E value) async {
    final key = _data.keys.isEmpty ? 0 : (_data.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1);
    _data[key] = value;
    return key;
  }

  @override
  Future<void> put(dynamic key, E value) async {
    _data[key] = value;
  }

  @override
  Future<void> putAll(Map<dynamic, E> entries) async {
    _data.addAll(entries);
  }

  @override
  E? get(dynamic key, {E? defaultValue}) {
    return _data[key] ?? defaultValue;
  }

  @override
  E? getAt(int index) {
    if (index < 0 || index >= _data.length) return null;
    return _data.values.toList()[index];
  }

  @override
  Future<void> delete(dynamic key) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAt(int index) async {
    if (index >= 0 && index < _data.length) {
      _data.remove(_data.keys.toList()[index]);
    }
  }

  @override
  int get length => _data.length;

  @override
  bool containsKey(dynamic key) => _data.containsKey(key);

  @override
  Iterable<E> get values => _data.values;

  @override
  Iterable<dynamic> get keys => _data.keys;

  @override
  Map<dynamic, E> toMap() => Map.from(_data);

  @override
  Future<void> compact() async {}
}

// ============================================================================
// GLOBAL TEST SETUP HELPERS
// ============================================================================

/// Initialize mocks for Supabase before tests run
MockSupabaseClient initSupabaseMock() {
  return MockSupabaseClient();
}

/// Initialize mock Hive box for tests
MockHiveBox<T> initHiveBoxMock<T>() {
  return MockHiveBox<T>();
}

/// Setup test environment with default mocks
Future<void> setupTestEnvironment() async {
  // Disable debug prints during tests for cleaner output
  debugPrint = (String? message, {int? wrapWidth}) {};
}

/// Cleanup after tests
Future<void> teardownTestEnvironment() async {
  debugPrint = debugPrintThrottled;
}

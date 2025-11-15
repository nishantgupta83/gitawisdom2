// test/mocks/auth_mocks.dart
// Comprehensive mocks for Supabase authentication testing

import 'package:flutter/foundation.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

// Type aliases for clarity
typedef PostgrestList = List<Map<String, dynamic>>;
typedef PostgrestMap = Map<String, dynamic>;

// Mock Supabase Client
class MockSupabaseClient extends Mock implements SupabaseClient {
  @override
  GoTrueClient get auth => super.noSuchMethod(
        Invocation.getter(#auth),
        returnValue: MockGoTrueClient(),
        returnValueForMissingStub: MockGoTrueClient(),
      );

  @override
  SupabaseQueryBuilder from(String table) => super.noSuchMethod(
        Invocation.method(#from, [table]),
        returnValue: MockSupabaseQueryBuilder(),
        returnValueForMissingStub: MockSupabaseQueryBuilder(),
      );

  @override
  FunctionsClient get functions => super.noSuchMethod(
        Invocation.getter(#functions),
        returnValue: MockFunctionsClient(),
        returnValueForMissingStub: MockFunctionsClient(),
      );
}

// Mock GoTrueClient (Auth)
class MockGoTrueClient extends Mock implements GoTrueClient {
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();

  @override
  Stream<AuthState> get onAuthStateChange => _authStateController.stream;

  @override
  Session? get currentSession => super.noSuchMethod(
        Invocation.getter(#currentSession),
        returnValue: null,
        returnValueForMissingStub: null,
      );

  @override
  User? get currentUser => super.noSuchMethod(
        Invocation.getter(#currentUser),
        returnValue: null,
        returnValueForMissingStub: null,
      );

  @override
  Future<AuthResponse> signUp({
    String? email,
    String? phone,
    String? password,
    String? emailRedirectTo,
    Map<String, dynamic>? data,
    String? captchaToken,
    OtpChannel? channel,
  }) =>
      super.noSuchMethod(
        Invocation.method(#signUp, [], {
          #email: email,
          #phone: phone,
          #password: password,
          #emailRedirectTo: emailRedirectTo,
          #data: data,
          #captchaToken: captchaToken,
          #channel: channel,
        }),
        returnValue: Future.value(
          AuthResponse(
            user: null,
            session: null,
          ),
        ),
        returnValueForMissingStub: Future.value(
          AuthResponse(
            user: null,
            session: null,
          ),
        ),
      );

  @override
  Future<AuthResponse> signInWithPassword({
    String? email,
    String? phone,
    required String password,
    String? captchaToken,
  }) =>
      super.noSuchMethod(
        Invocation.method(#signInWithPassword, [], {
          #email: email,
          #phone: phone,
          #password: password,
          #captchaToken: captchaToken,
        }),
        returnValue: Future.value(
          AuthResponse(
            user: null,
            session: null,
          ),
        ),
        returnValueForMissingStub: Future.value(
          AuthResponse(
            user: null,
            session: null,
          ),
        ),
      );

  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.global}) =>
      super.noSuchMethod(
        Invocation.method(#signOut, [], {#scope: scope}),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<void> resetPasswordForEmail(
    String email, {
    String? redirectTo,
    String? captchaToken,
  }) =>
      super.noSuchMethod(
        Invocation.method(#resetPasswordForEmail, [email], {
          #redirectTo: redirectTo,
          #captchaToken: captchaToken,
        }),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<UserResponse> updateUser(
    UserAttributes attributes, {
    String? emailRedirectTo,
  }) =>
      super.noSuchMethod(
        Invocation.method(#updateUser, [attributes], {
          #emailRedirectTo: emailRedirectTo,
        }),
        returnValue: Future.value(UserResponse(user: null)),
        returnValueForMissingStub: Future.value(UserResponse(user: null)),
      );

  @override
  Future<AuthResponse> verifyOTP({
    String? email,
    String? phone,
    String? token,
    String? tokenHash,
    required OtpType type,
    String? redirectTo,
    String? captchaToken,
  }) =>
      super.noSuchMethod(
        Invocation.method(#verifyOTP, [], {
          #email: email,
          #phone: phone,
          #token: token,
          #tokenHash: tokenHash,
          #type: type,
          #redirectTo: redirectTo,
          #captchaToken: captchaToken,
        }),
        returnValue: Future.value(
          AuthResponse(
            user: null,
            session: null,
          ),
        ),
        returnValueForMissingStub: Future.value(
          AuthResponse(
            user: null,
            session: null,
          ),
        ),
      );

  @override
  Future<AuthResponse> signInWithIdToken({
    required OAuthProvider provider,
    required String idToken,
    String? nonce,
    String? accessToken,
    String? captchaToken,
  }) =>
      super.noSuchMethod(
        Invocation.method(#signInWithIdToken, [], {
          #provider: provider,
          #idToken: idToken,
          #nonce: nonce,
          #accessToken: accessToken,
          #captchaToken: captchaToken,
        }),
        returnValue: Future.value(
          AuthResponse(
            user: null,
            session: null,
          ),
        ),
        returnValueForMissingStub: Future.value(
          AuthResponse(
            user: null,
            session: null,
          ),
        ),
      );

  @override
  String generateRawNonce() => super.noSuchMethod(
        Invocation.method(#generateRawNonce, []),
        returnValue: 'test-nonce-12345',
        returnValueForMissingStub: 'test-nonce-12345',
      );

  void dispose() {
    _authStateController.close();
  }
}

// Mock SupabaseQueryBuilder
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {
  @override
  PostgrestFilterBuilder<PostgrestList> select([String columns = '*']) => super.noSuchMethod(
        Invocation.method(#select, [columns]),
        returnValue: MockPostgrestFilterBuilder(),
        returnValueForMissingStub: MockPostgrestFilterBuilder(),
      ) as PostgrestFilterBuilder<PostgrestList>;

  @override
  PostgrestFilterBuilder<PostgrestList> insert(
    dynamic values, {
    bool? defaultToNull,
  }) =>
      super.noSuchMethod(
        Invocation.method(#insert, [values], {
          #defaultToNull: defaultToNull,
        }),
        returnValue: MockPostgrestFilterBuilder(),
        returnValueForMissingStub: MockPostgrestFilterBuilder(),
      ) as PostgrestFilterBuilder<PostgrestList>;

  @override
  PostgrestFilterBuilder<PostgrestList> delete() => super.noSuchMethod(
        Invocation.method(#delete, []),
        returnValue: MockPostgrestFilterBuilder(),
        returnValueForMissingStub: MockPostgrestFilterBuilder(),
      ) as PostgrestFilterBuilder<PostgrestList>;
}

// Mock PostgrestFilterBuilder
class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder {
  @override
  PostgrestFilterBuilder eq(String column, Object value) => super.noSuchMethod(
        Invocation.method(#eq, [column, value]),
        returnValue: this,
        returnValueForMissingStub: this,
      );

  @override
  PostgrestFilterBuilder order(
    String column, {
    bool ascending = false,
    bool nullsFirst = false,
    String? referencedTable,
    String? foreignTable,
  }) =>
      super.noSuchMethod(
        Invocation.method(#order, [column], {
          #ascending: ascending,
          #nullsFirst: nullsFirst,
          #referencedTable: referencedTable,
          #foreignTable: foreignTable,
        }),
        returnValue: this,
        returnValueForMissingStub: this,
      );

  @override
  PostgrestFilterBuilder limit(int count, {String? referencedTable}) =>
      super.noSuchMethod(
        Invocation.method(#limit, [count], {
          #referencedTable: referencedTable,
        }),
        returnValue: this,
        returnValueForMissingStub: this,
      );

  @override
  PostgrestTransformBuilder<PostgrestMap> single() => super.noSuchMethod(
        Invocation.method(#single, []),
        returnValue: this,
        returnValueForMissingStub: this,
      ) as PostgrestTransformBuilder<PostgrestMap>;

  @override
  PostgrestTransformBuilder<PostgrestMap?> maybeSingle() => super.noSuchMethod(
        Invocation.method(#maybeSingle, []),
        returnValue: this,
        returnValueForMissingStub: this,
      ) as PostgrestTransformBuilder<PostgrestMap?>;

  // These methods need to return Future/data when awaited
  Future<U> then<U>(FutureOr<U> Function(PostgrestList) onValue, {Function? onError}) {
    return Future.value([] as PostgrestList).then(onValue, onError: onError);
  }
}

// Mock FunctionsClient
class MockFunctionsClient extends Mock implements FunctionsClient {
  @override
  Future<FunctionResponse> invoke(
    String functionName, {
    Object? body,
    Map<String, String>? headers,
    HttpMethod method = HttpMethod.post,
    Map<String, String>? queryParameters,
    Iterable<http.MultipartFile>? files,
  }) =>
      super.noSuchMethod(
        Invocation.method(#invoke, [functionName], {
          #body: body,
          #headers: headers,
          #method: method,
          #queryParameters: queryParameters,
          #files: files,
        }),
        returnValue: Future.value(
          FunctionResponse(data: {'success': true}, status: 200),
        ),
        returnValueForMissingStub: Future.value(
          FunctionResponse(data: {'success': true}, status: 200),
        ),
      );
}

// Mock User
class MockUser extends Mock implements User {
  @override
  String get id => super.noSuchMethod(
        Invocation.getter(#id),
        returnValue: 'test-user-id-12345',
        returnValueForMissingStub: 'test-user-id-12345',
      );

  @override
  String? get email => super.noSuchMethod(
        Invocation.getter(#email),
        returnValue: 'test@example.com',
        returnValueForMissingStub: 'test@example.com',
      );

  @override
  Map<String, dynamic>? get userMetadata => super.noSuchMethod(
        Invocation.getter(#userMetadata),
        returnValue: {'name': 'Test User'},
        returnValueForMissingStub: {'name': 'Test User'},
      );

  @override
  String? get emailConfirmedAt => super.noSuchMethod(
        Invocation.getter(#emailConfirmedAt),
        returnValue: DateTime.now().toIso8601String(),
        returnValueForMissingStub: DateTime.now().toIso8601String(),
      );
}

// Mock Session
class MockSession extends Mock implements Session {
  @override
  User get user => super.noSuchMethod(
        Invocation.getter(#user),
        returnValue: MockUser(),
        returnValueForMissingStub: MockUser(),
      );

  @override
  String get accessToken => super.noSuchMethod(
        Invocation.getter(#accessToken),
        returnValue: 'test-access-token-12345',
        returnValueForMissingStub: 'test-access-token-12345',
      );

  @override
  int? get expiresAt => super.noSuchMethod(
        Invocation.getter(#expiresAt),
        returnValue: DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch,
        returnValueForMissingStub: DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch,
      );
}

// Mock GoogleSignIn
class MockGoogleSignIn extends Mock implements GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signIn() => super.noSuchMethod(
        Invocation.method(#signIn, []),
        returnValue: Future.value(null),
        returnValueForMissingStub: Future.value(null),
      );
}

// Mock GoogleSignInAccount
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {
  @override
  String get email => super.noSuchMethod(
        Invocation.getter(#email),
        returnValue: 'test@gmail.com',
        returnValueForMissingStub: 'test@gmail.com',
      );

  @override
  Future<GoogleSignInAuthentication> get authentication => super.noSuchMethod(
        Invocation.getter(#authentication),
        returnValue: Future.value(MockGoogleSignInAuthentication()),
        returnValueForMissingStub: Future.value(MockGoogleSignInAuthentication()),
      );
}

// Mock GoogleSignInAuthentication
class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {
  @override
  String? get idToken => super.noSuchMethod(
        Invocation.getter(#idToken),
        returnValue: 'test-google-id-token',
        returnValueForMissingStub: 'test-google-id-token',
      );

  @override
  String? get accessToken => super.noSuchMethod(
        Invocation.getter(#accessToken),
        returnValue: 'test-google-access-token',
        returnValueForMissingStub: 'test-google-access-token',
      );
}

// Helper function to create mock AuthResponse
AuthResponse createMockAuthResponse({
  User? user,
  Session? session,
}) {
  return AuthResponse(
    user: user,
    session: session,
  );
}

// Helper function to create mock User
User createMockUser({
  String id = 'test-user-id',
  String? email = 'test@example.com',
  Map<String, dynamic>? metadata,
  String? emailConfirmedAt,
}) {
  final mockUser = MockUser();
  when(mockUser.id).thenReturn(id);
  when(mockUser.email).thenReturn(email);
  when(mockUser.userMetadata).thenReturn(metadata ?? {'name': 'Test User'});
  when(mockUser.emailConfirmedAt).thenReturn(emailConfirmedAt ?? DateTime.now().toIso8601String());
  return mockUser;
}

// Helper function to create mock Session
Session createMockSession({
  User? user,
  String accessToken = 'test-access-token',
}) {
  final mockSession = MockSession();
  when(mockSession.user).thenReturn(user ?? createMockUser());
  when(mockSession.accessToken).thenReturn(accessToken);
  when(mockSession.expiresAt).thenReturn(
    DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch,
  );
  return mockSession;
}

// ==================== Additional Mock Classes ====================

/// Mock AuthResponse for testing auth flows
class MockAuthResponse extends Mock implements AuthResponse {
  @override
  User? get user => super.noSuchMethod(
        Invocation.getter(#user),
        returnValue: null,
        returnValueForMissingStub: null,
      );

  @override
  Session? get session => super.noSuchMethod(
        Invocation.getter(#session),
        returnValue: null,
        returnValueForMissingStub: null,
      );
}

/// Mock UserAttributes for profile updates
class MockUserAttributes extends Mock implements UserAttributes {
  @override
  String? get email => super.noSuchMethod(
        Invocation.getter(#email),
        returnValue: null,
        returnValueForMissingStub: null,
      );

  @override
  Map<String, dynamic>? get data => super.noSuchMethod(
        Invocation.getter(#data),
        returnValue: null,
        returnValueForMissingStub: null,
      );
}

/// Mock UserResponse for user operations
class MockUserResponse extends Mock implements UserResponse {
  @override
  User? get user => super.noSuchMethod(
        Invocation.getter(#user),
        returnValue: null,
        returnValueForMissingStub: null,
      );
}

// ==================== Enhanced Helper Functions ====================

/// Create a mock authenticated User with full details
User createAuthenticatedUser({
  String id = 'auth-user-123',
  String email = 'user@example.com',
  String? displayName = 'Test User',
  bool emailConfirmed = true,
}) {
  final mockUser = MockUser();
  when(mockUser.id).thenReturn(id);
  when(mockUser.email).thenReturn(email);
  when(mockUser.userMetadata).thenReturn({
    'name': displayName,
    'email_confirmed': emailConfirmed,
  });
  when(mockUser.emailConfirmedAt).thenReturn(
    emailConfirmed ? DateTime.now().toIso8601String() : null,
  );
  return mockUser;
}

/// Create a mock anonymous User
User createAnonymousUser({
  String id = 'anon-user-456',
}) {
  final mockUser = MockUser();
  when(mockUser.id).thenReturn(id);
  when(mockUser.email).thenReturn(null);
  when(mockUser.userMetadata).thenReturn({
    'is_anonymous': true,
  });
  when(mockUser.emailConfirmedAt).thenReturn(null);
  return mockUser;
}

/// Create a complete authenticated AuthResponse
AuthResponse createAuthenticatedAuthResponse({
  String userId = 'auth-user-123',
  String email = 'user@example.com',
  String accessToken = 'auth-token-12345',
}) {
  final user = createAuthenticatedUser(id: userId, email: email);
  final session = createMockSession(user: user, accessToken: accessToken);
  return AuthResponse(user: user, session: session);
}

/// Create an anonymous AuthResponse
AuthResponse createAnonymousAuthResponse({
  String userId = 'anon-user-456',
  String accessToken = 'anon-token-12345',
}) {
  final user = createAnonymousUser(id: userId);
  final session = createMockSession(user: user, accessToken: accessToken);
  return AuthResponse(user: user, session: session);
}

/// Create a failed AuthResponse (null user and session)
AuthResponse createFailedAuthResponse() {
  return AuthResponse(user: null, session: null);
}

// ==================== Auth State Helpers ====================

/// Setup mock GoTrueClient for successful authentication
void setupSuccessfulAuth(
  MockGoTrueClient mockAuth, {
  String email = 'test@example.com',
  String password = 'password123',
  String userId = 'user-123',
}) {
  final authResponse = createAuthenticatedAuthResponse(
    userId: userId,
    email: email,
  );

  when(mockAuth.signInWithPassword(
    email: email,
    password: password,
  )).thenAnswer((_) async => authResponse);

  when(mockAuth.currentUser).thenReturn(authResponse.user);
  when(mockAuth.currentSession).thenReturn(authResponse.session);
}

/// Setup mock GoTrueClient for failed authentication
void setupFailedAuth(
  MockGoTrueClient mockAuth, {
  String email = 'test@example.com',
  String password = 'wrong-password',
}) {
  when(mockAuth.signInWithPassword(
    email: email,
    password: password,
  )).thenThrow(AuthException('Invalid credentials'));

  when(mockAuth.currentUser).thenReturn(null);
  when(mockAuth.currentSession).thenReturn(null);
}

/// Setup mock GoTrueClient for anonymous auth
void setupAnonymousAuth(MockGoTrueClient mockAuth) {
  final authResponse = createAnonymousAuthResponse();

  when(mockAuth.signUp(
    email: anyNamed('email'),
    password: anyNamed('password'),
    data: anyNamed('data'),
  )).thenAnswer((_) async => authResponse);

  when(mockAuth.currentUser).thenReturn(authResponse.user);
  when(mockAuth.currentSession).thenReturn(authResponse.session);
}

/// Setup mock GoTrueClient for sign out
void setupSignOut(MockGoTrueClient mockAuth) {
  when(mockAuth.signOut()).thenAnswer((_) async {
    when(mockAuth.currentUser).thenReturn(null);
    when(mockAuth.currentSession).thenReturn(null);
  });
}

// ==================== Google Sign In Helpers ====================

/// Setup successful Google Sign In
void setupSuccessfulGoogleSignIn(
  MockGoogleSignIn mockGoogleSignIn,
  MockGoTrueClient mockAuth, {
  String email = 'test@gmail.com',
  String idToken = 'google-id-token',
}) {
  final mockAccount = MockGoogleSignInAccount();
  when(mockAccount.email).thenReturn(email);

  final mockAuthentication = MockGoogleSignInAuthentication();
  when(mockAuthentication.idToken).thenReturn(idToken);
  when(mockAuthentication.accessToken).thenReturn('google-access-token');

  when(mockAccount.authentication).thenAnswer(
    (_) async => mockAuthentication,
  );

  when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);

  final authResponse = createAuthenticatedAuthResponse(email: email);
  when(mockAuth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: anyNamed('accessToken'),
  )).thenAnswer((_) async => authResponse);
}

/// Setup failed Google Sign In
void setupFailedGoogleSignIn(MockGoogleSignIn mockGoogleSignIn) {
  when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
}

// ==================== Test Data Generators ====================

/// Generate multiple mock users for testing
List<User> generateMockUsers(int count) {
  return List.generate(
    count,
    (index) => createMockUser(
      id: 'user-$index',
      email: 'user$index@example.com',
      metadata: {'name': 'User $index'},
    ),
  );
}

/// Generate mock sessions for testing
List<Session> generateMockSessions(int count) {
  return List.generate(
    count,
    (index) => createMockSession(
      user: createMockUser(id: 'user-$index'),
      accessToken: 'token-$index',
    ),
  );
}

import '../models/user.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class AuthResult {
  const AuthResult({required this.user, required this.token});

  final User user;
  final String token;
}

class AuthService {
  AuthService({
    required ApiClient apiClient,
    required AuthStorage storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  final ApiClient _apiClient;
  final AuthStorage _storage;

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/sign-in/email',
      body: {
        'email': email,
        'password': password,
      },
    ) as Map<String, dynamic>;

    final token = _extractToken(response);
    final user = _extractUser(response);

    await _storage.saveToken(token);
    await _storage.saveUser(user);

    return AuthResult(user: user, token: token);
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/sign-up/email',
      body: {
        'email': email,
        'password': password,
        'name': name,
      },
    ) as Map<String, dynamic>;

    final token = _extractToken(response);
    final user = _extractUser(response);

    await _storage.saveToken(token);
    await _storage.saveUser(user);

    return AuthResult(user: user, token: token);
  }

  Future<User?> getSession() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    try {
      final response = await _apiClient.get('/api/auth/get-session')
          as Map<String, dynamic>;
      if (response.containsKey('user')) {
        final user = User.fromJson(response['user'] as Map<String, dynamic>);
        await _storage.saveUser(user);
        return user;
      }
      return null;
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await _storage.clearAll();
        return null;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _apiClient.post('/api/auth/sign-out');
    } on ApiException {
      // ignore sign-out errors to ensure local session cleared
    } finally {
      await _storage.clearAll();
    }
  }

  Future<User?> loadUserFromCache() async {
    return _storage.readUser();
  }

  String _extractToken(Map<String, dynamic> payload) {
    if (payload['token'] is String) {
      return payload['token'] as String;
    }
    if (payload['token'] is Map<String, dynamic>) {
      final tokenMap = payload['token'] as Map<String, dynamic>;
      final token = tokenMap['token'] ?? tokenMap['value'] ?? tokenMap['accessToken'];
      if (token is String && token.isNotEmpty) {
        return token;
      }
    }
    if (payload['session'] is Map<String, dynamic>) {
      final session = payload['session'] as Map<String, dynamic>;
      final token = session['token'];
      if (token is String && token.isNotEmpty) {
        return token;
      }
    }
    throw ApiException('Unable to extract token from response', body: payload);
  }

  User _extractUser(Map<String, dynamic> payload) {
    final userData = payload['user'];
    if (userData is Map<String, dynamic>) {
      return User.fromJson(userData);
    }
    throw ApiException('Unable to extract user from response', body: payload);
  }
}

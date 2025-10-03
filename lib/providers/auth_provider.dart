import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _hasInitialized = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get hasInitialized => _hasInitialized;

  Future<void> bootstrap() async {
    if (_hasInitialized) return;
    _setLoading(true);
    try {
      _currentUser = await _authService.loadUserFromCache();
      final user = await _authService.getSession();
      if (user != null) {
        _currentUser = user;
      }
      _error = null;
    } catch (error, stackTrace) {
      _error = error.toString();
      debugPrint('AuthProvider bootstrap error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _currentUser = null;
    } finally {
      _hasInitialized = true;
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.signIn(email: email, password: password);
      _currentUser = result.user;
      _error = null;
      return true;
    } on ApiException catch (error, stackTrace) {
      _error = _formatApiError(error);
      debugPrint('AuthProvider signIn error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } catch (error, stackTrace) {
      _error = error.toString();
      debugPrint('AuthProvider signIn error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );
      _currentUser = result.user;
      _error = null;
      return true;
    } on ApiException catch (error, stackTrace) {
      _error = _formatApiError(error);
      debugPrint('AuthProvider signUp error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } catch (error, stackTrace) {
      _error = error.toString();
      debugPrint('AuthProvider signUp error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      _error = null;
    } on ApiException catch (error, stackTrace) {
      _error = _formatApiError(error);
      debugPrint('AuthProvider signOut error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } catch (error, stackTrace) {
      _error = error.toString();
      debugPrint('AuthProvider signOut error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      if (!value) notifyListeners();
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  String _formatApiError(ApiException exception) {
    final body = exception.body;
    if (body is Map<String, dynamic>) {
      final error = body['error'];
      final message = body['message'] ?? body['detail'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return exception.message;
  }
}

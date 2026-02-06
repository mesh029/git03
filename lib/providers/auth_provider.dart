import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../services/api/auth_service.dart';
import '../services/api/api_exceptions.dart';
import '../services/logger_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _hasRestoredSession = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isAgent => _currentUser?.isAgent ?? false;
  bool get hasRestoredSession => _hasRestoredSession;

  AuthProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      // Check if user is authenticated (has valid token)
      final isAuth = await authService.isAuthenticated();
      if (isAuth) {
        // Try to get current user from API
        try {
          final user = await authService.getCurrentUser();
          _currentUser = user;
          // Save email for compatibility
          await LocalStorageService.setCurrentUserEmail(user.email);
        } catch (e) {
          // Token might be expired, clear it
          await authService.logout();
          _currentUser = null;
        }
      }
    } catch (_) {
      // Ignore errors during session restore
      _currentUser = null;
    } finally {
      _hasRestoredSession = true;
      notifyListeners();
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    logger.info('Login attempt started', data: {'email': email}, tag: 'AUTH_PROVIDER');

    try {
      final authResponse = await authService.login(
        email: email,
        password: password,
      );

      _currentUser = authResponse.user;
      await LocalStorageService.setCurrentUserEmail(authResponse.user.email);
      _isLoading = false;
      notifyListeners();
      logger.info('Login successful', data: {'userId': authResponse.user.id, 'email': authResponse.user.email}, tag: 'AUTH_PROVIDER');
      return true;
    } on UnauthorizedException catch (e) {
      _isLoading = false;
      notifyListeners();
      _lastError = 'Invalid email or password';
      logger.error('Login failed - Unauthorized', error: e, data: {'email': email}, tag: 'AUTH_PROVIDER');
      return false;
    } on ValidationException catch (e) {
      _isLoading = false;
      notifyListeners();
      _lastError = e.message;
      logger.error('Login failed - Validation error', error: e, data: {'email': email, 'message': e.message}, tag: 'AUTH_PROVIDER');
      return false;
    } on NetworkException catch (e) {
      _isLoading = false;
      notifyListeners();
      _lastError = 'Network error: ${e.message}\n\nIf using Android emulator, API URL should be http://10.0.2.2:3000\nIf using physical device, use your computer\'s IP address';
      logger.error('Login failed - Network error', error: e, data: {'email': email, 'message': e.message}, tag: 'AUTH_PROVIDER');
      return false;
    } on ApiException catch (e) {
      _isLoading = false;
      notifyListeners();
      _lastError = e.message;
      logger.error('Login failed - API error', error: e, data: {'email': email, 'message': e.message}, tag: 'AUTH_PROVIDER');
      return false;
    } catch (e, stackTrace) {
      _isLoading = false;
      notifyListeners();
      _lastError = 'Login failed: ${e.toString()}';
      logger.error('Login failed - Unexpected error', error: e, stackTrace: stackTrace, data: {'email': email}, tag: 'AUTH_PROVIDER');
      return false;
    }
  }

  String? _lastError;
  String? get lastError => _lastError;

  // Sign up new user
  Future<bool> signUp(String name, String email, String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authResponse = await authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      _currentUser = authResponse.user;
      await LocalStorageService.setCurrentUserEmail(authResponse.user.email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ValidationException {
      // Email already exists or validation error
      _isLoading = false;
      notifyListeners();
      return false;
    } on NetworkException {
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await authService.logout();
    } catch (e) {
      // Ignore logout errors - clear local state anyway
    } finally {
      _currentUser = null;
      await LocalStorageService.setCurrentUserEmail(null);
      _isLoading = false;
      notifyListeners();
    }
  }
}

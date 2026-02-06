import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_exceptions.dart';
import '../api/token_storage.dart';
import '../../models/user_model.dart';
import '../../models/membership_model.dart';
import '../../services/logger_service.dart';

/// Authentication Service
/// Handles all authentication-related API calls
class AuthService {
  final ApiClient _client;

  AuthService({ApiClient? client}) : _client = client ?? apiClient;

  /// Register a new user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiConfig.registerUrl,
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>;
        final tokens = data['tokens'] as Map<String, dynamic>;

        // Save tokens
        await TokenStorage.saveTokens(
          tokens['accessToken'] as String,
          tokens['refreshToken'] as String,
        );

        // Set token in client
        _client.setAccessToken(tokens['accessToken'] as String);

        // Convert API user to app User model
        final user = _userFromApiResponse(userData);

        return AuthResponse(
          user: user,
          accessToken: tokens['accessToken'] as String,
          refreshToken: tokens['refreshToken'] as String,
        );
      } else {
        throw ApiException('Registration failed');
      }
    } on ValidationException catch (e) {
      // Extract validation error message
      String message = e.message;
      if (e.data != null && e.data is Map) {
        final error = (e.data as Map)['error'];
        if (error is Map && error.containsKey('message')) {
          message = error['message'] as String;
        }
      }
      throw ValidationException(message, data: e.data, code: e.code);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Registration failed: ${e.toString()}');
    }
  }

  /// Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    logger.info('🔐 Attempting login', data: {
      'email': email,
      'url': ApiConfig.loginUrl,
      'baseUrl': ApiConfig.baseUrl,
    }, tag: 'AUTH');
    
    try {
      logger.debug('📤 Sending login request', data: {
        'url': ApiConfig.loginUrl,
        'email': email,
      }, tag: 'AUTH');
      
      final response = await _client.post(
        ApiConfig.loginUrl,
        body: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      logger.debug('📥 Login response received', data: {
        'success': response['success'],
        'hasData': response.containsKey('data'),
        'hasUser': response['data'] != null && (response['data'] as Map).containsKey('user'),
        'hasTokens': response['data'] != null && (response['data'] as Map).containsKey('tokens'),
      }, tag: 'AUTH');

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>;
        final tokens = data['tokens'] as Map<String, dynamic>;

        // Save tokens
        await TokenStorage.saveTokens(
          tokens['accessToken'] as String,
          tokens['refreshToken'] as String,
        );

        // Set token in client
        _client.setAccessToken(tokens['accessToken'] as String);

        // Convert API user to app User model
        final user = _userFromApiResponse(userData);

        logger.info('Login successful', data: {
          'userId': user.id,
          'email': user.email,
        }, tag: 'AUTH');

        return AuthResponse(
          user: user,
          accessToken: tokens['accessToken'] as String,
          refreshToken: tokens['refreshToken'] as String,
        );
      } else {
        logger.warning('Login failed - success=false', data: {'response': response}, tag: 'AUTH');
        throw ApiException('Login failed');
      }
    } on UnauthorizedException catch (e) {
      logger.error('❌ Login failed - Unauthorized', error: e, data: {
        'email': email,
        'url': ApiConfig.loginUrl,
        'baseUrl': ApiConfig.baseUrl,
      }, tag: 'AUTH');
      throw UnauthorizedException('Invalid email or password');
    } on ValidationException catch (e) {
      String message = e.message;
      if (e.data != null && e.data is Map) {
        final error = (e.data as Map)['error'];
        if (error is Map && error.containsKey('message')) {
          message = error['message'] as String;
        }
      }
      logger.error('❌ Login failed - Validation error', error: e, data: {
        'email': email,
        'message': message,
        'url': ApiConfig.loginUrl,
        'baseUrl': ApiConfig.baseUrl,
      }, tag: 'AUTH');
      throw ValidationException(message, data: e.data, code: e.code);
    } on NetworkException catch (e) {
      logger.error('❌ Login failed - Network error', error: e, data: {
        'email': email,
        'url': ApiConfig.loginUrl,
        'baseUrl': ApiConfig.baseUrl,
        'hint': 'If using Android emulator, change ApiConfig.baseUrl to http://10.0.2.2:3000',
      }, tag: 'AUTH');
      rethrow;
    } on ApiException catch (e) {
      logger.error('❌ Login failed - API error', error: e, data: {
        'email': email,
        'url': ApiConfig.loginUrl,
        'baseUrl': ApiConfig.baseUrl,
      }, tag: 'AUTH');
      rethrow;
    } catch (e, stackTrace) {
      logger.error('❌ Login failed - Unexpected error', error: e, stackTrace: stackTrace, data: {
        'email': email,
        'url': ApiConfig.loginUrl,
        'baseUrl': ApiConfig.baseUrl,
      }, tag: 'AUTH');
      throw ApiException('Login failed: ${e.toString()}');
    }
  }

  /// Refresh access token
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _client.post(
        ApiConfig.refreshTokenUrl,
        body: {
          'refreshToken': refreshToken,
        },
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String;

        // Save new tokens
        await TokenStorage.saveTokens(accessToken, newRefreshToken);
        _client.setAccessToken(accessToken);

        return accessToken;
      } else {
        throw ApiException('Token refresh failed');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Token refresh failed: ${e.toString()}');
    }
  }

  /// Get current user
  Future<User> getCurrentUser() async {
    try {
      // Load token if not already loaded
      await _client.loadAccessToken();

      final response = await _client.get(ApiConfig.meUrl);

      if (response['success'] == true) {
        final userData = response['data'] as Map<String, dynamic>;
        return _userFromApiResponse(userData);
      } else {
        throw ApiException('Failed to get user');
      }
    } on UnauthorizedException {
      // Token expired or invalid
      await logout();
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to get user: ${e.toString()}');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Try to call logout endpoint (optional, may fail if token is invalid)
      try {
        await _client.post(ApiConfig.logoutUrl);
      } catch (e) {
        // Ignore errors - we'll clear tokens anyway
      }
    } finally {
      // Always clear tokens and client state
      await TokenStorage.clearTokens();
      _client.clearAccessToken();
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await TokenStorage.isAuthenticated();
  }

  /// Convert API user response to app User model
  User _userFromApiResponse(Map<String, dynamic> userData) {
    // API returns: id, email, name, phone, is_admin, is_agent, created_at, updated_at
    // App expects: id, name, email, phone, membership, createdAt, isAdmin, isAgent
    
    // Create default freemium membership (API doesn't return membership yet)
    final membership = Membership(
      type: MembershipType.freemium,
      subscriptions: [],
    );

    return User(
      id: userData['id'] as String,
      name: userData['name'] as String,
      email: userData['email'] as String,
      phone: userData['phone'] as String? ?? '',
      membership: membership,
      createdAt: DateTime.parse(userData['created_at'] as String),
      isAdmin: userData['is_admin'] as bool? ?? false,
      isAgent: userData['is_agent'] as bool? ?? false,
    );
  }
}

/// Authentication response
class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}

/// Singleton instance
final authService = AuthService();

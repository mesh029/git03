import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_exceptions.dart';
import 'token_storage.dart';
import '../../services/logger_service.dart';

/// API Client
/// Handles all HTTP requests to the API
class ApiClient {
  final http.Client _client;
  String? _accessToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Set access token for authenticated requests
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// Clear access token
  void clearAccessToken() {
    _accessToken = null;
  }

  /// Get current access token
  String? get accessToken => _accessToken;

  /// Load access token from storage
  Future<void> loadAccessToken() async {
    _accessToken = await TokenStorage.getAccessToken();
  }

  /// Build headers for requests
  Map<String, String> _buildHeaders({Map<String, String>? additionalHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add authorization header if token exists
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    // Add any additional headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Parse response body
  Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      if (response.body.isEmpty) {
        return {};
      }
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    } catch (e) {
      // Return error object instead of throwing for error responses
      return {'error': {'message': 'Failed to parse response: ${e.toString()}'}};
    }
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    // Log request (but don't log the log request itself to avoid recursion)
    if (!endpoint.contains('/logs/ui')) {
      logger.debug('GET Request', data: {
        'url': endpoint,
        'query': queryParameters,
      }, tag: 'API');
    }
    
    try {
      // Build URL with query parameters
      Uri uri = Uri.parse(endpoint);
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      // Make request
      final response = await _client
          .get(
            uri,
            headers: _buildHeaders(additionalHeaders: headers),
          )
          .timeout(ApiConfig.timeout);

      // Parse response
      final responseData = _parseResponse(response);

      // Log response (but don't log the log response itself to avoid recursion)
      if (!endpoint.contains('/logs/ui')) {
        logger.debug('GET Response', data: {
          'url': endpoint,
          'statusCode': response.statusCode,
        }, tag: 'API');
      }

      // Handle errors
      if (response.statusCode >= 400) {
        throw ApiException.fromResponse(response.statusCode, responseData);
      }

      // Return parsed response
      return responseData;
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error: ${e.message}\n\nIf using Android emulator, change ApiConfig.baseUrl to http://10.0.2.2:3000\nIf using physical device, use your computer\'s IP address';
      throw ApiException.networkError(errorMsg);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
        throw TimeoutException('Request timed out. Check if API is running at ${ApiConfig.baseUrl}');
      }
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse(endpoint);
    final requestBody = body != null ? jsonEncode(body) : null;
    
    // Log request (but don't log the log request itself to avoid recursion)
    if (!endpoint.contains('/logs/ui')) {
      logger.debug('POST Request', data: {
        'url': endpoint,
        'body': body != null ? (body.containsKey('password') ? {...body, 'password': '***'} : body) : null,
      }, tag: 'API');
    }
    
    try {
      final response = await _client
          .post(
            url,
            headers: _buildHeaders(additionalHeaders: headers),
            body: requestBody,
          )
          .timeout(ApiConfig.timeout);

      // Log response (but don't log the log response itself to avoid recursion)
      if (!endpoint.contains('/logs/ui')) {
        logger.debug('POST Response', data: {
          'url': endpoint,
          'statusCode': response.statusCode,
          'body': response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body,
        }, tag: 'API');
      }

      // Parse response
      final responseData = _parseResponse(response);

      // Handle errors
      if (response.statusCode >= 400) {
        final errorMsg = responseData['error']?['message'] ?? responseData['message'] ?? 'Request failed';
        logger.error('POST Request failed', error: errorMsg, data: {
          'url': endpoint,
          'statusCode': response.statusCode,
          'response': responseData,
        }, tag: 'API');
        throw ApiException.fromResponse(response.statusCode, responseData);
      }

      // Return parsed response
      return responseData;
    } on http.ClientException catch (e) {
      final errorMsg = 'Network error: ${e.message}\n\n'
          'Possible fixes:\n'
          '- Check if API is running at ${ApiConfig.baseUrl}\n'
          '- For Android emulator: use http://10.0.2.2:3000\n'
          '- For Flutter web: ensure CORS is configured\n'
          '- Check browser console (F12) for CORS errors';
      logger.error('POST Network error', error: errorMsg, data: {
        'url': endpoint,
        'baseUrl': ApiConfig.baseUrl,
        'originalError': e.toString(),
      }, tag: 'API');
      throw ApiException.networkError(errorMsg);
    } on ApiException catch (e) {
      logger.error('POST API error', error: e, data: {'url': endpoint}, tag: 'API');
      rethrow;
    } catch (e, stackTrace) {
      logger.error('POST Unexpected error', error: e, stackTrace: stackTrace, data: {'url': endpoint}, tag: 'API');
      if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
        throw TimeoutException('Request timed out. Check if API is running at ${ApiConfig.baseUrl}');
      }
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  /// PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .patch(
            Uri.parse(endpoint),
            headers: _buildHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      // Parse response
      final responseData = _parseResponse(response);

      // Handle errors
      if (response.statusCode >= 400) {
        throw ApiException.fromResponse(response.statusCode, responseData);
      }

      // Return parsed response
      return responseData;
    } on http.ClientException catch (e) {
      throw ApiException.networkError('Network error: ${e.message}');
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw TimeoutException('Request timed out');
      }
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  /// DELETE request
  Future<void> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(endpoint),
            headers: _buildHeaders(additionalHeaders: headers),
          )
          .timeout(ApiConfig.timeout);

      // Handle errors
      if (response.statusCode >= 400) {
        final responseData = await _parseResponse(response);
        throw ApiException.fromResponse(response.statusCode, responseData);
      }
    } on http.ClientException catch (e) {
      throw ApiException.networkError('Network error: ${e.message}');
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw TimeoutException('Request timed out');
      }
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse(ApiConfig.healthCheckUrl))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Close client (cleanup)
  void close() {
    _client.close();
  }
}

/// Singleton instance of ApiClient
final apiClient = ApiClient();

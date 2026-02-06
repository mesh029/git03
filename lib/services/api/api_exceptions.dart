/// API Exception classes for error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final String? code;

  ApiException(
    this.message, {
    this.statusCode,
    this.data,
    this.code,
  });

  /// Create ApiException from HTTP response
  factory ApiException.fromResponse(int statusCode, dynamic responseData) {
    String message = 'An error occurred';
    String? code;

    if (responseData is Map<String, dynamic>) {
      // Try to extract error message from API response
      if (responseData.containsKey('error')) {
        final error = responseData['error'];
        if (error is Map<String, dynamic>) {
          message = error['message'] ?? message;
          code = error['code'];
        } else if (error is String) {
          message = error;
        }
      } else if (responseData.containsKey('message')) {
        message = responseData['message'] as String;
      }
    }

    // Map status codes to specific exceptions
    switch (statusCode) {
      case 400:
        return BadRequestException(message, data: responseData, code: code);
      case 401:
        return UnauthorizedException(message, data: responseData, code: code);
      case 403:
        return ForbiddenException(message, data: responseData, code: code);
      case 404:
        return NotFoundException(message, data: responseData, code: code);
      case 422:
        return ValidationException(message, data: responseData, code: code);
      case 429:
        return RateLimitException(message, data: responseData, code: code);
      case 500:
      case 502:
      case 503:
        return ServerException(message, data: responseData, code: code);
      default:
        return ApiException(message, statusCode: statusCode, data: responseData, code: code);
    }
  }

  /// Create ApiException from network error
  factory ApiException.networkError(String message) {
    return NetworkException(message);
  }

  @override
  String toString() => message;
}

/// Bad Request (400)
class BadRequestException extends ApiException {
  BadRequestException(String message, {dynamic data, String? code})
      : super(message, statusCode: 400, data: data, code: code);
}

/// Unauthorized (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException(String message, {dynamic data, String? code})
      : super(message, statusCode: 401, data: data, code: code);
}

/// Forbidden (403)
class ForbiddenException extends ApiException {
  ForbiddenException(String message, {dynamic data, String? code})
      : super(message, statusCode: 403, data: data, code: code);
}

/// Not Found (404)
class NotFoundException extends ApiException {
  NotFoundException(String message, {dynamic data, String? code})
      : super(message, statusCode: 404, data: data, code: code);
}

/// Validation Error (422)
class ValidationException extends ApiException {
  ValidationException(String message, {dynamic data, String? code})
      : super(message, statusCode: 422, data: data, code: code);
}

/// Rate Limit (429)
class RateLimitException extends ApiException {
  RateLimitException(String message, {dynamic data, String? code})
      : super(message, statusCode: 429, data: data, code: code);
}

/// Server Error (500+)
class ServerException extends ApiException {
  ServerException(String message, {dynamic data, String? code})
      : super(message, statusCode: 500, data: data, code: code);
}

/// Network Error (no connection, timeout, etc.)
class NetworkException extends ApiException {
  NetworkException(String message)
      : super(message, statusCode: null, data: null, code: 'NETWORK_ERROR');
}

/// Timeout Error
class TimeoutException extends ApiException {
  TimeoutException(String message)
      : super(message, statusCode: null, data: null, code: 'TIMEOUT');
}

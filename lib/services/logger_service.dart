import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'api/api_client.dart' as api;
import 'api/api_config.dart';

/// Log levels
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Logger Service
/// Sends logs to API which stores them in ui.log using Winston (separate from API logs)
/// View UI logs at: http://localhost:3000/v1/logs/ui/viewer
/// View API logs at: http://localhost:3000/v1/logs/viewer
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  final api.ApiClient _apiClient = api.apiClient;
  bool _isSendingLog = false;

  /// Send log to API (async, non-blocking)
  void _sendToApi(LogLevel level, String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? data, String? tag}) {
    // Always log to console FIRST (so we see it even if API fails)
    final logName = tag ?? level.toString().toUpperCase();
    final logData = <String, dynamic>{
      if (data != null) ...data,
      if (error != null) 'error': error.toString(),
    };
    developer.log(message, name: logName, error: logData.isEmpty ? null : logData, stackTrace: stackTrace);

    // Don't send if already sending (avoid recursion/infinite loops)
    if (_isSendingLog) {
      developer.log('Skipping log send - already sending', name: 'LOGGER');
      return;
    }
    
    // Send to API in background (fire and forget - don't await to avoid blocking)
    _isSendingLog = true;
    Future.microtask(() async {
      try {
        await _apiClient.post(
          ApiConfig.uiLogsUrl,
          body: {
            'level': level.toString().split('.').last,
            'message': message,
            if (tag != null) 'tag': tag,
            if (data != null) 'data': data,
            if (error != null) 'error': error.toString(),
            if (stackTrace != null) 'stackTrace': stackTrace.toString(),
          },
        ).timeout(const Duration(seconds: 2));
      } catch (e) {
        // Log the failure - this is important for debugging
        developer.log('❌ Failed to send log to API: $e', name: 'LOGGER', error: {
          'error': e.toString(),
          'url': ApiConfig.uiLogsUrl,
          'baseUrl': ApiConfig.baseUrl,
          'hint': 'If using Android emulator, change ApiConfig.baseUrl to http://10.0.2.2:3000',
        });
      } finally {
        _isSendingLog = false;
      }
    });
  }

  /// Log debug message
  void debug(String message, {Map<String, dynamic>? data, String? tag}) {
    _sendToApi(LogLevel.debug, message, data: data, tag: tag);
  }

  /// Log info message
  void info(String message, {Map<String, dynamic>? data, String? tag}) {
    _sendToApi(LogLevel.info, message, data: data, tag: tag);
  }

  /// Log warning message
  void warning(String message, {Map<String, dynamic>? data, String? tag}) {
    _sendToApi(LogLevel.warning, message, data: data, tag: tag);
  }

  /// Log error message
  void error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? data, String? tag}) {
    _sendToApi(LogLevel.error, message, error: error, stackTrace: stackTrace, data: data, tag: tag);
  }
}

/// Global logger instance
final logger = LoggerService();

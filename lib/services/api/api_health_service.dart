import 'api_client.dart';
import 'api_config.dart';
import '../logger_service.dart';

/// API Health Service
/// Tests API connectivity and logs results
class ApiHealthService {
  final ApiClient _client;

  ApiHealthService({ApiClient? client}) : _client = client ?? apiClient;

  /// Test API connectivity
  Future<Map<String, dynamic>> testConnection() async {
    logger.info('Testing API connection', data: {'url': ApiConfig.baseUrl}, tag: 'API_HEALTH');
    
    try {
      final response = await _client.get(ApiConfig.healthCheckUrl);
      
      logger.info('API health check successful', data: {
        'url': ApiConfig.healthCheckUrl,
        'response': response,
      }, tag: 'API_HEALTH');
      
      return {
        'success': true,
        'message': 'API is reachable',
        'data': response,
      };
    } catch (e, stackTrace) {
      logger.error('API health check failed', error: e, stackTrace: stackTrace, data: {
        'url': ApiConfig.healthCheckUrl,
        'baseUrl': ApiConfig.baseUrl,
      }, tag: 'API_HEALTH');
      
      return {
        'success': false,
        'message': 'API is not reachable',
        'error': e.toString(),
        'suggestion': _getSuggestion(),
      };
    }
  }

  String _getSuggestion() {
    final baseUrl = ApiConfig.baseUrl;
    
    if (baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1')) {
      return 'If running on Android emulator, use http://10.0.2.2:3000\n'
          'If running on physical device, use your computer\'s IP address\n'
          'Current URL: $baseUrl';
    }
    
    return 'Check if the API server is running and accessible';
  }
}

final apiHealthService = ApiHealthService();

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../exceptions/index.dart';
import '../models/index.dart';
import '../utils/piprapay_utils.dart';

/// HTTP client for Piprapay API requests
class PiprapayHttpClient {
  final String apiKey;
  final String baseUrl;
  final PanelVersion panelVersion;
  final Duration timeout;
  final bool enableLogging;
  late http.Client _httpClient;

  static const String _defaultSandboxUrl = 'https://sandbox.piprapay.com/api';
  static const Duration _defaultTimeout = Duration(seconds: 30);
  
  // API Key headers for different versions
  static const String _apiKeyHeaderV2 = 'mh-piprapay-api-key'; // V2 (lowercase)
  static const String _apiKeyHeaderV3 = 'MHS-PIPRAPAY-API-KEY'; // V3+ (uppercase)

  PiprapayHttpClient({
    required this.apiKey,
    required this.panelVersion,
    String? baseUrl,
    Duration? timeout,
    this.enableLogging = false,
    http.Client? httpClient,
  })  : baseUrl = baseUrl ?? _defaultSandboxUrl,
        timeout = timeout ?? _defaultTimeout {
    _httpClient = httpClient ?? http.Client();

    if (!PiprapayUtils.isValidApiKey(apiKey)) {
      throw PiprapayConfigException(
        message: 'Invalid API key format',
      );
    }

    if (enableLogging) {
      _logInit();
    }
  }

  /// Get appropriate API key header based on panel version
  String get _apiKeyHeader {
    return panelVersion.isV3Plus ? _apiKeyHeaderV3 : _apiKeyHeaderV2;
  }

  /// Get headers for API requests
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      _apiKeyHeader: apiKey,
    };
  }

  /// Log initialization
  void _logInit() {
    print('\n${'=' * 80}');
    print('📦 PIPRAPAY SDK INITIALIZED');
    print('${'=' * 80}');
    print('🌐 Base URL: $baseUrl');
    print('🔑 API Key: ${_maskApiKey(apiKey)}');
    print('⏱️  Timeout: ${timeout.inSeconds}s');
    print('📊 Logging: ENABLED');
    print('${'=' * 80}\n');
  }

  /// Log request
  void _logRequest(String method, String url, Map<String, dynamic>? body, [String? rawBody]) {
    if (!enableLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    print('\n${'─' * 80}');
    print('📤 OUTGOING REQUEST');
    print('${'─' * 80}');
    print('🕐 Timestamp: $timestamp');
    print('🔹 Method: $method');
    print('🔹 URL: $url');
    if (body != null && body.isNotEmpty) {
      print('🔹 Request Body (Decoded):');
      _printJson(body);
    }
    if (rawBody != null) {
      print('🔹 Raw JSON Sent:');
      print('   $rawBody');
    }
    print('${'─' * 80}');
  }

  /// Log response
  void _logResponse(String method, String url, int statusCode, String responseBody) {
    if (!enableLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    final statusEmoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    
    print('\n${'─' * 80}');
    print('📥 INCOMING RESPONSE');
    print('${'─' * 80}');
    print('🕐 Timestamp: $timestamp');
    print('🔹 Method: $method');
    print('🔹 URL: $url');
    print('$statusEmoji Status Code: $statusCode');
    print('🔹 Response Body:');
    try {
      final decoded = jsonDecode(responseBody);
      _printJson(decoded);
    } catch (e) {
      print('   $responseBody');
    }
    print('${'─' * 80}\n');
  }

  /// Log error
  void _logError(String method, String url, dynamic error) {
    if (!enableLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    print('\n${'─' * 80}');
    print('❌ REQUEST ERROR');
    print('${'─' * 80}');
    print('🕐 Timestamp: $timestamp');
    print('🔹 Method: $method');
    print('🔹 URL: $url');
    print('🔹 Error: $error');
    print('${'─' * 80}\n');
  }

  /// Print JSON with indentation
  void _printJson(dynamic json) {
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(json);
    final lines = prettyJson.split('\n');
    for (var line in lines) {
      print('   $line');
    }
  }

  /// Mask API key for logging
  String _maskApiKey(String key) {
    if (key.length <= 8) return '********';
    final start = key.substring(0, 4);
    final end = key.substring(key.length - 4);
    return '$start${'*' * (key.length - 8)}$end';
  }

  /// Make a POST request to the API
  Future<T> post<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic>) fromJson,
    bool includeApiKey = true,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = includeApiKey ? _getHeaders() : _getJsonHeaders();

    final rawBody = jsonEncode(body);
    _logRequest('POST', url.toString(), body, rawBody);

    try {
      final response = await _httpClient
          .post(
            url,
            headers: headers,
            body: rawBody,
          )
          .timeout(timeout);

      _logResponse('POST', url.toString(), response.statusCode, response.body);
      return _handleResponse(response, fromJson);
    } on TimeoutException catch (_) {
      _logError('POST', url.toString(), 'Timeout after ${timeout.inSeconds}s');
      throw PiprapayNetworkException(
        message: 'Request timeout after ${timeout.inSeconds} seconds',
      );
    } catch (e, stackTrace) {
      if (e is! PiprapayException) {
        _logError('POST', url.toString(), e);
      }
      if (e is PiprapayException) {
        rethrow;
      }
      throw PiprapayNetworkException(
        message: 'Network error: $e',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Make a GET request to the API
  Future<T> get<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? queryParameters,
  }) async {
    var url = Uri.parse('$baseUrl/$endpoint');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      url = url.replace(queryParameters: queryParameters);
    }

    _logRequest('GET', url.toString(), null);

    try {
      final response = await _httpClient
          .get(url, headers: _getHeaders())
          .timeout(timeout);

      _logResponse('GET', url.toString(), response.statusCode, response.body);
      return _handleResponse(response, fromJson);
    } on TimeoutException {
      _logError('GET', url.toString(), 'Timeout after ${timeout.inSeconds}s');
      throw PiprapayNetworkException(
        message: 'Request timeout after ${timeout.inSeconds} seconds',
      );
    } catch (e, stackTrace) {
      if (e is! PiprapayException) {
        _logError('GET', url.toString(), e);
      }
      if (e is PiprapayException) {
        rethrow;
      }
      throw PiprapayNetworkException(
        message: 'Network error: $e',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle HTTP response and parse it
  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      // Check for authentication error
      if (response.statusCode == 401) {
        throw PiprapayAuthException(
          message: responseBody['message'] ?? 'Unauthorized: Invalid API key',
        );
      }

      // Check for bad request
      if (response.statusCode == 400 || response.statusCode == 422) {
        throw PiprapayRequestException(
          message:
              responseBody['message'] ?? 'Invalid request parameters',
          statusCode: response.statusCode,
          responseBody: responseBody,
        );
      }

      // Check for server error
      if (response.statusCode >= 500) {
        throw PiprapayRequestException(
          message: 'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: responseBody,
        );
      }

      // Success response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return fromJson(responseBody);
      }

      // Other error codes
      throw PiprapayRequestException(
        message:
            responseBody['message'] ??
            'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
        responseBody: responseBody,
      );
    } on PiprapayException {
      rethrow;
    } catch (e, stackTrace) {
      throw PiprapayException(
        message: 'Failed to parse response: $e',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get JSON headers without API key
  Map<String, String> _getJsonHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Dispose the HTTP client
  void dispose() {
    _httpClient.close();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../exceptions/index.dart';
import '../models/index.dart';
import 'http_client.dart';
import '../utils/piprapay_utils.dart';

/// Main service class for Piprapay API integration
/// Supports both V2 and V3+ API versions
class PiprapayService {
  late final PiprapayHttpClient _httpClient;
  final String apiKey;
  final String baseUrl;
  final bool isSandbox;
  final PanelVersion panelVersion;
  final bool enableLogging;
  final Duration? timeout;

  /// Default URLs
  static const String sandboxUrl = 'https://sandbox.piprapay.com/api';
  static const String productionUrl = 'https://api.domain.com/api';

  /// Create PiprapayService instance
  /// 
  /// Parameters:
  /// - [apiKey] - Your Piprapay API key
  /// - [isSandbox] - true for sandbox, false for production
  /// - [baseUrl] - Required when isSandbox is false (production)
  /// - [panelVersion] - API version (v2 or v3+, defaults to v3+)
  /// - [enableLogging] - Enable detailed request/response logging
  /// - [timeout] - Request timeout duration
  /// - [httpClient] - Custom HTTP client for testing
  PiprapayService({
    required this.apiKey,
    required this.isSandbox,
    String? baseUrl,
    this.panelVersion = PanelVersion.v3plus,
    this.enableLogging = false,
    Duration? timeout,
    http.Client? httpClient,
  })  : baseUrl = _resolveBaseUrl(isSandbox, baseUrl),
        timeout = timeout {
    _httpClient = PiprapayHttpClient(
      apiKey: apiKey,
      baseUrl: this.baseUrl,
      panelVersion: panelVersion,
      enableLogging: enableLogging,
      timeout: timeout,
      httpClient: httpClient,
    );
  }

  /// Resolve base URL based on sandbox mode
  static String _resolveBaseUrl(bool isSandbox, String? baseUrl) {
    if (isSandbox) {
      return sandboxUrl;
    } else {
      if (baseUrl == null || baseUrl.isEmpty) {
        throw PiprapayConfigException(
          message: 'Base URL is required when not in sandbox mode (isSandbox: false)',
        );
      }
      return baseUrl;
    }
  }

  /// Initialize with production environment and V3+ API
  factory PiprapayService.production({
    required String apiKey,
    required String baseUrl,
    PanelVersion panelVersion = PanelVersion.v3plus,
    bool enableLogging = false,
    Duration? timeout,
    http.Client? httpClient,
  }) {
    return PiprapayService(
      apiKey: apiKey,
      isSandbox: false,
      baseUrl: baseUrl,
      panelVersion: panelVersion,
      enableLogging: enableLogging,
      timeout: timeout,
      httpClient: httpClient,
    );
  }

  /// Initialize with sandbox environment
  factory PiprapayService.sandbox({
    required String apiKey,
    PanelVersion panelVersion = PanelVersion.v3plus,
    bool enableLogging = false,
    Duration? timeout,
    http.Client? httpClient,
  }) {
    return PiprapayService(
      apiKey: apiKey,
      isSandbox: true,
      panelVersion: panelVersion,
      enableLogging: enableLogging,
      timeout: timeout,
      httpClient: httpClient,
    );
  }

  /// Create a charge/payment (supports both V2 and V3+)
  /// 
  /// For V3+: requires [fullName], [emailAddress], [mobileNumber], [amount], [currency], [metadata], [returnUrl], [webhookUrl]
  /// For V2: requires [fullName], [emailOrMobile], [amount], [metadata], [redirectUrl], [cancelUrl], [webhookUrl]
  Future<dynamic> createCharge({
    // V3+ parameters
    String? fullName,
    String? emailAddress,
    String? mobileNumber,
    String? amount,
    String? currency,
    Map<String, dynamic>? metadata,
    String? returnUrl,
    String? webhookUrl,
    // V2 parameters
    String? emailOrMobile,
    String? redirectUrl,
    String? cancelUrl,
    String? returnType,
    String? orderId,
  }) async {
    try {
      if (panelVersion.isV3Plus) {
        return await _createChargeV3(
          fullName: fullName ?? '',
          emailAddress: emailAddress ?? '',
          mobileNumber: mobileNumber ?? '',
          amount: amount ?? '',
          currency: currency ?? 'BDT',
          metadata: metadata ?? {},
          returnUrl: returnUrl ?? '',
          webhookUrl: webhookUrl ?? '',
        );
      } else {
        return await _createChargeV2(
          fullName: fullName ?? '',
          emailOrMobile: emailOrMobile ?? '',
          amount: amount ?? '',
          metadata: metadata ?? {},
          redirectUrl: redirectUrl ?? '',
          cancelUrl: cancelUrl ?? '',
          webhookUrl: webhookUrl ?? '',
          returnType: returnType ?? 'POST',
          currency: currency ?? 'BDT',
          orderId: orderId,
        );
      }
    } catch (e) {
      if (e is PiprapayException) rethrow;
      throw PiprapayPaymentException(
        message: 'Failed to create charge: $e',
        originalException: e,
      );
    }
  }

  /// Create charge for V3+ API
  Future<CreateChargeResponseV3> _createChargeV3({
    required String fullName,
    required String emailAddress,
    required String mobileNumber,
    required String amount,
    required String currency,
    required Map<String, dynamic> metadata,
    required String returnUrl,
    required String webhookUrl,
  }) async {
    _validate('fullName', fullName);
    _validate('emailAddress', emailAddress);
    _validate('mobileNumber', mobileNumber);
    _validate('amount', amount);
    _validate('returnUrl', returnUrl);
    _validate('webhookUrl', webhookUrl);

    if (!PiprapayUtils.isValidEmail(emailAddress)) {
      throw PiprapayRequestException(
        message: 'Email address is invalid',
        statusCode: 400,
      );
    }

    final request = CreateChargeRequestV3(
      fullName: fullName,
      emailAddress: emailAddress,
      mobileNumber: mobileNumber,
      amount: amount,
      currency: currency,
      metadata: metadata,
      returnUrl: returnUrl,
      webhookUrl: webhookUrl,
    );

    return await _httpClient.post<CreateChargeResponseV3>(
      endpoint: 'checkout/redirect',
      body: request.toJson(),
      fromJson: CreateChargeResponseV3.fromJson,
    );
  }

  /// Create charge for V2 API (legacy)
  Future<CreateChargeResponseV2> _createChargeV2({
    required String fullName,
    required String emailOrMobile,
    required String amount,
    required Map<String, dynamic> metadata,
    required String redirectUrl,
    required String cancelUrl,
    required String webhookUrl,
    required String returnType,
    required String currency,
    String? orderId,
  }) async {
    _validate('fullName', fullName);
    _validate('emailOrMobile', emailOrMobile);
    _validate('amount', amount);
    _validate('redirectUrl', redirectUrl);

    if (!PiprapayUtils.isValidEmailOrMobile(emailOrMobile)) {
      throw PiprapayRequestException(
        message: 'Email or mobile number is invalid',
        statusCode: 400,
      );
    }

    final request = CreateChargeRequestV2(
      fullName: fullName,
      emailOrMobile: emailOrMobile,
      amount: amount,
      metadata: metadata,
      redirectUrl: redirectUrl,
      returnType: returnType,
      cancelUrl: cancelUrl,
      webhookUrl: webhookUrl,
      currency: currency,
      orderId: orderId,
    );

    return await _httpClient.post<CreateChargeResponseV2>(
      endpoint: 'create-charge',
      body: request.toJson(),
      fromJson: CreateChargeResponseV2.fromJson,
    );
  }

  /// Verify a payment (supports both V2 and V3+)
  /// 
  /// For V3+: uses [ppId] parameter
  /// For V2: uses [transactionId] parameter
  Future<dynamic> verifyPayment({
    String? ppId,
    String? transactionId,
  }) async {
    try {
      if (panelVersion.isV3Plus) {
        return await _verifyPaymentV3(ppId: ppId ?? '');
      } else {
        return await _verifyPaymentV2(transactionId: transactionId ?? '');
      }
    } catch (e) {
      if (e is PiprapayException) rethrow;
      throw PiprapayPaymentException(
        message: 'Failed to verify payment',
        transactionId: transactionId ?? ppId,
        originalException: e,
      );
    }
  }

  /// Verify payment for V3+ API
  Future<VerifyPaymentResponseV3> _verifyPaymentV3({
    required String ppId,
  }) async {
    _validate('ppId', ppId);

    final body = {
      'pp_id': ppId,
    };

    return await _httpClient.post<VerifyPaymentResponseV3>(
      endpoint: 'verify-payment',
      body: body,
      fromJson: VerifyPaymentResponseV3.fromJson,
    );
  }

  /// Verify payment for V2 API (legacy)
  Future<VerifyPaymentResponseV2> _verifyPaymentV2({
    required String transactionId,
  }) async {
    _validate('transactionId', transactionId);

    final body = {
      'transaction_id': transactionId,
    };

    return await _httpClient.post<VerifyPaymentResponseV2>(
      endpoint: 'verify-payment',
      body: body,
      fromJson: VerifyPaymentResponseV2.fromJson,
    );
  }

  /// Refund a payment (supports both V2 and V3+)
  /// 
  /// For V3+: uses [ppId] parameter
  /// For V2: uses [transactionId] parameter
  Future<dynamic> refundPayment({
    String? ppId,
    String? transactionId,
  }) async {
    try {
      if (panelVersion.isV3Plus) {
        return await _refundPaymentV3(ppId: ppId ?? '');
      } else {
        return await _refundPaymentV2(transactionId: transactionId ?? '');
      }
    } catch (e) {
      if (e is PiprapayException) rethrow;
      throw PiprapayPaymentException(
        message: 'Failed to refund payment',
        transactionId: transactionId ?? ppId,
        originalException: e,
      );
    }
  }

  /// Refund payment for V3+ API
  Future<RefundPaymentResponseV3> _refundPaymentV3({
    required String ppId,
  }) async {
    _validate('ppId', ppId);

    final body = {
      'pp_id': ppId,
    };

    return await _httpClient.post<RefundPaymentResponseV3>(
      endpoint: 'refund-payment',
      body: body,
      fromJson: RefundPaymentResponseV3.fromJson,
    );
  }

  /// Refund payment for V2 API (legacy)
  Future<dynamic> _refundPaymentV2({
    required String transactionId,
  }) async {
    _validate('transactionId', transactionId);

    final body = {
      'transaction_id': transactionId,
    };

    return await _httpClient.post<dynamic>(
      endpoint: 'refund-payment',
      body: body,
      fromJson: (json) => json,
    );
  }

  /// Validate and parse webhook payload (supports both V2 and V3+)
  Future<dynamic> validateWebhook({
    required String payload,
    required String receivedApiKey,
  }) async {
    try {
      if (!PiprapayUtils.validateWebhookApiKey(
        receivedApiKey: receivedApiKey,
        expectedApiKey: apiKey,
      )) {
        throw PiprapayWebhookException(
          message: 'Webhook validation failed: Invalid API key',
        );
      }

      final Map<String, dynamic> jsonPayload = jsonDecode(payload);
      
      if (panelVersion.isV3Plus) {
        return WebhookPayloadV3.fromJson(jsonPayload);
      } else {
        return WebhookPayload.fromJson(jsonPayload);
      }
    } on PiprapayException {
      rethrow;
    } catch (e, stackTrace) {
      throw PiprapayWebhookException(
        message: 'Failed to validate webhook: $e',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Parse webhook payload to appropriate type (supports both V2 and V3+)
  dynamic parseWebhookPayload(Map<String, dynamic> jsonData) {
    try {
      if (panelVersion.isV3Plus) {
        return WebhookPayloadV3.fromJson(jsonData);
      } else {
        return WebhookPayload.fromJson(jsonData);
      }
    } catch (e, stackTrace) {
      throw PiprapayWebhookException(
        message: 'Failed to parse webhook payload: $e',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Extract checkout/payment URL from create-charge response (V2/V3+)
  String? extractCheckoutUrl(dynamic createResponse) {
    if (createResponse is CreateChargeResponseV3) {
      final url = createResponse.paymentUrl.trim();
      return url.isEmpty ? null : url;
    }

    if (createResponse is CreateChargeResponseV2) {
      final url = (createResponse.paymentUrl ?? '').trim();
      return url.isEmpty ? null : url;
    }

    return null;
  }

  /// Extract payment reference ID from create-charge response (V2/V3+)
  String? extractPaymentReference(dynamic createResponse) {
    if (createResponse is CreateChargeResponseV3) {
      final id = (createResponse.ppId ?? '').trim();
      if (id.isNotEmpty) return id;

      final url = createResponse.paymentUrl.trim();
      if (url.isNotEmpty) {
        try {
          final segments = Uri.parse(url).pathSegments;
          if (segments.isNotEmpty) {
            final last = segments.last.trim();
            if (last.isNotEmpty) return last;
          }
        } catch (_) {
          // Ignore URL parsing issue and return null.
        }
      }
      return null;
    }

    if (createResponse is CreateChargeResponseV2) {
      final id = createResponse.invoiceId.trim();
      return id.isEmpty ? null : id;
    }

    return null;
  }

  /// Check whether a status indicates successful payment
  bool isSuccessfulStatus(String? status) {
    final normalized = (status ?? '').toLowerCase().trim();
    return normalized == 'completed' ||
        normalized == 'success' ||
        normalized == 'paid';
  }

  /// Check whether a status indicates failed/cancelled payment
  bool isFailedStatus(String? status) {
    final normalized = (status ?? '').toLowerCase().trim();
    return normalized == 'failed' ||
        normalized == 'cancelled' ||
        normalized == 'canceled' ||
        normalized == 'expired';
  }

  /// Get API version name
  String get versionName => panelVersion.displayName;

  /// Check if using V3+ API
  bool get isV3Plus => panelVersion.isV3Plus;

  /// Check if using V2 API
  bool get isV2 => panelVersion.isV2;

  /// Validate a string field
  void _validate(String fieldName, String value) {
    if (value.isEmpty) {
      throw PiprapayRequestException(
        message: '$fieldName is required',
        statusCode: 400,
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _httpClient.dispose();
  }
}

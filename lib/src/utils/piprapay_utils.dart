import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;

/// Utility class for webhook validation and security operations
class PiprapayUtils {
  /// Validate webhook by checking API key in headers
  ///
  /// Returns true if the API key in headers matches the expected API key
  static bool validateWebhookApiKey({
    required String receivedApiKey,
    required String expectedApiKey,
  }) {
    return receivedApiKey.toLowerCase() == expectedApiKey.toLowerCase();
  }

  /// Generate HMAC-SHA256 signature for webhook payload
  /// This can be used for additional webhook security if needed
  static String generateHmacSignature({
    required String payload,
    required String secretKey,
  }) {
    final bytes = utf8.encode(payload);
    final key = utf8.encode(secretKey);
    return crypto.Hmac(crypto.sha256, key).convert(bytes).toString();
  }

  /// Validate HMAC signature for webhook payload
  static bool validateHmacSignature({
    required String payload,
    required String signature,
    required String secretKey,
  }) {
    final expectedSignature = generateHmacSignature(
      payload: payload,
      secretKey: secretKey,
    );
    return signature == expectedSignature;
  }

  /// Check if payment status indicates a completed payment
  static bool isPaymentCompleted(String status) {
    return status.toLowerCase() == 'completed';
  }

  /// Check if payment status indicates a failed payment
  static bool isPaymentFailed(String status) {
    return status.toLowerCase() == 'failed';
  }

  /// Check if payment status indicates a refunded payment
  static bool isPaymentRefunded(String status) {
    return status.toLowerCase() == 'refunded';
  }

  /// Check if payment status indicates pending status
  static bool isPaymentPending(String status) {
    return status.toLowerCase() == 'pending';
  }

  /// Parse currency string to enum
  static String parseCurrency(String? currency) {
    if (currency == null || currency.isEmpty) {
      return 'BDT';
    }
    return currency.toUpperCase();
  }

  /// Format amount as string
  static String formatAmount(num amount) {
    return amount.toString();
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate mobile number (basic validation)
  static bool isValidMobileNumber(String mobile) {
    final mobileRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return mobileRegex.hasMatch(mobile);
  }

  /// Check if input is valid email or mobile
  static bool isValidEmailOrMobile(String input) {
    return isValidEmail(input) || isValidMobileNumber(input);
  }

  /// Validate API Key format
  static bool isValidApiKey(String apiKey) {
    return apiKey.isNotEmpty && apiKey.length >= 16;
  }

  /// Build query parameters string from map
  static String buildQueryString(Map<String, dynamic> params) {
    return params.entries
        .where((e) => e.value != null)
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }
}

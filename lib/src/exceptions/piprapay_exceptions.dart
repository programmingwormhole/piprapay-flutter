/// Base exception for Piprapay SDK
class PiprapayException implements Exception {
  final String message;
  final dynamic originalException;
  final StackTrace? stackTrace;

  PiprapayException({
    required this.message,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => 'PiprapayException: $message';
}

/// Exception thrown when API authentication fails
class PiprapayAuthException extends PiprapayException {
  PiprapayAuthException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    originalException: originalException,
    stackTrace: stackTrace,
  );

  @override
  String toString() => 'PiprapayAuthException: $message';
}

/// Exception thrown when API request is invalid
class PiprapayRequestException extends PiprapayException {
  final int? statusCode;
  final Map<String, dynamic>? responseBody;

  PiprapayRequestException({
    required String message,
    this.statusCode,
    this.responseBody,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    originalException: originalException,
    stackTrace: stackTrace,
  );

  @override
  String toString() =>
      'PiprapayRequestException (${statusCode ?? 'Unknown'}): $message';
}

/// Exception thrown when network request fails
class PiprapayNetworkException extends PiprapayException {
  PiprapayNetworkException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    originalException: originalException,
    stackTrace: stackTrace,
  );

  @override
  String toString() => 'PiprapayNetworkException: $message';
}

/// Exception thrown when payment verification fails
class PiprapayPaymentException extends PiprapayException {
  final String? transactionId;

  PiprapayPaymentException({
    required String message,
    this.transactionId,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    originalException: originalException,
    stackTrace: stackTrace,
  );

  @override
  String toString() =>
      'PiprapayPaymentException (Transaction: $transactionId): $message';
}

/// Exception thrown when webhook validation fails
class PiprapayWebhookException extends PiprapayException {
  PiprapayWebhookException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    originalException: originalException,
    stackTrace: stackTrace,
  );

  @override
  String toString() => 'PiprapayWebhookException: $message';
}

/// Exception thrown when configuration is invalid
class PiprapayConfigException extends PiprapayException {
  PiprapayConfigException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    originalException: originalException,
    stackTrace: stackTrace,
  );

  @override
  String toString() => 'PiprapayConfigException: $message';
}
/// Simplified exception for payment operations - used by high-level payment execution
class PiprapayFailure implements Exception {
  final String message;
  final String? transactionId;
  final bool isPaymentCancelled;
  final bool isPaymentFailed;
  final dynamic originalException;

  PiprapayFailure({
    required this.message,
    this.transactionId,
    this.isPaymentCancelled = false,
    this.isPaymentFailed = false,
    this.originalException,
  });

  /// Payment was cancelled by user
  factory PiprapayFailure.cancelled() => PiprapayFailure(
    message: 'Payment cancelled by user',
    isPaymentCancelled: true,
  );

  /// Payment processing failed
  factory PiprapayFailure.failed({
    required String message,
    String? transactionId,
  }) => PiprapayFailure(
    message: message,
    transactionId: transactionId,
    isPaymentFailed: true,
  );

  @override
  String toString() => 'PiprapayFailure: $message${transactionId != null ? ' (TXN: $transactionId)' : ''}';
}
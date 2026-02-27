/// Result of payment execution through WebView checkout
class PaymentResult {
  final bool isSuccess;
  final bool isCancelled;
  final bool isFailed;
  final String? message;
  final String? transactionRef;

  PaymentResult({
    required this.isSuccess,
    required this.isCancelled,
    required this.isFailed,
    this.message,
    this.transactionRef,
  });

  /// Payment completed successfully
  factory PaymentResult.success({String? transactionRef}) => PaymentResult(
    isSuccess: true,
    isCancelled: false,
    isFailed: false,
    transactionRef: transactionRef,
  );

  /// Payment cancelled by user
  factory PaymentResult.cancelled() => PaymentResult(
    isSuccess: false,
    isCancelled: true,
    isFailed: false,
  );

  /// Payment processing failed
  factory PaymentResult.failed({
    required String message,
    String? transactionRef,
  }) => PaymentResult(
    isSuccess: false,
    isCancelled: false,
    isFailed: true,
    message: message,
    transactionRef: transactionRef,
  );
}

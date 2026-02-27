/// Currency types supported by Piprapay
enum PiprapayeCurrency {
  bdt,
  usd,
  eur,
}

/// Return type for payment notifications
enum ReturnType {
  get,
  post,
}

/// Payment status enum
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
}

/// Request model for creating a charge/payment
class CreateChargeRequest {
  /// User's full name
  final String fullName;

  /// User's email address or mobile number
  final String emailOrMobile;

  /// The payment amount
  final String amount;

  /// Additional project-specific metadata
  final Map<String, dynamic> metadata;

  /// URL where user is redirected after successful payment
  final String redirectUrl;

  /// How invoice_id is returned (GET or POST)
  final String returnType;

  /// URL for payment cancellation
  final String cancelUrl;

  /// Backend webhook URL for payment notifications
  final String webhookUrl;

  /// Currency for payment (default: BDT)
  final String currency;

  /// Additional optional parameter for custom reference
  final String? orderId;

  CreateChargeRequest({
    required this.fullName,
    required this.emailOrMobile,
    required this.amount,
    required this.metadata,
    required this.redirectUrl,
    this.returnType = 'GET',
    required this.cancelUrl,
    required this.webhookUrl,
    this.currency = 'BDT',
    this.orderId,
  });

  factory CreateChargeRequest.fromJson(Map<String, dynamic> json) {
    return CreateChargeRequest(
      fullName: json['full_name'] as String,
      emailOrMobile: json['email_mobile'] as String,
      amount: json['amount'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      redirectUrl: json['redirect_url'] as String,
      returnType: json['return_type'] as String? ?? 'GET',
      cancelUrl: json['cancel_url'] as String,
      webhookUrl: json['webhook_url'] as String,
      currency: json['currency'] as String? ?? 'BDT',
      orderId: json['order_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'full_name': fullName,
      'email_mobile': emailOrMobile,
      'amount': amount,
      'metadata': metadata,
      'redirect_url': redirectUrl,
      'return_type': returnType,
      'cancel_url': cancelUrl,
      'webhook_url': webhookUrl,
      'currency': currency,
    };
    if (orderId != null) {
      data['order_id'] = orderId;
    }
    return data;
  }
}

/// Response model for charge creation
class CreateChargeResponse {
  /// Transaction/Invoice ID
  final String invoiceId;

  /// Payment gateway URL to redirect user to
  final String? paymentUrl;

  /// Status of charge creation
  final String status;

  /// Error message if any
  final String? message;

  CreateChargeResponse({
    required this.invoiceId,
    this.paymentUrl,
    required this.status,
    this.message,
  });

  factory CreateChargeResponse.fromJson(Map<String, dynamic> json) {
    return CreateChargeResponse(
      invoiceId: json['invoice_id'] as String,
      paymentUrl: json['paymentUrl'] as String?,
      status: json['status'] as String,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      'paymentUrl': paymentUrl,
      'status': status,
      'message': message,
    };
  }
}

/// Request model for verifying payment
class VerifyPaymentRequest {
  /// Transaction ID to verify
  final String transactionId;

  VerifyPaymentRequest({
    required this.transactionId,
  });

  factory VerifyPaymentRequest.fromJson(Map<String, dynamic> json) {
    return VerifyPaymentRequest(
      transactionId: json['pp_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pp_id': transactionId,
    };
  }
}

/// Response model for payment verification
class VerifyPaymentResponse {
  /// Transaction ID
  final String transactionId;

  /// Customer name
  final String customerName;

  /// Customer email or mobile
  final String customerEmailOrMobile;

  /// Payment method used
  final String paymentMethod;

  /// Amount paid
  final String amount;

  /// Transaction fee
  final String fee;

  /// Refunded amount
  final String refundAmount;

  /// Total amount
  final double total;

  /// Currency of transaction
  final String currency;

  /// Payment status
  final String status;

  /// Transaction date/time
  final String date;

  /// User's phone number (if bKash)
  final String? senderNumber;

  /// External transaction ID
  final String? externalTransactionId;

  /// Custom metadata from creation
  final Map<String, dynamic>? metadata;

  VerifyPaymentResponse({
    required this.transactionId,
    required this.customerName,
    required this.customerEmailOrMobile,
    required this.paymentMethod,
    required this.amount,
    required this.fee,
    required this.refundAmount,
    required this.total,
    required this.currency,
    required this.status,
    required this.date,
    this.senderNumber,
    this.externalTransactionId,
    this.metadata,
  });

  factory VerifyPaymentResponse.fromJson(Map<String, dynamic> json) {
    return VerifyPaymentResponse(
      transactionId: _asString(json['pp_id']) ?? '',
      customerName: _asString(json['customer_name']) ?? '',
      customerEmailOrMobile: _asString(json['customer_email_mobile']) ?? '',
      paymentMethod: _asString(json['payment_method']) ?? '',
      amount: _asString(json['amount']) ?? '0',
      fee: _asString(json['fee']) ?? '0',
      refundAmount: _asString(json['refund_amount']) ?? '0',
      total: _asDouble(json['total']) ?? 0.0,
      currency: _asString(json['currency']) ?? 'BDT',
      status: _asString(json['status']) ?? 'pending',
      date: _asString(json['date']) ?? '',
      senderNumber: _asString(json['sender_number']),
      externalTransactionId: _asString(json['transaction_id']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Helper to safely convert value to string (handles both string and number)
  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is num) return value.toString();
    return value.toString();
  }

  /// Helper to safely convert value to double
  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    if (value is num) return value.toDouble();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'pp_id': transactionId,
      'customer_name': customerName,
      'customer_email_mobile': customerEmailOrMobile,
      'payment_method': paymentMethod,
      'amount': amount,
      'fee': fee,
      'refund_amount': refundAmount,
      'total': total,
      'currency': currency,
      'status': status,
      'date': date,
      'sender_number': senderNumber,
      'transaction_id': externalTransactionId,
      'metadata': metadata,
    };
  }

  /// Check if payment is completed
  bool get isCompleted => status.toLowerCase() == 'completed';

  /// Check if payment is pending
  bool get isPending => status.toLowerCase() == 'pending';

  /// Check if payment failed
  bool get isFailed => status.toLowerCase() == 'failed';

  /// Check if payment is refunded
  bool get isRefunded => status.toLowerCase() == 'refunded';
}

/// Webhook payload model
class WebhookPayload {
  /// Transaction ID
  final String transactionId;

  /// Customer name
  final String customerName;

  /// Customer email or mobile
  final String customerEmailOrMobile;

  /// Payment method
  final String paymentMethod;

  /// Amount
  final String amount;

  /// Fee
  final String fee;

  /// Refund amount
  final String refundAmount;

  /// Total
  final double total;

  /// Currency
  final String currency;

  /// Payment status
  final String status;

  /// Transaction date
  final String date;

  /// Sender phone number
  final String? senderNumber;

  /// External transaction ID
  final String? externalTransactionId;

  /// Custom metadata
  final Map<String, dynamic>? metadata;

  WebhookPayload({
    required this.transactionId,
    required this.customerName,
    required this.customerEmailOrMobile,
    required this.paymentMethod,
    required this.amount,
    required this.fee,
    required this.refundAmount,
    required this.total,
    required this.currency,
    required this.status,
    required this.date,
    this.senderNumber,
    this.externalTransactionId,
    this.metadata,
  });

  factory WebhookPayload.fromJson(Map<String, dynamic> json) {
    return WebhookPayload(
      transactionId: json['pp_id'] as String,
      customerName: json['customer_name'] as String,
      customerEmailOrMobile: json['customer_email_mobile'] as String,
      paymentMethod: json['payment_method'] as String,
      amount: json['amount'] as String,
      fee: json['fee'] as String,
      refundAmount: json['refund_amount'] as String,
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      date: json['date'] as String,
      senderNumber: json['sender_number'] as String?,
      externalTransactionId: json['transaction_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pp_id': transactionId,
      'customer_name': customerName,
      'customer_email_mobile': customerEmailOrMobile,
      'payment_method': paymentMethod,
      'amount': amount,
      'fee': fee,
      'refund_amount': refundAmount,
      'total': total,
      'currency': currency,
      'status': status,
      'date': date,
      'sender_number': senderNumber,
      'transaction_id': externalTransactionId,
      'metadata': metadata,
    };
  }
}

/// Request model for refund
class RefundPaymentRequest {
  /// Transaction ID to refund
  final String transactionId;

  RefundPaymentRequest({
    required this.transactionId,
  });

  factory RefundPaymentRequest.fromJson(Map<String, dynamic> json) {
    return RefundPaymentRequest(
      transactionId: json['pp_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pp_id': transactionId,
    };
  }
}

/// Response model for refund
class RefundPaymentResponse {
  /// Refund status
  final String status;

  /// Transaction ID
  final String? transactionId;

  /// Refund amount
  final String? refundAmount;

  /// Message from server
  final String? message;

  RefundPaymentResponse({
    required this.status,
    this.transactionId,
    this.refundAmount,
    this.message,
  });

  factory RefundPaymentResponse.fromJson(Map<String, dynamic> json) {
    return RefundPaymentResponse(
      status: json['status'] as String,
      transactionId: json['pp_id'] as String?,
      refundAmount: json['refund_amount'] as String?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'pp_id': transactionId,
      'refund_amount': refundAmount,
      'message': message,
    };
  }

  /// Check if refund was successful
  bool get isSuccessful => status.toLowerCase() == 'success';
}

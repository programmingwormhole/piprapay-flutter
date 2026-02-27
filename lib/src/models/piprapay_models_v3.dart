/// Piprapay V3+ Models
/// 
/// Models for Piprapay API V3+ integration
/// All V3+ endpoints use: pp_id (Piprapay ID) instead of transaction_id

/// Create Charge Request for V3+ API
class CreateChargeRequestV3 {
  final String fullName;
  final String emailAddress;
  final String mobileNumber;
  final String amount;
  final String currency;
  final Map<String, dynamic> metadata;
  final String returnUrl;
  final String webhookUrl;

  CreateChargeRequestV3({
    required this.fullName,
    required this.emailAddress,
    required this.mobileNumber,
    required this.amount,
    required this.currency,
    required this.metadata,
    required this.returnUrl,
    required this.webhookUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email_address': emailAddress,
      'mobile_number': mobileNumber,
      'amount': amount,
      'currency': currency,
      'metadata': metadata.isEmpty ? '{}' : _metadataToJsonString(metadata),
      'return_url': returnUrl,
      'webhook_url': webhookUrl,
    };
  }

  /// Convert metadata map to JSON string
  static String _metadataToJsonString(Map<String, dynamic> metadata) {
    if (metadata.isEmpty) return '{}';
    
    final entries = <String>[];
    metadata.forEach((key, value) {
      final jsonValue = _valueToJsonString(value);
      entries.add('"$key":$jsonValue');
    });
    return '{${entries.join(',')}}';
  }

  static String _valueToJsonString(dynamic value) {
    if (value is String) {
      return '"$value"';
    } else if (value is num) {
      return value.toString();
    } else if (value is bool) {
      return value.toString();
    } else if (value is Map) {
      final entries = <String>[];
      value.forEach((k, v) {
        entries.add('"$k":${_valueToJsonString(v)}');
      });
      return '{${entries.join(',')}}';
    } else if (value is List) {
      final items = value.map(_valueToJsonString).toList();
      return '[${items.join(',')}]';
    } else {
      return 'null';
    }
  }
}

/// Create Charge Response for V3+ API
class CreateChargeResponseV3 {
  final String redirectUrl;
  final String status;
  final String? message;
  final String? ppId;
  final String? ppUrl;

  CreateChargeResponseV3({
    required this.redirectUrl,
    required this.status,
    this.message,
    this.ppId,
    this.ppUrl,
  });

  factory CreateChargeResponseV3.fromJson(Map<String, dynamic> json) {
    final redirectUrl = (json['redirect_url'] as String?) ??
        (json['pp_url'] as String?) ??
        (json['payment_url'] as String?) ??
        '';

    return CreateChargeResponseV3(
      redirectUrl: redirectUrl,
      status: json['status'] as String? ?? 'created',
      message: json['message'] as String?,
      ppId: json['pp_id'] as String?,
      ppUrl: json['pp_url'] as String?,
    );
  }

  /// Unified payment URL regardless of key name returned by API
  String get paymentUrl => ppUrl ?? redirectUrl;

  /// Check if response contains a usable payment URL
  bool get hasPaymentUrl => paymentUrl.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'redirect_url': redirectUrl,
      'status': status,
      if (message != null) 'message': message,
      if (ppId != null) 'pp_id': ppId,
      if (ppUrl != null) 'pp_url': ppUrl,
    };
  }
}

/// Verify Payment Response for V3+ API
/// Uses pp_id instead of transaction_id
class VerifyPaymentResponseV3 {
  final String ppId; // Piprapay unique transaction ID
  final String? fullName;
  final String? emailAddress;
  final String? mobileNumber;
  final String? gateway;
  final String amount;
  final String? fee;
  final String? discountAmount;
  final String? total;
  final String? localNetAmount;
  final String currency;
  final String? localCurrency;
  final Map<String, dynamic>? metadata;
  final String? sender;
  final String? transactionId; // Gateway transaction ID
  final String status;
  final String? date;

  VerifyPaymentResponseV3({
    required this.ppId,
    this.fullName,
    this.emailAddress,
    this.mobileNumber,
    this.gateway,
    required this.amount,
    this.fee,
    this.discountAmount,
    this.total,
    this.localNetAmount,
    required this.currency,
    this.localCurrency,
    this.metadata,
    this.sender,
    this.transactionId,
    required this.status,
    this.date,
  });

  factory VerifyPaymentResponseV3.fromJson(Map<String, dynamic> json) {
    return VerifyPaymentResponseV3(
      ppId: _asString(json['pp_id']) ?? '',
      fullName: _asString(json['full_name']),
      emailAddress: _asString(json['email_address']),
      mobileNumber: _asString(json['mobile_number']),
      gateway: _asString(json['gateway']),
      amount: _asString(json['amount']) ?? '0',
      fee: _asString(json['fee']),
      discountAmount: _asString(json['discount_amount']),
      total: _asString(json['total']),
      localNetAmount: _asString(json['local_net_amount']),
      currency: _asString(json['currency']) ?? 'BDT',
      localCurrency: _asString(json['local_currency']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      sender: _asString(json['sender']),
      transactionId: _asString(json['transaction_id']),
      status: _asString(json['status']) ?? 'pending',
      date: _asString(json['date']),
    );
  }

  /// Helper to safely convert value to string (handles both string and number)
  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is num) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'pp_id': ppId,
      if (fullName != null) 'full_name': fullName,
      if (emailAddress != null) 'email_address': emailAddress,
      if (mobileNumber != null) 'mobile_number': mobileNumber,
      if (gateway != null) 'gateway': gateway,
      'amount': amount,
      if (fee != null) 'fee': fee,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (total != null) 'total': total,
      if (localNetAmount != null) 'local_net_amount': localNetAmount,
      'currency': currency,
      if (localCurrency != null) 'local_currency': localCurrency,
      if (metadata != null) 'metadata': metadata,
      if (sender != null) 'sender': sender,
      if (transactionId != null) 'transaction_id': transactionId,
      'status': status,
      if (date != null) 'date': date,
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

/// Refund Payment Response for V3+ API
class RefundPaymentResponseV3 {
  final String ppId;
  final String status;
  final String? message;
  final String? refundAmount;
  final String? refundId;

  RefundPaymentResponseV3({
    required this.ppId,
    required this.status,
    this.message,
    this.refundAmount,
    this.refundId,
  });

  factory RefundPaymentResponseV3.fromJson(Map<String, dynamic> json) {
    return RefundPaymentResponseV3(
      ppId: json['pp_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String?,
      refundAmount: json['refund_amount'] as String?,
      refundId: json['refund_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pp_id': ppId,
      'status': status,
      if (message != null) 'message': message,
      if (refundAmount != null) 'refund_amount': refundAmount,
      if (refundId != null) 'refund_id': refundId,
    };
  }

  /// Check if refund is successful
  bool get isSuccessful => status.toLowerCase() == 'success' || status.toLowerCase() == 'completed';
}

/// Webhook Payload for V3+ API
/// Enhanced with detailed payment information
class WebhookPayloadV3 {
  final String ppId;
  final String? fullName;
  final String? emailAddress;
  final String? mobileNumber;
  final String? gateway;
  final String amount;
  final String? fee;
  final String? discountAmount;
  final double? total;
  final String? localNetAmount;
  final String currency;
  final String? localCurrency;
  final Map<String, dynamic>? metadata;
  final String? sender;
  final String? transactionId;
  final String status;
  final String? date;

  WebhookPayloadV3({
    required this.ppId,
    this.fullName,
    this.emailAddress,
    this.mobileNumber,
    this.gateway,
    required this.amount,
    this.fee,
    this.discountAmount,
    this.total,
    this.localNetAmount,
    required this.currency,
    this.localCurrency,
    this.metadata,
    this.sender,
    this.transactionId,
    required this.status,
    this.date,
  });

  factory WebhookPayloadV3.fromJson(Map<String, dynamic> json) {
    return WebhookPayloadV3(
      ppId: _asString(json['pp_id']) ?? '',
      fullName: _asString(json['full_name']),
      emailAddress: _asString(json['email_address']),
      mobileNumber: _asString(json['mobile_number']),
      gateway: _asString(json['gateway']),
      amount: _asString(json['amount']) ?? '0',
      fee: _asString(json['fee']),
      discountAmount: _asString(json['discount_amount']),
      total: _asDouble(json['total']),
      localNetAmount: _asString(json['local_net_amount']),
      currency: _asString(json['currency']) ?? 'BDT',
      localCurrency: _asString(json['local_currency']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      sender: _asString(json['sender']),
      transactionId: _asString(json['transaction_id']),
      status: _asString(json['status']) ?? 'pending',
      date: _asString(json['date']),
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
      'pp_id': ppId,
      if (fullName != null) 'full_name': fullName,
      if (emailAddress != null) 'email_address': emailAddress,
      if (mobileNumber != null) 'mobile_number': mobileNumber,
      if (gateway != null) 'gateway': gateway,
      'amount': amount,
      if (fee != null) 'fee': fee,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (total != null) 'total': total,
      if (localNetAmount != null) 'local_net_amount': localNetAmount,
      'currency': currency,
      if (localCurrency != null) 'local_currency': localCurrency,
      if (metadata != null) 'metadata': metadata,
      if (sender != null) 'sender': sender,
      if (transactionId != null) 'transaction_id': transactionId,
      'status': status,
      if (date != null) 'date': date,
    };
  }

  /// Check if payment is completed
  bool get isCompleted => status.toLowerCase() == 'completed';

  /// Check if payment failed
  bool get isFailed => status.toLowerCase() == 'failed';

  /// Check if payment was refunded
  bool get isRefunded => status.toLowerCase() == 'refunded';
}

/// Old V2 models (kept for backwards compatibility)

class CreateChargeRequestV2 {
  final String fullName;
  final String emailOrMobile;
  final String amount;
  final Map<String, dynamic> metadata;
  final String redirectUrl;
  final String returnType;
  final String cancelUrl;
  final String webhookUrl;
  final String currency;
  final String? orderId;

  CreateChargeRequestV2({
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

  factory CreateChargeRequestV2.fromJson(Map<String, dynamic> json) {
    return CreateChargeRequestV2(
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

class CreateChargeResponseV2 {
  final String invoiceId;
  final String? paymentUrl;
  final String status;
  final String? message;

  CreateChargeResponseV2({
    required this.invoiceId,
    this.paymentUrl,
    required this.status,
    this.message,
  });

  factory CreateChargeResponseV2.fromJson(Map<String, dynamic> json) {
    return CreateChargeResponseV2(
      invoiceId: json['invoice_id'] as String,
      paymentUrl: json['paymentUrl'] as String?,
      status: json['status'] as String,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      if (paymentUrl != null) 'paymentUrl': paymentUrl,
      'status': status,
      if (message != null) 'message': message,
    };
  }
}

/// V2 Verify Payment Response
class VerifyPaymentResponseV2 {
  final String? transactionId;
  final String? customerName;
  final String? amount;
  final String? status;
  final Map<String, dynamic>? metadata;

  VerifyPaymentResponseV2({
    this.transactionId,
    this.customerName,
    this.amount,
    this.status,
    this.metadata,
  });

  factory VerifyPaymentResponseV2.fromJson(Map<String, dynamic> json) {
    return VerifyPaymentResponseV2(
      transactionId: _asString(json['transaction_id']),
      customerName: _asString(json['customer_name']),
      amount: _asString(json['amount']),
      status: _asString(json['status']),
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

  Map<String, dynamic> toJson() {
    return {
      if (transactionId != null) 'transaction_id': transactionId,
      if (customerName != null) 'customer_name': customerName,
      if (amount != null) 'amount': amount,
      if (status != null) 'status': status,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

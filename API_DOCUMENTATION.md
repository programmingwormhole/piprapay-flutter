# Piprapay API Documentation

Complete API documentation for the Piprapay Flutter package.

## Table of Contents

1. [PiprapayService](#piprapayservice)
2. [Models](#models)
3. [Exceptions](#exceptions)
4. [Utilities](#utilities)

---

## PiprapayService

The main service class for all Piprapay API operations.

### Constructor

```dart
PiprapayService({
  required String apiKey,
  String? baseUrl,
  Duration? timeout,
  http.Client? httpClient,
})
```

**Parameters:**
- `apiKey` *(String, required)* - Your Piprapay API key
- `baseUrl` *(String, optional)* - Custom API endpoint (defaults to sandbox)
- `timeout` *(Duration, optional)* - Request timeout (defaults to 30 seconds)
- `httpClient` *(http.Client, optional)* - Custom HTTP client for testing

**Example:**
```dart
final piprapay = PiprapayService(
  apiKey: 'your_api_key',
  timeout: Duration(seconds: 60),
);
```

### Factories

#### sandbox
Initialize with sandbox environment.

```dart
factory PiprapayService.sandbox({
  required String apiKey,
  Duration? timeout,
  http.Client? httpClient,
})
```

**Example:**
```dart
final piprapay = PiprapayService.sandbox(
  apiKey: 'your_sandbox_key',
);
```

#### production
Initialize with production environment.

```dart
factory PiprapayService.production({
  required String apiKey,
  Duration? timeout,
  http.Client? httpClient,
})
```

**Example:**
```dart
final piprapay = PiprapayService.production(
  apiKey: 'your_production_key',
);
```

### Methods

#### createCharge

Create a payment charge.

```dart
Future<CreateChargeResponse> createCharge({
  required String fullName,
  required String emailOrMobile,
  required String amount,
  required Map<String, dynamic> metadata,
  required String redirectUrl,
  required String cancelUrl,
  required String webhookUrl,
  String returnType = 'POST',
  String currency = 'BDT',
  String? orderId,
})
```

**Parameters:**
- `fullName` *(String)* - Customer's full name
- `emailOrMobile` *(String)* - Customer's email or mobile number
- `amount` *(String)* - Payment amount as string
- `metadata` *(Map)* - Custom key-value data
- `redirectUrl` *(String)* - URL to redirect after payment
- `cancelUrl` *(String)* - URL to redirect on cancellation
- `webhookUrl` *(String)* - URL for webhook notifications
- `returnType` *(String)* - 'GET' or 'POST' (default: 'POST')
- `currency` *(String)* - Currency code (default: 'BDT')
- `orderId` *(String, optional)* - Your custom order ID

**Returns:** `Future<CreateChargeResponse>`

**Throws:** `PiprapayException`, `PiprapayRequestException`, `PiprapayPaymentException`

**Example:**
```dart
final response = await piprapay.createCharge(
  fullName: 'John Doe',
  emailOrMobile: 'john@example.com',
  amount: '500.00',
  metadata: {
    'order_id': 'ORD-12345',
    'product': 'Premium Package',
  },
  redirectUrl: 'https://myapp.com/payment/success',
  cancelUrl: 'https://myapp.com/payment/cancel',
  webhookUrl: 'https://myapi.com/webhook',
  currency: 'BDT',
);

print('Invoice ID: ${response.invoiceId}');
print('Payment URL: ${response.paymentUrl}');
```

#### verifyPayment

Verify the status of a payment.

```dart
Future<VerifyPaymentResponse> verifyPayment({
  required String transactionId,
})
```

**Parameters:**
- `transactionId` *(String)* - The `pp_id` returned from payment

**Returns:** `Future<VerifyPaymentResponse>`

**Throws:** `PiprapayException`, `PiprapayPaymentException`

**Example:**
```dart
final verification = await piprapay.verifyPayment(
  transactionId: '181055228',
);

if (verification.isCompleted) {
  print('Payment successful!");
  print('Amount: ${verification.amount} ${verification.currency}');
  print('Method: ${verification.paymentMethod}');
} else {
  print('Status: ${verification.status}');
}
```

#### refundPayment

Refund a completed payment.

```dart
Future<RefundPaymentResponse> refundPayment({
  required String transactionId,
})
```

**Parameters:**
- `transactionId` *(String)* - The `pp_id` to refund

**Returns:** `Future<RefundPaymentResponse>`

**Throws:** `PiprapayException`, `PiprapayPaymentException`

**Example:**
```dart
final refund = await piprapay.refundPayment(
  transactionId: '181055228',
);

if (refund.isSuccessful) {
  print('Refund processed successfully');
} else {
  print('Refund failed: ${refund.message}');
}
```

#### validateWebhook

Validate and parse webhook payload.

```dart
Future<WebhookPayload> validateWebhook({
  required String payload,
  required String receivedApiKey,
})
```

**Parameters:**
- `payload` *(String)* - The webhook JSON payload
- `receivedApiKey` *(String)* - API key from webhook headers

**Returns:** `Future<WebhookPayload>`

**Throws:** `PiprapayWebhookException`

**Example:**
```dart
Future<void> handleWebhook(String body, String apiKey) async {
  try {
    final webhook = await piprapay.validateWebhook(
      payload: body,
      receivedApiKey: apiKey,
    );

    if (webhook.status == 'completed') {
      // Update your database
      await updatePaymentStatus(webhook.transactionId, 'paid');
    }
  } on PiprapayWebhookException catch (e) {
    print('Webhook validation failed: ${e.message}');
  }
}
```

#### parseWebhookPayload

Parse webhook payload without validation.

```dart
Future<WebhookPayload> parseWebhookPayload(String jsonString)
```

**Parameters:**
- `jsonString` *(String)* - The JSON payload string

**Returns:** `Future<WebhookPayload>`

**Throws:** `PiprapayWebhookException`

#### dispose

Clean up resources.

```dart
void dispose()
```

**Important:** Always call this method when the service is no longer needed.

**Example:**
```dart
@override
void dispose() {
  piprapay.dispose();
  super.dispose();
}
```

---

## Models

### CreateChargeRequest

Request data for creating a payment charge.

```dart
class CreateChargeRequest {
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

  CreateChargeRequest({...});

  factory CreateChargeRequest.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### CreateChargeResponse

Response with payment details and redirect URL.

```dart
class CreateChargeResponse {
  final String invoiceId;      // Transaction ID
  final String? paymentUrl;    // Payment gateway URL
  final String status;         // Request status
  final String? message;       // Status message

  factory CreateChargeResponse.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**Important Properties:**
- `invoiceId` - Save this for payment verification
- `paymentUrl` - Redirect user to this URL for payment

### VerifyPaymentRequest

Request data for payment verification.

```dart
class VerifyPaymentRequest {
  final String transactionId;  // pp_id

  factory VerifyPaymentRequest.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### VerifyPaymentResponse

Complete payment information.

```dart
class VerifyPaymentResponse {
  final String transactionId;
  final String customerName;
  final String customerEmailOrMobile;
  final String paymentMethod;          // bKash, Nagad, etc.
  final String amount;
  final String fee;
  final String refundAmount;
  final double total;
  final String currency;
  final String status;                 // completed, failed, pending, etc.
  final String date;
  final String? senderNumber;          // For bKash
  final String? externalTransactionId;
  final Map<String, dynamic>? metadata;

  // Convenience properties
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isFailed => status.toLowerCase() == 'failed';
  bool get isRefunded => status.toLowerCase() == 'refunded';

  factory VerifyPaymentResponse.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### WebhookPayload

Data received in webhook notifications.

```dart
class WebhookPayload {
  final String transactionId;
  final String customerName;
  final String customerEmailOrMobile;
  final String paymentMethod;
  final String amount;
  final String fee;
  final String refundAmount;
  final double total;
  final String currency;
  final String status;
  final String date;
  final String? senderNumber;
  final String? externalTransactionId;
  final Map<String, dynamic>? metadata;

  factory WebhookPayload.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### RefundPaymentRequest

Request data for refunding.

```dart
class RefundPaymentRequest {
  final String transactionId;  // pp_id

  factory RefundPaymentRequest.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### RefundPaymentResponse

Refund status and details.

```dart
class RefundPaymentResponse {
  final String status;
  final String? transactionId;
  final String? refundAmount;
  final String? message;

  bool get isSuccessful => status.toLowerCase() == 'success';

  factory RefundPaymentResponse.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

---

## Exceptions

All exceptions inherit from `PiprapayException`.

### PiprapayException

Base exception class.

```dart
class PiprapayException implements Exception {
  final String message;
  final dynamic originalException;
  final StackTrace? stackTrace;
}
```

### PiprapayAuthException

Thrown when authentication fails (invalid API key).

```dart
try {
  await piprapay.verifyPayment(transactionId);
} on PiprapayAuthException catch (e) {
  print('Invalid API key: ${e.message}');
}
```

### PiprapayRequestException

Thrown when request validation fails.

```dart
class PiprapayRequestException extends PiprapayException {
  final int? statusCode;
  final Map<String, dynamic>? responseBody;
}

try {
  await piprapay.createCharge(...);
} on PiprapayRequestException catch (e) {
  print('Status: ${e.statusCode}');
  print('Response: ${e.responseBody}');
}
```

### PiprapayNetworkException

Thrown when network request fails.

```dart
try {
  await piprapay.verifyPayment(transactionId);
} on PiprapayNetworkException catch (e) {
  print('Network error: ${e.message}');
}
```

### PiprapayPaymentException

Thrown for payment-specific errors.

```dart
class PiprapayPaymentException extends PiprapayException {
  final String? transactionId;
}

try {
  await piprapay.verifyPayment(transactionId);
} on PiprapayPaymentException catch (e) {
  print('Payment error for ${e.transactionId}: ${e.message}');
}
```

### PiprapayWebhookException

Thrown when webhook validation fails.

```dart
try {
  await piprapay.validateWebhook(payload, apiKey);
} on PiprapayWebhookException catch (e) {
  print('Webhook error: ${e.message}');
}
```

### PiprapayConfigException

Thrown when configuration is invalid.

```dart
try {
  final piprapay = PiprapayService(apiKey: 'invalid');
} on PiprapayConfigException catch (e) {
  print('Config error: ${e.message}');
}
```

---

## Utilities

### PiprapayUtils

Utility methods for validation and security.

#### Validation Methods

```dart
// Email validation
static bool isValidEmail(String email)

// Mobile validation
static bool isValidMobileNumber(String mobile)

// Email or mobile
static bool isValidEmailOrMobile(String input)

// API key validation
static bool isValidApiKey(String apiKey)
```

**Example:**
```dart
if (!PiprapayUtils.isValidEmail(email)) {
  throw Exception('Invalid email');
}

if (!PiprapayUtils.isValidMobileNumber(mobile)) {
  throw Exception('Invalid mobile');
}
```

#### Payment Status Helpers

```dart
static bool isPaymentCompleted(String status)
static bool isPaymentFailed(String status)
static bool isPaymentRefunded(String status)
static bool isPaymentPending(String status)
```

**Example:**
```dart
if (PiprapayUtils.isPaymentCompleted(webhook.status)) {
  // Process confirmation
}
```

#### Security Methods

```dart
// Webhook validation
static bool validateWebhookApiKey({
  required String receivedApiKey,
  required String expectedApiKey,
})

// HMAC signature generation
static String generateHmacSignature({
  required String payload,
  required String secretKey,
})

// HMAC signature validation
static bool validateHmacSignature({
  required String payload,
  required String signature,
  required String secretKey,
})
```

**Example:**
```dart
// Validate webhook API key
if (!PiprapayUtils.validateWebhookApiKey(
  receivedApiKey: headerApiKey,
  expectedApiKey: myApiKey,
)) {
  throw Exception('Unauthorized webhook');
}

// Generate signature
final signature = PiprapayUtils.generateHmacSignature(
  payload: jsonString,
  secretKey: secretKey,
);
```

#### Formatting Methods

```dart
static String parseCurrency(String? currency)
static String formatAmount(num amount)
static String buildQueryString(Map<String, dynamic> params)
```

---

## Environment Constants

```dart
class PiprapayService {
  static const String sandboxUrl = 'https://sandbox.piprapay.com/api';
  static const String productionUrl = 'https://api.piprapay.com/api';
}
```

---

## Status Values

### Payment Status

- `pending` - Payment is awaiting confirmation
- `processing` - Payment is being processed
- `completed` - Payment successfully completed
- `failed` - Payment failed
- `cancelled` - Payment was cancelled
- `refunded` - Payment was refunded

### Currency

- `BDT` - Bangladeshi Taka (default)
- `USD` - US Dollar
- `EUR` - Euro

---

## Error Response Format

When an error occurs, the response may include:

```dart
{
  "status": "error",
  "message": "Error description",
  "errors": {
    "field_name": ["Field validation error"]
  },
  "code": "ERROR_CODE"
}
```

---

## Common Error Codes

- `INVALID_API_KEY` - API key is invalid or missing
- `INVALID_AMOUNT` - Amount is invalid or missing
- `INVALID_EMAIL` - Email is invalid
- `INVALID_MOBILE` - Mobile number is invalid
- `INVALID_URL` - URL is invalid
- `TRANSACTION_NOT_FOUND` - Transaction ID doesn't exist
- `ALREADY_REFUNDED` - Transaction already refunded
- `REFUND_LIMIT_EXCEEDED` - Refund exceeds payment amount
- `SERVER_ERROR` - Internal server error
- `NETWORK_ERROR` - Network connectivity issue
- `TIMEOUT` - Request timeout

---

## Webhook Headers

Webhooks are sent with the following headers:

- `Content-Type: application/json`
- `MHS-PIPRAPAY-API-KEY: your-api-key`

Always validate the API key from the headers before processing the webhook payload.

---

## Rate Limits

- Create Charge: 100 requests per minute
- Verify Payment: 1000 requests per minute
- Refund: 100 requests per minute

Contact Piprapay support for increased limits.

---

For more information, visit [Piprapay Documentation](https://piprapay.readme.io)

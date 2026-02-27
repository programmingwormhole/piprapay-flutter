# 🚀 Piprapay Flutter Package

[![Pub Version](https://img.shields.io/pub/v/piprapay)](https://pub.dev/packages/piprapay)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)
[![GitHub](https://img.shields.io/badge/GitHub-programmingwormhole-black.svg)](https://github.com/programmingwormhole/piprapay-flutter)

A **production-ready, type-safe** Flutter package for seamless integration with [Piprapay](https://piprapay.com) payment gateway. Build powerful payment solutions with complete API support (V2 & V3+), comprehensive error handling, and professional payment UI capabilities.

---

## ✨ Features

### 🌟 Core Features
- ✅ **Complete Piprapay API Integration** - Full support for V2 and V3+ APIs with automatic version detection
- ✅ **Payment Creation & Management** - Create charges, extract checkout URLs, handle payment references
- ✅ **Real-time Verification** - Verify payment status with detailed transaction information
- ✅ **Refund Processing** - Process full and partial refunds securely
- ✅ **Webhook Validation** - Built-in webhook payload validation and signature verification
- ✅ **Activity Logging** - Optional in-app payment activity tracking and monitoring

### 🔒 Security & Reliability
- ✅ **Type-Safe Models** - Null-safe, fully-typed data models with JSON serialization
- ✅ **Professional Error Handling** - Specific exceptions for different error scenarios
- ✅ **Flexible Type Conversion** - Handles inconsistent API responses (numeric/string fields)
- ✅ **API Key Authentication** - Secure API key management and validation
- ✅ **HTTPS Communication** - All traffic encrypted and secure
- ✅ **Webhook Signature Verification** - Cryptographic validation of webhook payloads

### 🎯 Developer Experience
- ✅ **Simple, Intuitive API** - Clean, easy-to-use service interface
- ✅ **Sandbox & Production Modes** - Built-in environment switching
- ✅ **Comprehensive Documentation** - Detailed API references and integration guides
- ✅ **Example App Included** - Full-featured example showing best practices
- ✅ **Input Validation Utilities** - Email, mobile number, and payment status validators
- ✅ **Zero Dependencies** - Minimal external dependencies (only `http` and `crypto`)

### 🎨 UI Enhancements (Built-in)
- ✅ **WebView Payment Handler** - Built-in WebView for seamless in-app payment execution
- ✅ **Payment Status Detection** - Automatic detection of success, cancel, and failure states
- ✅ **Customizable UI** - Configurable app bar title and display duration
- ✅ **Error Handling** - Comprehensive error detection and reporting

---

## 📦 Installation

### Add to your `pubspec.yaml`:

```yaml
dependencies:
  piprapay: ^1.0.0
```

### Run:
```bash
flutter pub get
```

> **Note:** The package includes `webview_flutter` for in-app payment execution. No additional dependencies needed!

---

## 🚀 Quick Start

### 1️⃣ Initialize the Piprapay Service

#### Basic Initialization

```dart
import 'package:piprapay/piprapay.dart';

// Sandbox Mode (Testing) - Minimal configuration
final piprapay = PiprapayService.sandbox(
  apiKey: 'your_sandbox_api_key',  // ✅ Required
);

// Production Mode - Minimal configuration
final piprapay = PiprapayService.production(
  apiKey: 'your_production_api_key',  // ✅ Required
  baseUrl: 'https://api.piprapay.com/api',  // ✅ Required for production
);
```

#### Advanced Initialization (With All Options)

```dart
// Sandbox with all optional parameters
final piprapay = PiprapayService.sandbox(
  apiKey: 'your_sandbox_api_key',              // ✅ Required
  panelVersion: PanelVersion.v3plus,           // ⚙️ Optional (default: V3+)
  enableLogging: true,                          // ⚙️ Optional (default: false) - Enables request/response logging
  timeout: Duration(seconds: 30),              // ⚙️ Optional (default: system timeout)
);

// Production with all optional parameters
final piprapay = PiprapayService.production(
  apiKey: 'your_production_api_key',           // ✅ Required
  baseUrl: 'https://api.piprapay.com/api',     // ✅ Required
  panelVersion: PanelVersion.v3plus,           // ⚙️ Optional (default: V3+)
  enableLogging: false,                         // ⚙️ Optional (default: false) - Set true for debugging
  timeout: Duration(seconds: 60),              // ⚙️ Optional (default: system timeout)
);

// Manual Configuration (Advanced)
final piprapay = PiprapayService(
  apiKey: 'your_api_key',                      // ✅ Required
  isSandbox: true,                              // ✅ Required - true for testing, false for production
  baseUrl: 'https://custom.piprapay.com/api',  // ⚙️ Optional (auto-set if isSandbox: true)
  panelVersion: PanelVersion.v2,               // ⚙️ Optional - Use V2 for legacy API
  enableLogging: true,                          // ⚙️ Optional - Logs API calls for debugging
  timeout: Duration(seconds: 45),              // ⚙️ Optional - Custom timeout duration
);
```

#### Initialization Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `apiKey` | String | ✅ Yes | - | Your Piprapay API key from dashboard |
| `baseUrl` | String | ✅ Yes (Production) | Sandbox URL | API endpoint URL (required when `isSandbox: false`) |
| `isSandbox` | bool | ✅ Yes (Manual) | - | `true` for testing, `false` for production |
| `panelVersion` | PanelVersion | ⚙️ Optional | `v3plus` | API version: `PanelVersion.v2` or `PanelVersion.v3plus` |
| `enableLogging` | bool | ⚙️ Optional | `false` | Enable detailed request/response logging (useful for debugging) |
| `timeout` | Duration | ⚙️ Optional | System default | Maximum time to wait for API responses |

#### Panel Version Options

```dart
// For V3+ API (Latest - Recommended)
final piprapay = PiprapayService.sandbox(
  apiKey: 'your_key',
  panelVersion: PanelVersion.v3plus,  // Uses pp_id, pp_url, latest features
);

// For V2 API (Legacy Support)
final piprapay = PiprapayService.sandbox(
  apiKey: 'your_key',
  panelVersion: PanelVersion.v2,  // Uses transaction_id, older endpoints
);
```

### 2️⃣ Create a Payment Charge

#### For V3+ API (Recommended)

```dart
try {
  final charge = await piprapay.createCharge(
    // ✅ Required Parameters (V3+)
    fullName: 'Customer Name',                          // ✅ Required
    emailAddress: 'customer@example.com',               // ✅ Required (must be valid email)
    mobileNumber: '+8801700000000',                     // ✅ Required (with country code)
    amount: '100.00',                                   // ✅ Required (as String)
    returnUrl: 'https://yourapp.com/payment/return',   // ✅ Required (success redirect)
    webhookUrl: 'https://yourapp.com/api/webhook',     // ✅ Required (backend notification)
    
    // ⚙️ Optional Parameters
    currency: 'BDT',                                    // ⚙️ Optional (default: BDT)
    metadata: {'order_id': '12345', 'user_id': '789'}, // ⚙️ Optional (custom data)
  );

  // Extract payment information
  String checkoutUrl = piprapay.extractCheckoutUrl(charge)!;
  String paymentRef = piprapay.extractPaymentReference(charge)!;

  print('✅ Invoice: ${charge.invoiceId}');
  print('✅ Payment URL: $checkoutUrl');
  print('✅ Payment Reference (pp_id): $paymentRef');
  
} on PiprapayRequestException catch (e) {
  print('❌ Validation Error: ${e.message}');
} on PiprapayException catch (e) {
  print('❌ Error: ${e.message}');
}
```

#### For V2 API (Legacy Support)

```dart
try {
  final charge = await piprapay.createCharge(
    // ✅ Required Parameters (V2)
    fullName: 'Customer Name',                            // ✅ Required
    emailOrMobile: 'customer@example.com',                // ✅ Required (email OR mobile)
    amount: '100.00',                                     // ✅ Required
    redirectUrl: 'https://yourapp.com/payment/success',  // ✅ Required
    webhookUrl: 'https://yourapp.com/api/webhook',       // ✅ Required
    
    // ⚙️ Optional Parameters
    cancelUrl: 'https://yourapp.com/payment/cancel',     // ⚙️ Optional (cancel redirect)
    currency: 'BDT',                                      // ⚙️ Optional (default: BDT)
    returnType: 'POST',                                   // ⚙️ Optional (default: POST)
    orderId: 'order_12345',                               // ⚙️ Optional (custom order ID)
    metadata: {'custom_field': 'value'},                 // ⚙️ Optional
  );

  String paymentUrl = charge.paymentUrl;
  print('✅ Payment URL: $paymentUrl');
  
} on PiprapayException catch (e) {
  print('❌ Error: ${e.message}');
}
```

#### createCharge() Parameters

**V3+ API Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `fullName` | String | ✅ Yes | - | Customer's full name |
| `emailAddress` | String | ✅ Yes | - | Valid email address (validated) |
| `mobileNumber` | String | ✅ Yes | - | Mobile with country code (e.g., +8801700000000) |
| `amount` | String | ✅ Yes | - | Payment amount (e.g., "100.00") |
| `returnUrl` | String | ✅ Yes | - | URL to redirect after payment completion |
| `webhookUrl` | String | ✅ Yes | - | Backend endpoint for payment notifications |
| `currency` | String | ⚙️ Optional | "BDT" | Currency code (BDT, USD, etc.) |
| `metadata` | Map | ⚙️ Optional | `{}` | Custom data to attach to payment |

**V2 API Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `fullName` | String | ✅ Yes | - | Customer's full name |
| `emailOrMobile` | String | ✅ Yes | - | Email OR mobile number (validated) |
| `amount` | String | ✅ Yes | - | Payment amount |
| `redirectUrl` | String | ✅ Yes | - | Success redirect URL |
| `webhookUrl` | String | ✅ Yes | - | Webhook endpoint URL |
| `cancelUrl` | String | ⚙️ Optional | - | Cancel page redirect URL |
| `currency` | String | ⚙️ Optional | "BDT" | Currency code |
| `returnType` | String | ⚙️ Optional | "POST" | Return method (POST/GET) |
| `orderId` | String | ⚙️ Optional | - | Custom order identifier |
| `metadata` | Map | ⚙️ Optional | `{}` | Custom data object |

### 3️⃣ Verify Payment Status

#### For V3+ API

```dart
try {
  final verification = await piprapay.verifyPayment(
    ppId: 'pp_id_from_redirect',  // ✅ Required (V3+) - Received from payment redirect/webhook
  );

  if (piprapay.isSuccessfulStatus(verification.status)) {
    print('✅ Payment Successful!');
    print('✅ Amount: ${verification.amount} ${verification.currency}');
    print('✅ Total: ${verification.total}');
    print('✅ Method: ${verification.paymentMethod}');
    print('✅ Transaction: ${verification.transactionId}');
  } else {
    print('❌ Payment Status: ${verification.status}');
  }
  
} on PiprapayPaymentException catch (e) {
  print('❌ Verification Error: ${e.message}');
}
```

#### For V2 API

```dart
try {
  final verification = await piprapay.verifyPayment(
    transactionId: 'transaction_id_from_redirect',  // ✅ Required (V2)
  );

  if (verification.status == 'completed') {
    print('✅ Payment verified!');
  }
  
} on PiprapayPaymentException catch (e) {
  print('❌ Error: ${e.message}');
}
```

#### verifyPayment() Parameters

| Parameter | Type | Required | API Version | Description |
|-----------|------|----------|-------------|-------------|
| `ppId` | String | ✅ Yes | V3+ | Payment reference from redirect (pp_id parameter) |
| `transactionId` | String | ✅ Yes | V2 | Transaction ID from redirect (V2 legacy) |

> **Note:** Use `ppId` for V3+ API or `transactionId` for V2 API based on your `panelVersion` setting.

### 4️⃣ Execute Payment in WebView (Built-in)

The package includes a built-in WebView handler - no need to implement it yourself!

```dart
import 'package:piprapay/piprapay.dart';

try {
  final result = await PiprapayWebView.executePayment(
    context,
    paymentUrl: checkoutUrl,                        // ✅ Required - From createCharge()
    successPageDisplayDuration: Duration(seconds: 2), // ⚙️ Optional (default: 2 seconds)
    appBarTitle: 'Complete Payment',                // ⚙️ Optional (default: "Complete Payment")
  );

  if (result != null && result.isSuccess) {
    // Verify payment after successful completion
    final verification = await piprapay.verifyPayment(
      ppId: result.transactionRef!,  // V3+
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Payment verified: ${verification.amount}')),
    );
  } else if (result?.isCancelled == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⚠️ Payment cancelled')),
    );
  } else if (result?.isFailed == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Payment failed: ${result!.message}')),
    );
  }
  
} catch (e) {
  print('Error executing payment: $e');
}
```

#### PiprapayWebView.executePayment() Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `context` | BuildContext | ✅ Yes | - | BuildContext for navigation |
| `paymentUrl` | String | ✅ Yes | - | Payment gateway URL from `createCharge()` |
| `successPageDisplayDuration` | Duration | ⚙️ Optional | 2 seconds | How long to display success page before closing |
| `appBarTitle` | String | ⚙️ Optional | "Complete Payment" | Custom title for the payment page |

**Returns:** `PaymentResult?` - Contains payment outcome (success/cancelled/failed)

### 5️⃣ Process Refunds

#### For V3+ API

```dart
try {
  final refund = await piprapay.refundPayment(
    ppId: 'pp_id_value',  // ✅ Required (V3+) - Payment reference to refund
  );

  if (refund.status == 'refunded') {
    print('✅ Refund processed successfully');
    print('✅ Refund Amount: ${refund.refundAmount}');
    print('✅ Transaction: ${refund.transactionId}');
  }
  
} on PiprapayPaymentException catch (e) {
  print('❌ Refund failed: ${e.message}');
}
```

#### For V2 API

```dart
try {
  final refund = await piprapay.refundPayment(
    transactionId: 'transaction_id_value',  // ✅ Required (V2)
  );

  print('✅ Refund initiated');
  print('Response: $refund');
  
} on PiprapayPaymentException catch (e) {
  print('❌ Refund failed: ${e.message}');
}
```

#### refundPayment() Parameters

| Parameter | Type | Required | API Version | Description |
|-----------|------|----------|-------------|-------------|
| `ppId` | String | ✅ Yes | V3+ | Payment reference (pp_id) to refund |
| `transactionId` | String | ✅ Yes | V2 | Transaction ID to refund (V2 legacy) |

> **Note:** Full refund is processed. Partial refunds depend on Piprapay dashboard configuration.

### 6️⃣ Handle Webhooks

#### Using validateWebhook() Method

```dart
// In your Flutter backend webhook handler
try {
  final webhook = await piprapay.validateWebhook(
    payload: requestBody,        // ✅ Required - Raw JSON string from request body
    receivedApiKey: apiKeyHeader, // ✅ Required - API key from request header
  );

  // Webhook validated successfully
  if (webhook.status == 'completed') {
    print('✅ Payment completed: ${webhook.transactionId}');
    updateDatabase(webhook.transactionId, 'completed');
  }
  
} on PiprapayWebhookException catch (e) {
  print('❌ Webhook validation failed: ${e.message}');
  // Return 401 Unauthorized
}
```

#### Backend Example (Node.js/Express)

```dart
app.post('/api/webhook', async (req, res) => {
  const apiKey = req.headers['mh-piprapay-api-key'];  // ✅ Required header
  const payload = JSON.stringify(req.body);           // ✅ Required body
  
  // Validate using Piprapay Flutter service
  const webhook = await piprapay.validateWebhook(
    payload: payload,
    receivedApiKey: apiKey,
  );
  
  if (webhook.status === 'completed') {
    updatePaymentStatus(webhook.transactionId, 'completed');
  }
  
  res.json({ status: true, message: 'Webhook received' });
});
```

#### validateWebhook() Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `payload` | String | ✅ Yes | Raw JSON string from webhook request body |
| `receivedApiKey` | String | ✅ Yes | API key from `mh-piprapay-api-key` request header |

> **Security Note:** Always validate the API key matches your configured key to prevent unauthorized webhook calls.

---

## 🛡️ Error Handling

The package provides specific exception types for precise error handling:

```dart
try {
  // Payment operation
} on PiprapayAuthException catch (e) {
  // Handle authentication errors (invalid API key)
  print('🔑 Auth Error: ${e.message}');
  
} on PiprapayRequestException catch (e) {
  // Handle validation/request errors
  print('📝 Request Error: ${e.message}');
  print('Status Code: ${e.statusCode}');
  
} on PiprapayNetworkException catch (e) {
  // Handle network errors
  print('🌐 Network Error: ${e.message}');
  
} on PiprapayPaymentException catch (e) {
  // Handle payment-specific errors
  print('💳 Payment Error: ${e.message}');
  print('Transaction: ${e.transactionId}');
  
} on PiprapayWebhookException catch (e) {
  // Handle webhook validation errors
  print('🔔 Webhook Error: ${e.message}');
  
} on PiprapayFailure catch (e) {
  // Handle simplified payment failures (WebView execution)
  if (e.isPaymentCancelled) {
    print('⚠️ Payment cancelled by user');
  } else if (e.isPaymentFailed) {
    print('❌ Payment failed: ${e.message}');
  }
  
} on PiprapayException catch (e) {
  // Handle all other Piprapay errors
  print('❌ Error: ${e.message}');
}
```

---

## 📚 Advanced Usage

### Custom Configuration

#### Full Manual Configuration

```dart
final piprapay = PiprapayService(
  apiKey: 'your_api_key',                        // ✅ Required - Your Piprapay API key
  isSandbox: true,                                // ✅ Required - Environment mode
  baseUrl: 'https://custom.piprapay.com/api',   // ⚙️ Optional (auto-set if sandbox)
  panelVersion: PanelVersion.v3plus,             // ⚙️ Optional (default: V3+)
  enableLogging: true,                            // ⚙️ Optional (default: false)
  timeout: Duration(seconds: 60),                // ⚙️ Optional
);
```

#### Configuration Options

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `apiKey` | String | ✅ Yes | - | Piprapay API key |
| `isSandbox` | bool | ✅ Yes | - | `true` for sandbox, `false` for production |
| `baseUrl` | String | ⚙️ Optional | Sandbox URL | Custom API endpoint (required if `isSandbox: false`) |
| `panelVersion` | PanelVersion | ⚙️ Optional | `v3plus` | API version (`PanelVersion.v2` or `PanelVersion.v3plus`) |
| `enableLogging` | bool | ⚙️ Optional | `false` | Enable request/response logging for debugging |
| `timeout` | Duration | ⚙️ Optional | System default | Request timeout duration |
| `httpClient` | http.Client | ⚙️ Optional | - | Custom HTTP client (for testing/mocking) |

> **Tip:** Use `enableLogging: true` during development to see full API request/response details in console.

### Input Validation

```dart
import 'package:piprapay/piprapay.dart';

// Validate email
if (!PiprapayUtils.isValidEmail('test@example.com')) {
  print('Invalid email format');
}

// Validate mobile number
if (!PiprapayUtils.isValidMobileNumber('+8801700000000')) {
  print('Invalid mobile number');
}

// Validate email or mobile
if (PiprapayUtils.isValidEmailOrMobile(userInput)) {
  print('Valid contact information');
}

// Check payment status
if (PiprapayUtils.isPaymentCompleted(status)) {
  print('Payment completed successfully');
}

// Verify status helpers
bool isSuccess = piprapay.isSuccessfulStatus(status);
bool isFailed = piprapay.isFailedStatus(status);
```

### Environment Variables

```dart
// Use environment configuration in main.dart
const String PIPRAPAY_API_KEY = String.fromEnvironment(
  'PIPRAPAY_API_KEY',
  defaultValue: 'sandbox_key',
);

const String PIPRAPAY_ENV = String.fromEnvironment(
  'PIPRAPAY_ENV',
  defaultValue: 'sandbox',
);

final piprapay = PIPRAPAY_ENV == 'production'
    ? PiprapayService.production(apiKey: PIPRAPAY_API_KEY)
    : PiprapayService.sandbox(apiKey: PIPRAPAY_API_KEY);
```

### Resource Management

```dart
@override
void dispose() {
  piprapay.dispose();
  super.dispose();
}
```

---

## 📊 Data Models

### CreateChargeResponse
```dart
class CreateChargeResponse {
  final String invoiceId;           // Unique invoice ID
  final String transactionId;       // Transaction reference (pp_id)
  final String checkoutUrl;         // Payment gateway URL (V3+)
  final String paymentUrl;          // Alternative payment URL (V2/V3)
  final Map<String, dynamic>? metadata; // Custom data
}
```

### VerifyPaymentResponse (V2 & V3+)
```dart
class VerifyPaymentResponse {
  final String transactionId;       // pp_id
  final String customerName;
  final String amount;
  final double total;               // Total amount
  final String currency;            // BDT, USD, etc.
  final String status;              // completed, failed, pending, etc.
  final String paymentMethod;       // bKash, Nagad, Rocket, etc.
  final String date;
  final String? metadata;           // Custom data
}
```

### WebhookPayload
```dart
class WebhookPayload {
  final String transactionId;       // pp_id
  final String status;              // completed, failed, etc.
  final String amount;
  final double total;
  final String currency;
  final String paymentMethod;
  final String customerName;
  final String customerEmailOrMobile;
  final Map<String, dynamic>? metadata;
}
```

### PaymentResult (WebView)
```dart
class PaymentResult {
  final bool isSuccess;
  final bool isCancelled;
  final bool isFailed;
  final String? transactionRef;
  final String? message;
  
  // Factory constructors
  factory PaymentResult.success(String transactionRef);
  factory PaymentResult.cancelled();
  factory PaymentResult.failed(String? message, String? transactionRef);
}
```

---

## 🧪 Testing

### Run Tests

```bash
flutter test
```

### Example Test

```dart
test('Create charge request validation', () {
  final piprapay = PiprapayService.sandbox(apiKey: 'test_key');
  
  expect(
    PiprapayUtils.isValidEmail('valid@example.com'),
    true,
  );
  
  expect(
    PiprapayUtils.isValidMobileNumber('+8801700000000'),
    true,
  );
});
```

### Sandbox Testing

```dart
// Use sandbox credentials for testing
final piprapay = PiprapayService.sandbox(
  apiKey: 'pk_test_your_sandbox_key',
);

// Test credentials
const testEmail = 'test@example.com';
const testAmount = '100';
const testMobile = '+8801700000000';

// All transactions will be simulated
```

---

## ✅ Best Practices

1. **🔐 API Key Security**
   - Never hardcode API keys
   - Use environment variables: `String.fromEnvironment('PIPRAPAY_API_KEY')`
   - Store sensitive data in secure storage (Flutter Secure Storage)

2. **✔️ Input Validation**
   - Always validate user input before payment
   - Use `PiprapayUtils` validators
   - Show validation errors to users

3. **🛡️ Error Handling**
   - Implement try-catch for all payment operations
   - Provide meaningful error messages
   - Log errors for debugging

4. **🔔 Webhook Verification**
   - Always validate webhook API keys
   - Verify webhook signatures
   - Process payments idempotently (handle duplicate webhooks)

5. **💾 Database Integration**
   - Store transaction IDs for record-keeping
   - Update payment status on verification
   - Log all payment events with timestamps

6. **🧪 Testing Strategy**
   - Use sandbox environment for testing
   - Test all payment flows (success, cancel, fail)
   - Verify webhook handling

7. **📊 Monitoring & Logging**
   - Log important payment events
   - Monitor API response times
   - Track error rates
   - Use activity logs for debugging

8. **🚀 Production Deployment**
   - Switch to production API key
   - Update base URL for production
   - Enable webhook endpoint
   - Monitor payment success rates
   - Have fallback payment methods

---

## 🔧 API Reference

### PiprapayService Methods

#### `createCharge()`
Creates a new payment charge.

**V3+ API Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `fullName` | String | ✅ Yes | - | Customer's full name |
| `emailAddress` | String | ✅ Yes | - | Valid email address (validated) |
| `mobileNumber` | String | ✅ Yes | - | Mobile with country code |
| `amount` | String | ✅ Yes | - | Payment amount (e.g., "100.00") |
| `returnUrl` | String | ✅ Yes | - | Success redirect URL |
| `webhookUrl` | String | ✅ Yes | - | Backend webhook endpoint |
| `currency` | String | ⚙️ Optional | "BDT" | Currency code |
| `metadata` | Map | ⚙️ Optional | `{}` | Custom data |

**V2 API Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `fullName` | String | ✅ Yes | - | Customer's full name |
| `emailOrMobile` | String | ✅ Yes | - | Email OR mobile number |
| `amount` | String | ✅ Yes | - | Payment amount |
| `redirectUrl` | String | ✅ Yes | - | Success redirect URL |
| `webhookUrl` | String | ✅ Yes | - | Backend webhook endpoint |
| `cancelUrl` | String | ⚙️ Optional | - | Cancel redirect URL |
| `currency` | String | ⚙️ Optional | "BDT" | Currency code |
| `returnType` | String | ⚙️ Optional | "POST" | Return method (POST/GET) |
| `orderId` | String | ⚙️ Optional | - | Custom order identifier |
| `metadata` | Map | ⚙️ Optional | `{}` | Custom data |

**Returns:** `CreateChargeResponseV3` (V3+) or `CreateChargeResponseV2` (V2)

#### `verifyPayment()`
Verifies payment status using transaction ID.

**Parameters:**

| Parameter | Type | Required | API Version | Description |
|-----------|------|----------|-------------|-------------|
| `ppId` | String | ✅ Yes | V3+ | Payment reference (pp_id) |
| `transactionId` | String | ✅ Yes | V2 | Transaction ID (V2 legacy) |

**Returns:** `VerifyPaymentResponseV3` (V3+) or `VerifyPaymentResponseV2` (V2)

#### `refundPayment()`
Processes refund for completed payment.

**Parameters:**

| Parameter | Type | Required | API Version | Description |
|-----------|------|----------|-------------|-------------|
| `ppId` | String | ✅ Yes | V3+ | Payment reference (pp_id) to refund |
| `transactionId` | String | ✅ Yes | V2 | Transaction ID to refund (V2) |

**Returns:** `RefundPaymentResponseV3` (V3+) or dynamic (V2)

#### `validateWebhook()`
Validates webhook payload and signature.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `payload` | String | ✅ Yes | Raw JSON string from webhook request body |
| `receivedApiKey` | String | ✅ Yes | API key from `mh-piprapay-api-key` header |

**Returns:** `WebhookPayloadV3` (V3+) or `WebhookPayload` (V2)

#### Helper Methods

**`extractCheckoutUrl()`** - Extract payment URL from createCharge response

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `createResponse` | dynamic | ✅ Yes | Response from `createCharge()` |

**Returns:** `String?` - Payment/checkout URL or null

```dart
String? url = piprapay.extractCheckoutUrl(charge);
```

---

**`extractPaymentReference()`** - Extract payment reference (pp_id or transaction_id)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `createResponse` | dynamic | ✅ Yes | Response from `createCharge()` |

**Returns:** `String?` - Payment reference or null

```dart
String? ppId = piprapay.extractPaymentReference(charge);
```

---

**`isSuccessfulStatus()`** - Check if payment status indicates success

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | String | ✅ Yes | Payment status from verification |

**Returns:** `bool` - true if status is 'completed'

```dart
bool isSuccess = piprapay.isSuccessfulStatus(status);
```

---

**`isFailedStatus()`** - Check if payment status indicates failure

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | String | ✅ Yes | Payment status from verification |

**Returns:** `bool` - true if status is 'failed', 'cancelled', 'expired', or 'rejected'

```dart
bool isFailed = piprapay.isFailedStatus(status);
```

---

## 🐛 Troubleshooting

### "Invalid API Key" Error
```
✗ Verify API key is correct
✗ Check if API key has required permissions
✗ Ensure API key matches environment (sandbox/production)
✗ Regenerate API key in Piprapay dashboard
```

### "Request Timeout" Error
```
✗ Check network connectivity
✗ Verify backend service is running
✗ Increase timeout: timeout: Duration(seconds: 90)
✗ Check for network proxy/firewall issues
```

### "Invalid Email or Mobile" Error
```
✗ Validate input format before sending
✗ Use PiprapayUtils validators
✗ Check phone number includes country code
✗ Ensure email format is valid
```

### Webhook Not Received
```
✗ Verify webhook URL is publicly accessible
✗ Ensure webhook URL uses HTTPS
✗ Check API key in webhook headers
✗ Verify server logs for errors
✗ Test webhook endpoint manually
```

### Payment Verification Fails
```
✗ Verify transaction ID (pp_id) is correct
✗ Wait a few seconds after payment completion
✗ Check payment status in Piprapay dashboard
✗ Verify API key has verification permissions
✗ Check network connectivity
```

---

## 📖 Documentation

- **[Piprapay Official Docs](https://piprapay.readme.io/reference)**
- **[API Documentation](https://piprapay.com/api-docs)**
- **[GitHub Repository](https://github.com/programmingwormhole/piprapay-flutter)**
- **[Issue Tracker](https://github.com/programmingwormhole/piprapay-flutter/issues)**

---

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and updates.

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Setup

```bash
# Clone repository
git clone https://github.com/programmingwormhole/piprapay-flutter.git
cd piprapay-flutter

# Get dependencies
flutter pub get

# Run tests
flutter test

# Run example app
cd example
flutter run
```

---

## 📄 License

This package is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 About the Developer

**Md Shirajul Islam**

A passionate Flutter developer dedicated to building professional, production-ready payment solutions for the Bangladeshi fintech ecosystem.

### Connect with Me

- **GitHub:** [github.com/programmingwormhole](https://github.com/programmingwormhole)
- **YouTube:** [youtube.com/@programmingwormhole](https://youtube.com/@programmingwormhole)
- **Facebook:** [facebook.com/no.name.virus](https://facebook.com/no.name.virus)
- **Email:** programmingwormhole@gmail.com

---

## 🙏 Support

If you found this package helpful:
- ⭐ Star the repository on GitHub
- 📤 Share with your developer friends
- 🐛 Report issues and suggest improvements
- 💬 Contribute code and documentation

---

## � Quick Reference

### All Methods & Parameters Summary

#### Initialization Methods

| Method | Required Parameters | Optional Parameters | Returns |
|--------|---------------------|---------------------|---------|
| `PiprapayService.sandbox()` | `apiKey` | `panelVersion`, `enableLogging`, `timeout` | PiprapayService |
| `PiprapayService.production()` | `apiKey`, `baseUrl` | `panelVersion`, `enableLogging`, `timeout` | PiprapayService |

#### Payment Methods

| Method | Required (V3+) | Required (V2) | Optional | Returns |
|--------|----------------|---------------|----------|---------|
| `createCharge()` | `fullName`, `emailAddress`, `mobileNumber`, `amount`, `returnUrl`, `webhookUrl` | `fullName`, `emailOrMobile`, `amount`, `redirectUrl`, `webhookUrl` | `currency`, `metadata`, `cancelUrl` (V2), `returnType` (V2), `orderId` (V2) | CreateChargeResponse |
| `verifyPayment()` | `ppId` | `transactionId` | - | VerifyPaymentResponse |
| `refundPayment()` | `ppId` | `transactionId` | - | RefundPaymentResponse |
| `validateWebhook()` | `payload`, `receivedApiKey` | `payload`, `receivedApiKey` | - | WebhookPayload |

#### Helper Methods

| Method | Required Parameters | Returns | Description |
|--------|---------------------|---------|-------------|
| `extractCheckoutUrl()` | `createResponse` | String? | Extract payment URL |
| `extractPaymentReference()` | `createResponse` | String? | Extract pp_id/transaction_id |
| `isSuccessfulStatus()` | `status` | bool | Check if status is "completed" |
| `isFailedStatus()` | `status` | bool | Check if status is failed/cancelled/expired |

#### UI Methods (WebView)

| Method | Required Parameters | Optional Parameters | Returns | Description |
|--------|---------------------|---------------------|---------|-------------|
| `PiprapayWebView.executePayment()` | `context`, `paymentUrl` | `successPageDisplayDuration`, `appBarTitle` | PaymentResult? | Execute payment in built-in WebView |

#### Utility Methods (PiprapayUtils)

| Method | Required Parameters | Returns | Description |
|--------|---------------------|---------|-------------|
| `isValidEmail()` | `email` | bool | Validate email format |
| `isValidMobileNumber()` | `mobile` | bool | Validate mobile number |
| `isValidEmailOrMobile()` | `input` | bool | Validate email OR mobile |
| `isPaymentCompleted()` | `status` | bool | Check if payment completed |
| `validateWebhookApiKey()` | `receivedApiKey`, `expectedApiKey` | bool | Validate webhook API key |

### Initialization Quick Reference

```dart
// V3+ Sandbox with logging (Development)
final piprapay = PiprapayService.sandbox(
  apiKey: 'pk_sandbox_key',
  panelVersion: PanelVersion.v3plus,  // ⚙️ Optional
  enableLogging: true,                 // ⚙️ Optional - Helps debugging
);

// V3+ Production (Live)
final piprapay = PiprapayService.production(
  apiKey: 'pk_live_key',
  baseUrl: 'https://api.piprapay.com/api',
  panelVersion: PanelVersion.v3plus,  // ⚙️ Optional
  enableLogging: false,                // ⚙️ Optional - Disable in production
);

// V2 Legacy Support
final piprapay = PiprapayService.sandbox(
  apiKey: 'pk_sandbox_key',
  panelVersion: PanelVersion.v2,      // For V2 API
);
```

### Payment Flow Quick Reference

```dart
// 1. Create Charge (V3+)
final charge = await piprapay.createCharge(
  fullName: 'Name',             // ✅ Required
  emailAddress: 'email@x.com',  // ✅ Required
  mobileNumber: '+880170...',   // ✅ Required
  amount: '100',                // ✅ Required
  returnUrl: 'https://...',     // ✅ Required
  webhookUrl: 'https://...',    // ✅ Required
  currency: 'BDT',              // ⚙️ Optional
  metadata: {},                 // ⚙️ Optional
);

// 2. Extract Payment URL
String url = piprapay.extractCheckoutUrl(charge)!;

// 3. Execute payment in built-in WebView
final result = await PiprapayWebView.executePayment(
  context,
  paymentUrl: url,              // ✅ Required
  successPageDisplayDuration: Duration(seconds: 2), // ⚙️ Optional
);

// 4. Verify Payment (if successful)
if (result?.isSuccess == true) {
  final verification = await piprapay.verifyPayment(
    ppId: result!.transactionRef!,  // ✅ Required (V3+)
  );
  
  // 5. Check Status
  if (piprapay.isSuccessfulStatus(verification.status)) {
    // Payment successful - update your database
  }
}

// 6. Refund (if needed)
final refund = await piprapay.refundPayment(
  ppId: 'pp_id_value',          // ✅ Required (V3+)
);
```

---

## �🚀 Quick Links

| Link | Purpose |
|------|---------|
| [GitHub Repository](https://github.com/programmingwormhole/piprapay-flutter) | Source code and issue tracking |
| [pub.dev Package](https://pub.dev/packages/piprapay) | Package page and version history |
| [Piprapay Official](https://piprapay.com) | Piprapay payment gateway website |
| [API Documentation](https://piprapay.readme.io) | Official Piprapay API docs |

---

<div align="center">

**Made with ❤️ by [Md Shirajul Islam](https://github.com/programmingwormhole)**

*Professional • Secure • Easy to Use • Production Ready*

[⬆ Back to Top](#-piprapay-flutter-package)

</div>

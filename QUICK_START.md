# Piprapay Flutter Package - Quick Start

Get started with Piprapay payment integration in 5 minutes!

## 1. Install Package

```bash
flutter pub add piprapay
```

## 2. Initialize Service

```dart
import 'package:piprapay/piprapay.dart';

// Create service instance
final piprapay = PiprapayService.sandbox(
  apiKey: 'your_api_key',
);
```

## 3. Create Payment

```dart
try {
  final charge = await piprapay.createCharge(
    fullName: 'John Doe',
    emailOrMobile: 'john@example.com',
    amount: '100.00',
    metadata: {'order_id': '12345'},
    redirectUrl: 'https://yourapp.com/success',
    cancelUrl: 'https://yourapp.com/cancel',
    webhookUrl: 'https://yourapp.com/webhook',
  );

  print('Invoice ID: ${charge.invoiceId}');
  // Navigate user to charge.paymentUrl
} catch (e) {
  print('Error: $e');
}
```

## 4. Verify Payment

```dart
try {
  final verification = await piprapay.verifyPayment(
    transactionId: ppId,
  );

  if (verification.isCompleted) {
    print('Payment successful!');
  }
} catch (e) {
  print('Error: $e');
}
```

## 5. Clean Up

```dart
@override
void dispose() {
  piprapay.dispose();
  super.dispose();
}
```

## Next Steps

- Read [README.md](README.md) for detailed documentation
- Check [SETUP_GUIDE.md](SETUP_GUIDE.md) for configuration
- Review [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for full API reference
- Explore [example/](example/) directory for complete app example

## Common Tasks

### Output Payment Form

```dart
// Show payment in WebView
showDialog(
  context: context,
  builder: (context) => Dialog(
    child: WebView(
      initialUrl: charge.paymentUrl!,
    ),
  ),
);
```

### Handle Webhook

```dart
// In your backend
app.post('/webhook', (req, res) => {
  const webhook = await piprapay.validateWebhook(
    payload: req.body,
    receivedApiKey: req.headers['mh-piprapay-api-key'],
  );
  // Process payment
});
```

### Refund Payment

```dart
final refund = await piprapay.refundPayment(
  transactionId: ppId,
);

if (refund.isSuccessful) {
  print('Refund processed!');
}
```

## Error Handling

```dart
try {
  await piprapay.createCharge(...);
} on PiprapayAuthException {
  // Invalid API key
} on PiprapayRequestException catch (e) {
  // Invalid request
  print('Status: ${e.statusCode}');
} on PiprapayNetworkException {
  // Network error
} on PiprapayException catch (e) {
  // Other errors
  print('Error: ${e.message}');
}
```

## Environment Variables

```bash
# .env file
PIPRAPAY_API_KEY=your_key
PIPRAPAY_ENV=sandbox
```

## Validation Utilities

```dart
// Validate email
if (PiprapayUtils.isValidEmail(email)) { }

// Validate mobile
if (PiprapayUtils.isValidMobileNumber(mobile)) { }

// Check payment status
if (PiprapayUtils.isPaymentCompleted(status)) { }
```

---

**Need help?** Check [API_DOCUMENTATION.md](API_DOCUMENTATION.md) or visit [piprapay.readme.io](https://piprapay.readme.io)

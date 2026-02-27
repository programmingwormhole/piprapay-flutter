# Piprapay Flutter Package - Setup Guide

## Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- A Piprapay merchant account
- API Key from Piprapay dashboard

## Installation Steps

### 1. Get Your API Key

1. Log in to [Piprapay Dashboard](https://piprapay.com/dashboard)
2. Navigate to **Developer** > **API Keys**
3. Generate a new API key
4. Keep it secure (never share or commit to version control)

### 2. Add Package to Your Project

Update your `pubspec.yaml`:

```yaml
dependencies:
  piprapay: ^1.0.0
```

Run:
```bash
flutter pub get
```

### 3. Generate Code (if using models)

Generate JSON serialization code:

```bash
flutter pub run build_runner build
```

For watch mode:
```bash
flutter pub run build_runner watch
```

### 4. Import in Your App

```dart
import 'package:piprapay/piprapay.dart';
```

## Environment Setup

### Development (Sandbox)

```dart
final piprapay = PiprapayService.sandbox(
  apiKey: 'your_sandbox_api_key',
);
```

### Production

```dart
final piprapay = PiprapayService.production(
  apiKey: 'your_production_api_key',
);
```

### Using Environment Variables

Create `.env` file (add to `.gitignore`):

```
PIPRAPAY_API_KEY=your_api_key
PIPRAPAY_ENV=sandbox
```

In your code:

```dart
const apiKey = String.fromEnvironment('PIPRAPAY_API_KEY');
const env = String.fromEnvironment('PIPRAPAY_ENV', defaultValue: 'sandbox');

final piprapay = env == 'production'
    ? PiprapayService.production(apiKey: apiKey)
    : PiprapayService.sandbox(apiKey: apiKey);
```

Run with:
```bash
flutter run --dart-define=PIPRAPAY_API_KEY=your_key --dart-define=PIPRAPAY_ENV=sandbox
```

## Configuration

### Custom Timeout

```dart
final piprapay = PiprapayService(
  apiKey: apiKey,
  timeout: Duration(seconds: 60),
);
```

### Custom Base URL

```dart
final piprapay = PiprapayService(
  apiKey: apiKey,
  baseUrl: 'https://custom.piprapay.com/api',
);
```

## Project Structure

Recommended folder structure for using Piprapay:

```
lib/
├── models/
│   └── payment_model.dart
├── services/
│   └── payment_service.dart
├── screens/
│   ├── payment_screen.dart
│   └── success_screen.dart
├── utils/
│   └── app_config.dart
└── main.dart
```

### Example Service Wrapper

Create `lib/services/payment_service.dart`:

```dart
import 'package:piprapay/piprapay.dart';

class PaymentService {
  late final PiprapayService _piprapay;

  PaymentService({required String apiKey}) {
    _piprapay = PiprapayService.sandbox(apiKey: apiKey);
  }

  Future<CreateChargeResponse> createPayment({
    required String fullName,
    required String email,
    required String amount,
  }) async {
    return _piprapay.createCharge(
      fullName: fullName,
      emailOrMobile: email,
      amount: amount,
      metadata: {'timestamp': DateTime.now().toString()},
      redirectUrl: 'https://myapp.com/success',
      cancelUrl: 'https://myapp.com/cancel',
      webhookUrl: 'https://myapi.com/webhook',
    );
  }

  void dispose() {
    _piprapay.dispose();
  }
}
```

## Webhook Setup

### Local Testing with ngrok

1. Install [ngrok](https://ngrok.com/)
2. Start your backend server on port 3000
3. Run ngrok: `ngrok http 3000`
4. Update webhook URL in Piprapay dashboard with ngrok URL

### Node.js Backend Example

```javascript
const express = require('express');
const app = express();

app.use(express.json());

app.post('/webhook', (req, res) => {
  const apiKey = req.headers['mh-piprapay-api-key'];
  
  if (apiKey !== process.env.PIPRAPAY_API_KEY) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const { pp_id, status, amount } = req.body;
  
  console.log(`Payment ${pp_id} ${status} for ${amount}`);
  
  res.json({ status: true, message: 'Webhook received' });
});

app.listen(3000, () => console.log('Server running on port 3000'));
```

### Django Backend Example

```python
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
import json

@require_http_methods(["POST"])
def webhook(request):
    api_key = request.META.get('HTTP_MHS_PIPRAPAY_API_KEY')
    expected_key = os.getenv('PIPRAPAY_API_KEY')
    
    if api_key != expected_key:
        return JsonResponse({'error': 'Unauthorized'}, status=401)
    
    data = json.loads(request.body)
    pp_id = data.get('pp_id')
    status = data.get('status')
    
    # Process payment
    print(f'Payment {pp_id} {status}')
    
    return JsonResponse({'status': True, 'message': 'Webhook received'})
```

## Testing

### Unit Tests

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/piprapay_test.dart
```

### Integration Tests

Add to `pubspec.yaml`:

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

Run:
```bash
flutter test integration_test/piprapay_integration_test.dart
```

### Manual Testing

Use the example app:

```bash
cd example
flutter run
```

## Build for Production

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## Troubleshooting

### Import Error
```
Error: Unable to locate Dart function
```

Solution: Run `flutter pub get` and restart your IDE.

### JSON Serialization Error
```
Error: Could not find generated file
```

Solution: Run `flutter pub run build_runner build`

### API Key Error
```
PiprapayAuthException: Unauthorized
```

Solution: 
- Verify API key is correct
- Check if using correct environment (sandbox/production)
- Regenerate key in dashboard

### Timeout Error
```
PiprapayNetworkException: Request timeout
```

Solution:
- Increase timeout duration
- Check internet connection
- Verify Piprapay servers are operational

## Security Checklist

- [ ] API key stored securely (not in code)
- [ ] Use HTTPS for all URLs
- [ ] Validate webhook API key
- [ ] Implement proper error handling
- [ ] Log sensitive data carefully
- [ ] Test with sandbox first
- [ ] Use production API key only when ready
- [ ] Implement webhook verification
- [ ] Keep package updated

## NextSteps

1. Read [README.md](README.md) for feature overview
2. Check [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for detailed API reference
3. Review example app in `example/` directory
4. Implement payment flow in your app
5. Set up webhook handler
6. Test with sandbox account
7. Go live!

## Support

- Piprapay Documentation: https://piprapay.readme.io
- GitHub Issues: https://github.com/yourusername/piprapay-flutter/issues
- Piprapay Support: https://piprapay.com/support

## Additional Resources

- [Flutter Documentation](https://flutter.dev)
- [Dart Documentation](https://dart.dev)
- [HTTP Package Docs](https://pub.dev/packages/http)
- [JSON Serialization Guide](https://flutter.dev/docs/development/data-and-backend/json)

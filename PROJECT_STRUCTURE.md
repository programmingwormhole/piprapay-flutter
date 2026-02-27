# Piprapay Flutter Package - Project Structure

## Complete Package Overview

This is a professional, production-ready Flutter package for Piprapay payment gateway integration.

## Directory Structure

```
piprapay/
├── lib/
│   ├── piprapay.dart                    # Main package export
│   └── src/
│       ├── models/
│       │   ├── index.dart
│       │   └── piprapay_models.dart    # All data models
│       ├── services/
│       │   ├── index.dart
│       │   ├── piprapay_service.dart  # Main API service
│       │   └── http_client.dart       # HTTP client
│       ├── exceptions/
│       │   ├── index.dart
│       │   └── piprapay_exceptions.dart # Custom exceptions
│       └── utils/
│           ├── index.dart
│           └── piprapay_utils.dart    # Utility functions
├── example/
│   ├── lib/
│   │   ├── main.dart                    # Example app entry
│   │   ├── screens/
│   │   │   └── home_screen.dart        # Payment UI
│   │   └── services/
│   │       └── payment_service.dart    # Service wrapper
│   └── pubspec.yaml
├── test/
│   └── piprapay_test.dart              # Unit tests
├── pubspec.yaml                         # Package definition
├── analysis_options.yaml                # Linting configuration
├── .gitignore                           # Git ignore rules
├── README.md                            # Main documentation
├── CHANGELOG.md                         # Version history
├── LICENSE                              # MIT License
├── API_DOCUMENTATION.md                 # Detailed API docs
├── SETUP_GUIDE.md                       # Setup instructions
├── QUICK_START.md                       # Quick start guide
└── CONTRIBUTING.md                      # Contribution guidelines
```

## Package Features

### Core Components

#### Models (`lib/src/models/`)
- `CreateChargeRequest` - Payment creation request
- `CreateChargeResponse` - Payment creation response
- `VerifyPaymentRequest` - Payment verification request
- `VerifyPaymentResponse` - Payment details and status
- `RefundPaymentRequest` - Refund request
- `RefundPaymentResponse` - Refund status
- `WebhookPayload` - Webhook data model
- Enums: `PiprapayeCurrency`, `ReturnType`, `PaymentStatus`

#### Services (`lib/src/services/`)
- `PiprapayService` - Main API service with all operations
- `PiprapayHttpClient` - HTTP client with error handling
- Support for sandbox and production environments

#### Exceptions (`lib/src/exceptions/`)
- `PiprapayException` - Base exception
- `PiprapayAuthException` - Authentication errors
- `PiprapayRequestException` - Validation/request errors
- `PiprapayNetworkException` - Network errors
- `PiprapayPaymentException` - Payment errors
- `PiprapayWebhookException` - Webhook errors
- `PiprapayConfigException` - Configuration errors

#### Utilities (`lib/src/utils/`)
- Email validation
- Mobile number validation
- Payment status checking
- Webhook API key validation
- HMAC signature generation and validation
- Currency parsing
- Amount formatting

### Example App (`example/`)
- Complete Flutter app demonstrating all features
- Material Design 3 UI
- Payment creation form
- Payment verification
- Error handling examples
- Professional code structure

### Documentation
- **README.md** - Feature overview, quick start, advanced usage
- **API_DOCUMENTATION.md** - Detailed API reference for all classes
- **SETUP_GUIDE.md** - Installation and configuration instructions
- **QUICK_START.md** - 5-minute quick start
- **CONTRIBUTING.md** - Contributing guidelines
- **CHANGELOG.md** - Version history and future roadmap

### Testing
- Comprehensive unit tests covering:
  - Model serialization
  - Payment status identification
  - Validation utilities
  - Exception handling
  - Webhook processing

## API Endpoints

The package integrates with:
- `POST /api/create-charge` - Create payment
- `POST /api/verify-payment` - Verify payment status
- `POST /api/refund-payment` - Process refund
- `POST /webhook` - Webhook endpoint (for receiving notifications)

Supports:
- Sandbox: `https://sandbox.piprapay.com/api`
- Production: `https://api.piprapay.com/api`

## Key Features

✨ **Complete API Coverage**
- All payment operations supported
- Full webhook integration
- Real-time payment verification

🔒 **Security**
- API key authentication
- Webhook validation
- HMAC signature support
- HTTPS communication

📦 **Type Safety**
- Full null safety
- JSON serialization with `json_serializable`
- Type-safe models
- Enum support

⚙️ **Configuration**
- Sandbox and production environments
- Custom timeout settings
- Custom base URL support
- Custom HTTP client support

🎯 **Developer Experience**
- Intuitive API design
- Comprehensive error messages
- Input validation
- Detailed documentation
- Example app included

## Dependencies

**Core:**
- `flutter` (>=3.10.0)
- `dart` (>=3.0.0)
- `http` (^1.1.0)
- `json_annotation` (^4.8.1)
- `crypto` (^3.0.3)

**Development:**
- `build_runner` (^2.4.6)
- `json_serializable` (^6.7.1)
- `flutter_test` (Flutter SDK)
- `lints` (^3.0.0)
- `mocktail` (^1.0.0)

## Usage Pattern

```dart
// 1. Initialize
final piprapay = PiprapayService.sandbox(apiKey: apiKey);

// 2. Create payment
final charge = await piprapay.createCharge(...);

// 3. Redirect user to payment URL
// Navigate to charge.paymentUrl

// 4. Verify payment
final verification = await piprapay.verifyPayment(transactionId);

// 5. Handle webhook
final webhook = await piprapay.validateWebhook(payload, apiKey);

// 6. Clean up
piprapay.dispose();
```

## Error Handling

Specific exceptions for different scenarios:
- Authentication errors → `PiprapayAuthException`
- Request validation → `PiprapayRequestException`
- Network issues → `PiprapayNetworkException`
- Payment operations → `PiprapayPaymentException`
- Webhook validation → `PiprapayWebhookException`
- Configuration → `PiprapayConfigException`

## Testing

Run tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/piprapay_test.dart
```

With coverage:
```bash
flutter test --coverage
```

## Publishing

Ready for publication on pub.dev:
- ✅ All analysis passes
- ✅ Comprehensive documentation
- ✅ Example app included
- ✅ Tests included
- ✅ Linting configured
- ✅ Null safety enabled
- ✅ MIT License

## Code Quality

- **Null Safety**: 100% sound null safety
- **Formatting**: Dart format compliant
- **Linting**: Analysis options configured
- **Documentation**: Public APIs documented
- **Testing**: Unit tests included
- **Examples**: Complete example app

## Version Info

- **Version**: 1.0.0
- **Status**: Stable, Production-Ready
- **Flutter**: >=3.10.0
- **Dart**: >=3.0.0

## Getting Started

1. **Add to pubspec.yaml**
   ```yaml
   dependencies:
     piprapay: ^1.0.0
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Import and use**
   ```dart
   import 'package:piprapay/piprapay.dart';
   ```

4. **Read documentation**
   - Start with [QUICK_START.md](QUICK_START.md)
   - Then [README.md](README.md)
   - Deep dive with [API_DOCUMENTATION.md](API_DOCUMENTATION.md)

## Next Steps

1. [Quick Start](QUICK_START.md) - Get started in 5 minutes
2. [Setup Guide](SETUP_GUIDE.md) - Configure your environment
3. [API Documentation](API_DOCUMENTATION.md) - Learn the API
4. [Example App](example/) - See complete implementation
5. [Contributing](CONTRIBUTING.md) - Help improve the package

## Support

- 📚 [Documentation](README.md)
- 💬 GitHub Issues
- 🏢 [Piprapay Support](https://piprapay.com/support)
- 📖 [Piprapay API Docs](https://piprapay.readme.io)

---

**Professional. Secure. Production-Ready.** ✨

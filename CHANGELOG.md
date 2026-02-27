# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-27

### Added
- Initial release of Piprapay Flutter package
- Complete API integration:
  - Create payment charges
  - Verify payment status
  - Process refunds
  - Real-time webhook handling and validation
- Comprehensive error handling with specific exception types:
  - `PiprapayAuthException` for authentication errors
  - `PiprapayRequestException` for validation/request errors
  - `PiprapayNetworkException` for network errors
  - `PiprapayPaymentException` for payment-specific errors
  - `PiprapayWebhookException` for webhook errors
  - `PiprapayConfigException` for configuration errors
- Type-safe models with JSON serialization using `json_serializable`
- Support for sandbox and production environments
- Input validation utilities
- HMAC signature generation for enhanced security
- Webhook payload parsing and validation
- Configurable HTTP client with custom timeouts
- Well-documented with comprehensive example app
- Full null safety support
- Production-ready code structure

### Features
- `PiprapayService` - Main service class for all API operations
- `CreateChargeRequest/Response` - Payment creation models
- `VerifyPaymentRequest/Response` - Payment verification models
- `RefundPaymentRequest/Response` - Refund models
- `WebhookPayload` - Webhook data model
- `PiprapayUtils` - Utility methods for validation and security
- `PiprapayHttpClient` - HTTP client with error handling

### Documentation
- Comprehensive README with quick start guide
- Detailed API reference
- Error handling guide
- Webhook integration guide
- Best practices documentation
- Example Flutter app demonstrating all features

### Example App
- Home screen with payment form
- Payment creation demonstration
- Payment verification demonstration
- Complete error handling examples
- Material Design 3 UI

### Testing
- Unit test examples
- Input validation tests
- Error handling tests

---

## Versioning

- **1.0.0** - Initial stable release

## Future Roadmap

- [ ] Add async payment status polling
- [ ] Support for payment plan subscriptions
- [ ] Enhanced webhook security with HMAC signatures
- [ ] Payment analytics and reporting
- [ ] Multi-currency support enhancements
- [ ] Payment method filtering
- [ ] Bulk refund operations
- [ ] Webhook retry mechanism
- [ ] Payment dispute handling
- [ ] Advanced error logging and monitoring

## Known Issues

None at this time. Please report any issues on GitHub.

## Support

For support, please visit:
- GitHub Issues: https://github.com/yourusername/piprapay-flutter/issues
- Documentation: https://piprapay.readme.io
- Piprapay Support: https://piprapay.com/support

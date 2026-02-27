/// A professional Flutter package for integrating Piprapay payment gateway.
///
/// This package provides a complete solution for accepting payments via Piprapay,
/// including payment creation, verification, webhook handling, and refunds.
///
/// ## Getting Started
///
/// ```dart
/// import 'package:piprapay/piprapay.dart';
///
/// // Initialize the service
/// final piprapay = PiprapayService(
///   apiKey: 'your_api_key',
/// );
///
/// // Create a payment
/// final charge = await piprapay.createCharge(
///   fullName: 'John Doe',
///   emailOrMobile: 'john@example.com',
///   amount: '100',
///   metadata: {'order_id': '12345'},
///   redirectUrl: 'https://yourapp.com/success',
///   cancelUrl: 'https://yourapp.com/cancel',
///   webhookUrl: 'https://yourapp.com/webhook',
/// );
///
/// // Redirect user to payment gateway
/// // Navigate to charge.paymentUrl
///
/// // Verify payment after user returns
/// final verification = await piprapay.verifyPayment(
///   transactionId: ppId,
/// );
/// ```
///
/// ## Features
///
/// - Create payment charges
/// - Verify payment status
/// - Process refunds
/// - Handle webhooks
/// - Complete error handling
/// - Sandbox and production environments
/// - Full input validation

library piprapay;

// Models
export 'src/models/index.dart';

// Services
export 'src/services/index.dart';

// Exceptions
export 'src/exceptions/index.dart';

// Utils
export 'src/utils/index.dart';

// UI Components (WebView payment handler)
export 'src/ui/index.dart';

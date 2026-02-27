import 'package:flutter/material.dart';
import '../models/payment_result.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// WebView-based payment execution handler (built into Piprapay package)
/// 
/// This handler provides a complete WebView integration for in-app payment processing.
/// No need to implement WebView logic in your app - just call `executePayment()`!
///
/// Example usage:
/// ```dart
/// import 'package:piprapay/piprapay.dart';
/// 
/// final result = await PiprapayWebView.executePayment(
///   context: context,
///   paymentUrl: checkoutUrl,
/// );
/// 
/// if (result.isSuccess) {
///   // Verify payment
///   final verification = await piprapay.verifyPayment(ppId: result.transactionRef!);
/// }
/// ```
class PiprapayWebView {
  /// Execute payment in WebView and return the result
  /// 
  /// Parameters:
  /// - [context] ✅ Required - BuildContext for navigation
  /// - [paymentUrl] ✅ Required - Payment gateway URL from createCharge()
  /// - [successPageDisplayDuration] ⚙️ Optional - How long to show success page (default: 2 seconds)
  /// - [appBarTitle] ⚙️ Optional - Custom title for payment page (default: "Complete Payment")
  /// 
  /// Returns: [PaymentResult] with payment outcome (success/cancelled/failed)
  static Future<PaymentResult?> executePayment(
    BuildContext context, {
    required String paymentUrl,
    Duration successPageDisplayDuration = const Duration(seconds: 2),
    String appBarTitle = 'Complete Payment',
  }) async {
    return Navigator.of(context).push<PaymentResult?>(
      MaterialPageRoute(
        builder: (_) => _PaymentWebViewPage(
          url: paymentUrl,
          successPageDisplayDuration: successPageDisplayDuration,
          appBarTitle: appBarTitle,
        ),
      ),
    );
  }
}

/// Internal WebView page for payment processing
class _PaymentWebViewPage extends StatefulWidget {
  final String url;
  final Duration successPageDisplayDuration;
  final String appBarTitle;

  const _PaymentWebViewPage({
    required this.url,
    required this.successPageDisplayDuration,
    required this.appBarTitle,
  });

  @override
  State<_PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<_PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _outcomeDetected = false;

  @override
  void initState() {
    super.initState();
    print('🚀 WebView: Initializing with URL - ${widget.url}');
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('🌐 WebView: Page started loading - $url');
            if (mounted && !_outcomeDetected) {
              setState(() => _loading = true);

              // Check for cancel/fail outcomes early
              final outcome = _detectPaymentOutcome(url);
              if (outcome != null && !outcome.isSuccess) {
                print('❌ WebView: Detected non-success outcome - closing');
                _outcomeDetected = true;
                if (mounted) {
                  Navigator.pop(context, outcome);
                }
              } else if (outcome != null) {
                print('✅ WebView: Detected success outcome - will close after delay');
              } else {
                print('⏳ WebView: No outcome detected yet - continuing');
              }
            }
          },
          onPageFinished: (url) {
            print('🌐 WebView: Page finished loading - $url');
            if (mounted) {
              setState(() => _loading = false);

              // For success, wait until page fully loads
              if (!_outcomeDetected) {
                final outcome = _detectPaymentOutcome(url);
                if (outcome != null && outcome.isSuccess) {
                  print('✅ WebView: Success page loaded - closing after ${widget.successPageDisplayDuration.inSeconds}s');
                  _outcomeDetected = true;
                  
                  // Let user see success page and interact with buttons
                  Future.delayed(widget.successPageDisplayDuration, () {
                    if (mounted && _outcomeDetected) {
                      Navigator.pop(context, outcome);
                    }
                  });
                }
              }
            }
          },
          onWebResourceError: (error) {
            // Only handle critical navigation errors, not resource loading errors
            print('⚠️ WebView: Resource error - ${error.errorType}: ${error.description}');
            
            // Only close on critical errors (navigation failures, not resource failures)
            if (error.errorType == WebResourceErrorType.hostLookup ||
                error.errorType == WebResourceErrorType.connect ||
                error.errorType == WebResourceErrorType.timeout) {
              print('❌ WebView: Critical error detected - closing');
              if (mounted && !_outcomeDetected) {
                _outcomeDetected = true;
                Navigator.pop(
                  context,
                  PaymentResult.failed(
                    message: 'Failed to load payment page: ${error.description}',
                  ),
                );
              }
            } else {
              print('⚠️ WebView: Non-critical error - continuing');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    print('🗑️ WebView: Disposing - outcomeDetected: $_outcomeDetected');
    super.dispose();
  }

  /// Detect payment outcome from URL
  PaymentResult? _detectPaymentOutcome(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();
    final query = uri.query.toLowerCase();

    print('🔍 WebView: Checking URL for outcome');
    print('   Path: $path');
    print('   Query: $query');

    // Success detection
    if (path.contains('success') || query.contains('pp_status=completed')) {
      print('✅ WebView: SUCCESS pattern detected');
      // Extract transaction reference from query parameters
      final transactionRef = uri.queryParameters['transaction_ref'] ??
          uri.queryParameters['pp_id'] ??
          uri.queryParameters['transactionId'];
      return PaymentResult.success(transactionRef: transactionRef);
    }

    // Cancel detection
    if (path.contains('cancel') ||
        path.contains('cancelled') ||
        query.contains('status=cancelled') ||
        query.contains('status=cancel') ||
        query.contains('cancel')) {
      print('⚠️ WebView: CANCEL pattern detected');
      return PaymentResult.cancelled();
    }

    // Failure detection
    if (path.contains('fail') ||
        path.contains('error') ||
        query.contains('status=failed') ||
        query.contains('status=error')) {
      print('❌ WebView: FAIL pattern detected');
      final message = uri.queryParameters['message'] ?? 'Payment processing failed';
      return PaymentResult.failed(message: message);
    }

    print('⏳ WebView: No outcome pattern detected - payment in progress');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        print('🔙 WebView: PopScope invoked - didPop: $didPop, outcomeDetected: $_outcomeDetected');
        if (!didPop && !_outcomeDetected) {
          print('❌ WebView: User cancelled via back button');
          _outcomeDetected = true;
          Navigator.pop(context, PaymentResult.cancelled());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.appBarTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              print('❌ WebView: User cancelled via close button');
              if (!_outcomeDetected) {
                _outcomeDetected = true;
                Navigator.pop(context, PaymentResult.cancelled());
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

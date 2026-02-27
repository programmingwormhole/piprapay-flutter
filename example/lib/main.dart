import 'package:flutter/material.dart';
import 'package:piprapay/piprapay.dart';

void main() {
  runApp(const PiprapayExampleApp());
}

class PiprapayExampleApp extends StatelessWidget {
  const PiprapayExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piprapay Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PiprapayService _piprapay;
  
  final _fullNameController = TextEditingController(text: 'John Doe');
  final _emailController = TextEditingController(text: 'john@example.com');
  final _amountController = TextEditingController(text: '100');
  final _idController = TextEditingController();

  bool _isLoading = false;
  String _log = 'Ready';

  @override
  void initState() {
    super.initState();
    _piprapay = PiprapayService.production(
      apiKey: 'your_live_api_key_here',
      baseUrl: 'https://panelurl.com/api',
      panelVersion: PanelVersion.v3plus,
      enableLogging: true,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _amountController.dispose();
    _idController.dispose();
    _piprapay.dispose();
    super.dispose();
  }

  /// Execute complete payment checkout flow with WebView
  Future<void> _executePayment() async {
    setState(() {
      _isLoading = true;
      _log = 'Creating payment...';
    });

    try {
      // Step 1: Create payment charge
      final chargeResponse = await _piprapay.createCharge(
        fullName: _fullNameController.text,
        emailAddress: _emailController.text,
        mobileNumber: '8801700000000',
        amount: _amountController.text,
        currency: 'BDT',
        metadata: {
          'app': 'flutter_example',
          'timestamp': DateTime.now().toIso8601String(),
        },
        returnUrl: 'https://domain.com/success',
        webhookUrl: 'https://domain.com/webhook',
      );

      // Extract payment URL and ID
      final paymentUrl = _piprapay.extractCheckoutUrl(chargeResponse);
      final paymentId = _piprapay.extractPaymentReference(chargeResponse);

      if (paymentUrl == null || paymentUrl.isEmpty) {
        _showErrorSnackbar('❌ No payment URL received');
        setState(() {
          _log = 'Error: No payment URL in response';
        });
        return;
      }

      if (paymentId != null) {
        _idController.text = paymentId;
      }

      setState(() {
        _log = 'Opening payment gateway...';
      });

      if (!mounted) return;

      // Step 2: Open WebView and execute payment
      final result = await PiprapayWebView.executePayment(
        context,
        paymentUrl: paymentUrl,
      );

      if (!mounted) return;

      // Step 3: Handle payment result
      if (result == null) {
        throw PiprapayFailure.cancelled();
      }

      if (result.isCancelled) {
        throw PiprapayFailure.cancelled();
      }

      if (result.isFailed) {
        throw PiprapayFailure.failed(
          message: result.message ?? 'Payment failed',
          transactionId: result.transactionRef,
        );
      }

      // Success!
      _showSuccessSnackbar('✅ Payment Completed Successfully!');
      setState(() {
        _log = 'Payment Status: SUCCESS\n'
            'Transaction ID: ${result.transactionRef ?? 'N/A'}\n'
            'You can now verify the payment';
      });
    } on PiprapayFailure catch (e) {
      if (!mounted) return;

      if (e.isPaymentCancelled) {
        _showWarningSnackbar('⚠️ Payment Cancelled by User');
        setState(() {
          _log = 'Payment Status: CANCELLED\nYou cancelled the payment';
        });
      } else if (e.isPaymentFailed) {
        _showErrorSnackbar('❌ Payment Failed');
        setState(() {
          _log = 'Payment Status: FAILED\n'
              'Reason: ${e.message}\n'
              'Please try again';
        });
      } else {
        _showErrorSnackbar('❌ ${e.message}');
        setState(() {
          _log = 'Error: ${e.message}';
        });
      }
    } on PiprapayException catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('❌ API Error: ${e.message}');
      setState(() {
        _log = 'API Error: ${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('❌ Unexpected error: $e');
      setState(() {
        _log = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Verify payment status using payment ID
  Future<void> _verifyPayment() async {
    if (_idController.text.isEmpty) {
      _showWarningSnackbar('⚠️ Please enter a Payment ID first');
      return;
    }

    setState(() {
      _isLoading = true;
      _log = 'Verifying payment...';
    });

    try {
      final result = await _piprapay.verifyPayment(
        ppId: _idController.text,
        transactionId: _idController.text,
      );

      if (!mounted) return;

      String statusDisplay = 'UNKNOWN';
      if (result is VerifyPaymentResponseV3) {
        
        final status = result.status;
        final isSuccess = _piprapay.isSuccessfulStatus(status);
        final isFailed = _piprapay.isFailedStatus(status);
        statusDisplay = isSuccess ? 'SUCCESS ✅' : isFailed ? 'FAILED ❌' : 'PENDING ⏳';

        setState(() {
          _log = 'Status: $statusDisplay\n'
              'Status Code: $status\n'
              'PP ID: ${result.ppId}\n'
              'Amount: ${result.amount} ${result.currency}\n'
              'Gateway TXN: ${result.transactionId ?? 'N/A'}';
        });

        if (isSuccess) {
          _showSuccessSnackbar('✅ Payment Verified');
        } else if (isFailed) {
          _showErrorSnackbar('❌ Payment Failed');
        } else {
          _showWarningSnackbar('⏳ Payment Pending');
        }
      } else if (result is VerifyPaymentResponseV2) {
        final status = result.status ?? 'unknown';
        final isSuccess = _piprapay.isSuccessfulStatus(status);
        final isFailed = _piprapay.isFailedStatus(status);
        statusDisplay = isSuccess ? 'SUCCESS ✅' : isFailed ? 'FAILED ❌' : 'PENDING ⏳';

        setState(() {
          _log = 'Status: $statusDisplay\n'
              'Status Code: $status\n'
              'Transaction ID: ${result.transactionId ?? 'N/A'}\n'
              'Amount: ${result.amount ?? 'N/A'}';
        });

        if (isSuccess) {
          _showSuccessSnackbar('✅ Payment Verified');
        } else if (isFailed) {
          _showErrorSnackbar('❌ Payment Failed');
        } else {
          _showWarningSnackbar('⏳ Payment Pending');
        }
      }
    } on PiprapayException catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('❌ Verify Error: ${e.message}');
      setState(() {
        _log = 'Verify Error: ${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('❌ Error: $e');
      setState(() {
        _log = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Refund payment
  Future<void> _refundPayment() async {
    if (_idController.text.isEmpty) {
      _showWarningSnackbar('⚠️ Please enter a Payment ID first');
      return;
    }

    setState(() {
      _isLoading = true;
      _log = 'Refunding payment...';
    });

    try {
      final result = await _piprapay.refundPayment(
        ppId: _idController.text,
        transactionId: _idController.text,
      );

      if (!mounted) return;

      if (result is RefundPaymentResponseV3) {
        setState(() {
          _log = 'Refund Status: ${result.status}\n'
              'Message: ${result.message}\n'
              'Refund ID: ${result.refundId ?? 'N/A'}';
        });
        _showSuccessSnackbar('✅ Refund Processed');
      } else {
        setState(() {
          _log = 'Refund Response:\n$result';
        });
        _showSuccessSnackbar('✅ Refund Processed');
      }
    } on PiprapayException catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('❌ Refund Error: ${e.message}');
      setState(() {
        _log = 'Refund Error: ${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('❌ Error: $e');
      setState(() {
        _log = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showWarningSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piprapay Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Payment Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (BDT)',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Payment ID (from checkout)',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
              readOnly: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _executePayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Create & Execute Payment',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPayment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Verify Payment'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _refundPayment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Refund Payment'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Response',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _log,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

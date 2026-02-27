import 'package:flutter_test/flutter_test.dart';
import 'package:piprapay/piprapay.dart';

void main() {
  group('Models', () {
    group('CreateChargeRequest', () {
      test('should serialize to JSON correctly', () {
        final request = CreateChargeRequest(
          fullName: 'John Doe',
          emailOrMobile: 'john@example.com',
          amount: '100.00',
          metadata: {'order_id': '123'},
          redirectUrl: 'https://example.com/success',
          cancelUrl: 'https://example.com/cancel',
          webhookUrl: 'https://example.com/webhook',
          currency: 'BDT',
        );

        final json = request.toJson();

        expect(json['full_name'], 'John Doe');
        expect(json['email_mobile'], 'john@example.com');
        expect(json['amount'], '100.00');
        expect(json['currency'], 'BDT');
        expect(json['metadata'], {'order_id': '123'});
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'full_name': 'Jane Doe',
          'email_mobile': 'jane@example.com',
          'amount': '200.00',
          'metadata': {'product_id': '456'},
          'redirect_url': 'https://example.com/success',
          'cancel_url': 'https://example.com/cancel',
          'webhook_url': 'https://example.com/webhook',
          'currency': 'BDT',
        };

        final request = CreateChargeRequest.fromJson(json);

        expect(request.fullName, 'Jane Doe');
        expect(request.emailOrMobile, 'jane@example.com');
        expect(request.amount, '200.00');
      });
    });

    group('VerifyPaymentResponse', () {
      test('should identify completed payment correctly', () {
        final response = VerifyPaymentResponse(
          transactionId: '123',
          customerName: 'John',
          customerEmailOrMobile: 'john@example.com',
          paymentMethod: 'bKash',
          amount: '100',
          fee: '0',
          refundAmount: '0',
          total: 100,
          currency: 'BDT',
          status: 'completed',
          date: '2026-02-27 10:00:00',
        );

        expect(response.isCompleted, true);
        expect(response.isPending, false);
        expect(response.isFailed, false);
        expect(response.isRefunded, false);
      });

      test('should identify pending payment correctly', () {
        final response = VerifyPaymentResponse(
          transactionId: '123',
          customerName: 'John',
          customerEmailOrMobile: 'john@example.com',
          paymentMethod: 'bKash',
          amount: '100',
          fee: '0',
          refundAmount: '0',
          total: 100,
          currency: 'BDT',
          status: 'pending',
          date: '2026-02-27 10:00:00',
        );

        expect(response.isPending, true);
        expect(response.isCompleted, false);
      });

      test('should identify failed payment correctly', () {
        final response = VerifyPaymentResponse(
          transactionId: '123',
          customerName: 'John',
          customerEmailOrMobile: 'john@example.com',
          paymentMethod: 'bKash',
          amount: '100',
          fee: '0',
          refundAmount: '0',
          total: 100,
          currency: 'BDT',
          status: 'failed',
          date: '2026-02-27 10:00:00',
        );

        expect(response.isFailed, true);
        expect(response.isCompleted, false);
      });

      test('should identify refunded payment correctly', () {
        final response = VerifyPaymentResponse(
          transactionId: '123',
          customerName: 'John',
          customerEmailOrMobile: 'john@example.com',
          paymentMethod: 'bKash',
          amount: '100',
          fee: '0',
          refundAmount: '100',
          total: 0,
          currency: 'BDT',
          status: 'refunded',
          date: '2026-02-27 10:00:00',
        );

        expect(response.isRefunded, true);
        expect(response.isCompleted, false);
      });
    });

    group('RefundPaymentResponse', () {
      test('should identify successful refund', () {
        final response = RefundPaymentResponse(
          status: 'success',
          transactionId: '123',
          refundAmount: '100',
        );

        expect(response.isSuccessful, true);
      });

      test('should identify failed refund', () {
        final response = RefundPaymentResponse(
          status: 'failed',
          message: 'Refund failed',
        );

        expect(response.isSuccessful, false);
      });
    });

    group('WebhookPayload', () {
      test('should deserialize from JSON correctly', () {
        final json = {
          'pp_id': '181055228',
          'customer_name': 'Demo',
          'customer_email_mobile': 'demo@gmail.com',
          'payment_method': 'bKash Personal',
          'amount': '10',
          'fee': '0',
          'refund_amount': '0',
          'total': 10,
          'currency': 'BDT',
          'status': 'completed',
          'date': '2026-02-27 13:34:13',
          'metadata': {'invoiceid': 'uouyo'},
        };

        final payload = WebhookPayload.fromJson(json);

        expect(payload.transactionId, '181055228');
        expect(payload.customerName, 'Demo');
        expect(payload.paymentMethod, 'bKash Personal');
        expect(payload.status, 'completed');
      });
    });
  });

  group('PiprapayUtils', () {
    group('Email Validation', () {
      test('should validate correct email', () {
        expect(
          PiprapayUtils.isValidEmail('test@example.com'),
          true,
        );
      });

      test('should reject invalid email without @', () {
        expect(
          PiprapayUtils.isValidEmail('testexample.com'),
          false,
        );
      });

      test('should reject invalid email without domain', () {
        expect(
          PiprapayUtils.isValidEmail('test@'),
          false,
        );
      });

      test('should reject empty email', () {
        expect(
          PiprapayUtils.isValidEmail(''),
          false,
        );
      });
    });

    group('Mobile Validation', () {
      test('should validate correct mobile number', () {
        expect(
          PiprapayUtils.isValidMobileNumber('8801700000000'),
          true,
        );
      });

      test('should validate mobile with + prefix', () {
        expect(
          PiprapayUtils.isValidMobileNumber('+8801700000000'),
          true,
        );
      });

      test('should reject short mobile number', () {
        expect(
          PiprapayUtils.isValidMobileNumber('1234'),
          false,
        );
      });

      test('should reject empty mobile', () {
        expect(
          PiprapayUtils.isValidMobileNumber(''),
          false,
        );
      });
    });

    group('Email or Mobile Validation', () {
      test('should accept valid email', () {
        expect(
          PiprapayUtils.isValidEmailOrMobile('test@example.com'),
          true,
        );
      });

      test('should accept valid mobile', () {
        expect(
          PiprapayUtils.isValidEmailOrMobile('8801700000000'),
          true,
        );
      });

      test('should reject invalid input', () {
        expect(
          PiprapayUtils.isValidEmailOrMobile('invalid input'),
          false,
        );
      });
    });

    group('Payment Status Checks', () {
      test('should identify completed status', () {
        expect(
          PiprapayUtils.isPaymentCompleted('completed'),
          true,
        );
      });

      test('should identify failed status', () {
        expect(
          PiprapayUtils.isPaymentFailed('failed'),
          true,
        );
      });

      test('should identify pending status', () {
        expect(
          PiprapayUtils.isPaymentPending('pending'),
          true,
        );
      });

      test('should identify refunded status', () {
        expect(
          PiprapayUtils.isPaymentRefunded('refunded'),
          true,
        );
      });

      test('should be case insensitive', () {
        expect(
          PiprapayUtils.isPaymentCompleted('COMPLETED'),
          true,
        );
      });
    });

    group('Webhook API Key Validation', () {
      test('should validate matching API keys', () {
        expect(
          PiprapayUtils.validateWebhookApiKey(
            receivedApiKey: 'test_api_key',
            expectedApiKey: 'test_api_key',
          ),
          true,
        );
      });

      test('should reject mismatched API keys', () {
        expect(
          PiprapayUtils.validateWebhookApiKey(
            receivedApiKey: 'test_api_key_1',
            expectedApiKey: 'test_api_key_2',
          ),
          false,
        );
      });

      test('should be case insensitive', () {
        expect(
          PiprapayUtils.validateWebhookApiKey(
            receivedApiKey: 'TEST_API_KEY',
            expectedApiKey: 'test_api_key',
          ),
          true,
        );
      });
    });

    group('HMAC Signature', () {
      test('should generate signature', () {
        final signature = PiprapayUtils.generateHmacSignature(
          payload: 'test payload',
          secretKey: 'secret',
        );

        expect(signature, isNotEmpty);
        expect(signature.length, 64); // SHA256 hex is 64 chars
      });

      test('should validate correct signature', () {
        const payload = 'test payload';
        const secretKey = 'secret';

        final signature = PiprapayUtils.generateHmacSignature(
          payload: payload,
          secretKey: secretKey,
        );

        expect(
          PiprapayUtils.validateHmacSignature(
            payload: payload,
            signature: signature,
            secretKey: secretKey,
          ),
          true,
        );
      });

      test('should reject incorrect signature', () {
        expect(
          PiprapayUtils.validateHmacSignature(
            payload: 'test payload',
            signature: 'invalid_signature',
            secretKey: 'secret',
          ),
          false,
        );
      });
    });

    group('Currency Parsing', () {
      test('should parse valid currency', () {
        expect(
          PiprapayUtils.parseCurrency('bdt'),
          'BDT',
        );
      });

      test('should handle null currency', () {
        expect(
          PiprapayUtils.parseCurrency(null),
          'BDT',
        );
      });

      test('should handle empty currency', () {
        expect(
          PiprapayUtils.parseCurrency(''),
          'BDT',
        );
      });
    });

    group('Amount Formatting', () {
      test('should format integer amount', () {
        expect(
          PiprapayUtils.formatAmount(100),
          '100',
        );
      });

      test('should format decimal amount', () {
        expect(
          PiprapayUtils.formatAmount(100.50),
          '100.5',
        );
      });
    });

    group('API Key Validation', () {
      test('should accept valid API key', () {
        expect(
          PiprapayUtils.isValidApiKey('test_api_key_12345'),
          true,
        );
      });

      test('should reject short API key', () {
        expect(
          PiprapayUtils.isValidApiKey('short'),
          false,
        );
      });

      test('should reject empty API key', () {
        expect(
          PiprapayUtils.isValidApiKey(''),
          false,
        );
      });
    });
  });

  group('Exceptions', () {
    test('PiprapayException toString', () {
      final exception = PiprapayException(
        message: 'Test error',
      );

      expect(
        exception.toString(),
        'PiprapayException: Test error',
      );
    });

    test('PiprapayAuthException toString', () {
      final exception = PiprapayAuthException(
        message: 'Invalid API key',
      );

      expect(
        exception.toString(),
        'PiprapayAuthException: Invalid API key',
      );
    });

    test('PiprapayRequestException with status code', () {
      final exception = PiprapayRequestException(
        message: 'Bad request',
        statusCode: 400,
      );

      expect(
        exception.toString(),
        contains('400'),
      );
    });

    test('PiprapayPaymentException with transaction ID', () {
      final exception = PiprapayPaymentException(
        message: 'Payment failed',
        transactionId: '123',
      );

      expect(
        exception.toString(),
        contains('123'),
      );
    });
  });
}

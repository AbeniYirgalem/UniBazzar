import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

/// Lightweight client for Chapa's public REST API.
///
/// This runs entirely on-device (test mode only). In production you should
/// route through a trusted backend to avoid leaking your secret key.
class ChapaService {
  ChapaService({
    required this.secretKey,
    http.Client? client,
    this.defaultCurrency = 'ETB',
    this.defaultCallbackUrl = _fallbackCallback,
    this.defaultReturnUrl = _fallbackReturn,
  }) : client = client ?? http.Client();

  final http.Client client;
  final String secretKey;
  final String defaultCurrency;
  final String defaultCallbackUrl;
  final String defaultReturnUrl;

  static const _baseUrl = 'https://api.chapa.co/v1/transaction/initialize';
  static const _fallbackCallback = 'https://example.com/chapa/callback';
  static const _fallbackReturn = 'https://example.com/chapa/return';

  /// Generates a unique tx_ref as required by Chapa.
  String generateTxRef({String prefix = 'TX'}) {
    final random = Random();
    final entropy = random.nextInt(900000) + 100000;
    return '$prefix-${DateTime.now().millisecondsSinceEpoch}-$entropy';
  }

  /// Kicks off a payment and returns the checkout URL + tx_ref.
  Future<ChapaPaymentInitResponse> initializePayment({
    required double amount,
    required String email,
    required String fullName,
    String currency = 'ETB',
    String? phone,
    String? txRef,
    String? callbackUrl,
    String? returnUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final resolvedTxRef = txRef ?? generateTxRef();
    final names = fullName.trim().split(' ');
    final firstName = names.isNotEmpty ? names.first : fullName;
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    final payload =
        <String, dynamic>{
          'amount': amount.toStringAsFixed(2),
          'currency': currency.isNotEmpty ? currency : defaultCurrency,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phone,
          'tx_ref': resolvedTxRef,
          'callback_url': callbackUrl ?? defaultCallbackUrl,
          'return_url': returnUrl ?? defaultReturnUrl,
          if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
          'customization': {
            'title': 'UniBazzar Pay',
            'description': 'Secure checkout powered by Chapa',
          },
        }..removeWhere(
          (_, value) => value == null || (value is String && value.isEmpty),
        );

    final response = await client.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $secretKey',
      },
      body: jsonEncode(payload),
    );

    final decoded = _safeJson(response.body);
    final isOk = decoded['status'] == 'success' && decoded['data'] != null;
    final checkoutUrl = decoded['data']?['checkout_url'] as String?;

    if (response.statusCode == 200 && isOk && checkoutUrl != null) {
      return ChapaPaymentInitResponse(
        checkoutUrl: checkoutUrl,
        txRef: resolvedTxRef,
        message: decoded['message'] as String? ?? 'Payment initialized',
      );
    }

    final errorMessage = decoded['message'] ?? 'Chapa initialization failed';
    throw ChapaException(
      message: errorMessage.toString(),
      statusCode: response.statusCode,
      responseBody: response.body,
    );
  }

  Map<String, dynamic> _safeJson(String body) {
    print('Chapa Response Body: $body'); // DEBUG LOG
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'message': 'Unexpected response shape', 'data': decoded};
    } catch (_) {
      return {'message': 'Invalid JSON response', 'raw': body};
    }
  }
}

class ChapaPaymentInitResponse {
  const ChapaPaymentInitResponse({
    required this.checkoutUrl,
    required this.txRef,
    required this.message,
  });

  final String checkoutUrl;
  final String txRef;
  final String message;
}

class ChapaException implements Exception {
  ChapaException({required this.message, this.statusCode, this.responseBody});

  final String message;
  final int? statusCode;
  final String? responseBody;

  @override
  String toString() => 'ChapaException($statusCode): $message';
}

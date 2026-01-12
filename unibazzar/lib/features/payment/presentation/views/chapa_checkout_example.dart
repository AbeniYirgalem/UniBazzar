import 'package:flutter/material.dart';

import '../../../../core/services/chapa_service.dart';
import '../widgets/payment_button.dart';

// Chapa TEST secret key provided by user.
const chapaTestSecretKey = 'CHASECK_TEST-lqy57fj37dxpTNByPfVg2kbzjchKo24n';

class ChapaCheckoutExamplePage extends StatelessWidget {
  ChapaCheckoutExamplePage({super.key});

  final _chapa = ChapaService(secretKey: chapaTestSecretKey);
  final double _price = 2499.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout (Chapa Test)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wireless Headphones',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'High-fidelity, noise-cancelling, 30h battery life.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text('Amount: ETB ${_price.toStringAsFixed(2)}'),
            const Spacer(),
            ChapaPaymentButton(
              chapaService: _chapa,
              amount: _price,
              currency: 'ETB',
              email: 'buyer@example.com',
              fullName: 'Student Buyer',
              metadata: const {
                'product_id': 'sku-123',
                'notes': 'Headphone purchase from UniBazzar demo',
              },
              onSuccess: (txRef) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment successful (tx_ref: $txRef)'),
                  ),
                );
              },
              onCancelled: (reason) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(reason ?? 'Payment cancelled')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

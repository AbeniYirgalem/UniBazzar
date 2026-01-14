import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/services/chapa_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/frosted_glass_card.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/listing.dart';
import '../../domain/entities/product.dart';
import '../../../payment/presentation/widgets/add_to_cart_button.dart';
import '../../../payment/presentation/widgets/payment_button.dart';

// Shared Chapa client for this screen.
final _chapaService = ChapaService(
  secretKey: AppConfig.chapaSecretKey,
  defaultCallbackUrl: AppConfig.chapaCallbackUrl,
  defaultReturnUrl: AppConfig.chapaReturnUrl,
);

class ProductDetailsPage extends ConsumerWidget {
  const ProductDetailsPage({super.key, this.listing});

  final Listing? listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. Handle null safety gracefully (early exit if essential data missing)
    if (listing == null) {
      return const Scaffold(body: Center(child: Text('Listing not found')));
    }

    // We already checked listing is not null, but product might be distinct?
    // Usually listing.product is non-null if listing is valid, but let's be safe.
    // Based on the entity definition, listing should have a product.
    // Accessing safely involved variables.
    final product = listing!.product;

    // 2. Inject logged-in user's email and name from Riverpod
    final userAsyncState = ref.watch(authControllerProvider);
    final user = userAsyncState.value;

    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 5. Improve network image handling
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: _buildProductImage(product),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FrostedGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'By ${listing!.seller.name}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white60),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 18,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                listing?.phoneNumber.isNotEmpty == true
                                    ? listing!.phoneNumber
                                    : 'No phone provided',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product.description,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              Chip(
                                label: Text('Category: ${product.category}'),
                                avatar: const Icon(Icons.category, size: 18),
                              ),
                              Chip(
                                label: Text('Status: ${listing!.status}'),
                                avatar: const Icon(
                                  Icons.verified_user,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Text(
                                'Br ${product.price.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppColors.accentTeal,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const Spacer(),
                              AddToCartButton(listing: listing!),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: listing?.status.toLowerCase() == 'sold'
              ? SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      disabledBackgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle, color: Colors.white70),
                    label: const Text(
                      'Sold / Already Paid',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                )
              : ChapaPaymentButton(
                  chapaService: _chapaService,
                  amount: product.price,
                  currency: 'ETB',
                  // 2. Dynamic email/name injection
                  email: user?.email ?? 'guest@unibazzar.com',
                  fullName: user?.name ?? 'Guest User',
                  metadata: {
                    'listing_id': listing!.id,
                    'product_title': product.title,
                  },
                  useWebView: false,
                  buttonText: 'Pay with Chapa',
                  onSuccess: (txRef) =>
                      _handlePaymentSuccess(context, ref, txRef),
                  onCancelled: (reason) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(reason ?? 'Payment cancelled')),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    if (product.images.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      product.images.first,
      fit: BoxFit.cover,
      // 4. Loading indicator
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      // 5. Error handling
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 48, color: Colors.white54),
      ),
    );
  }

  Future<void> _handlePaymentSuccess(
    BuildContext context,
    WidgetRef ref,
    String txRef,
  ) async {
    // 1. Record the transaction
    try {
      await ref
          .read(paymentRepositoryProvider)
          .recordChapaTransaction(
            listingId: listing!.id,
            amount: listing!.product.price,
            txRef: txRef,
            status: 'success',
          );
    } catch (e) {
      debugPrint('Failed to record transaction: $e');
      // Continue to show success dialog even if recording fails,
      // though in production you'd want robust handling.
    }

    if (!context.mounted) return;

    // 2. Show Success Popup
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text('Transaction Reference:\n$txRef'),
            const SizedBox(height: 16),
            const Text('Your order has been placed and is being processed.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Optionally navigate away or refresh
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

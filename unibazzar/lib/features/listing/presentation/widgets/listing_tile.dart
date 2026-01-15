import 'package:flutter/material.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/frosted_glass_card.dart';
import '../../../payment/presentation/widgets/add_to_cart_button.dart';
import '../../domain/entities/listing.dart';

class ListingTile extends StatelessWidget {
  const ListingTile({super.key, required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final product = listing.product;
    return FrostedGlassCard(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.productDetails, arguments: listing);
      },
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 92,
              height: 92,
              child: Image.network(
                _imageUrlForListing(listing),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (listing.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentTeal.withOpacity(.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Featured',
                          style: TextStyle(
                            color: AppColors.accentTeal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Br ${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.accentTeal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.phone, size: 16, color: Colors.white60),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        listing.phoneNumber.isNotEmpty
                            ? listing.phoneNumber
                            : 'No phone',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 4),
                    AddToCartButton(
                      listing: listing,
                      iconColor: AppColors.accentTeal,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _imageUrlForListing(Listing listing) {
    final images = listing.product.images;
    if (images.isNotEmpty &&
        images.first.isNotEmpty &&
        images.first.startsWith('http')) {
      return images.first;
    }
    return 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80';
  }
}

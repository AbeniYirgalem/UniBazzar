import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/frosted_glass_card.dart';
import '../../../listing/presentation/providers/listing_providers.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsState = ref.watch(listingControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Review Dashboard')),
      body: listingsState.when(
        data: (listings) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final listing = listings[index];
            return FrostedGlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.product.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text('Seller: ${listing.seller.name}'),
                        Text('Status: ${listing.status}'),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Listing approved')),
                          );
                        },
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.greenAccent,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Listing flagged for review'),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.flag_outlined,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: listings.length,
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

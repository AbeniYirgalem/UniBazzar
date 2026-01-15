import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../../domain/entities/listing.dart';
import '../providers/listing_providers.dart';

import '../widgets/listing_tile.dart';

class MarketplacePage extends ConsumerWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(listingControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              listingsAsync.whenOrNull(
                data: (listings) => showSearch<Listing?>(
                  context: context,
                  delegate: _MarketplaceSearchDelegate(listings),
                ),
              );
            },
          ),
        ],
      ),
      body: listingsAsync.when(
        data: (listings) {
          if (listings.isEmpty) {
            return const Center(child: Text('No products yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemBuilder: (context, index) =>
                ListingTile(listing: listings[index]),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: listings.length,
          );
        },
        error: (err, _) => Center(child: Text('Failed to load: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _MarketplaceSearchDelegate extends SearchDelegate<Listing?> {
  _MarketplaceSearchDelegate(this.listings);

  final List<Listing> listings;

  @override
  String get searchFieldLabel => 'Search products';

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    final results = _filtered();
    if (results.isEmpty) {
      return const Center(child: Text('No matches'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => ListingTile(listing: results[index]),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: results.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = _filtered();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.storefront_outlined),
        title: Text(results[index].product.title),
        subtitle: Text(results[index].product.category),
        onTap: () {
          close(context, results[index]);
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.productDetails, arguments: results[index]);
        },
      ),
    );
  }

  List<Listing> _filtered() {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return listings;
    return listings.where((listing) {
      final text =
          '${listing.product.title} ${listing.product.description} ${listing.product.category} ${listing.seller.name} ${listing.phoneNumber}'
              .toLowerCase();
      return text.contains(q);
    }).toList();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/frosted_glass_card.dart';
import '../../domain/entities/listing.dart';
import '../providers/listing_providers.dart';
import '../../../payment/presentation/widgets/add_to_cart_button.dart';

String _imageUrlForListing(Listing listing) {
  final images = listing.product.images;
  if (images.isNotEmpty &&
      images.first.isNotEmpty &&
      images.first.startsWith('http')) {
    return images.first;
  }
  return 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80';
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scrollController = ScrollController();
  String? _activeCategory = 'Books';

  Future<void> _launchEmail() async {
    final uri = Uri(scheme: 'mailto', path: 'support@unibazzar.app');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No email app available')));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setCategoryFilter(String? category) {
    setState(() => _activeCategory = category);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(listingControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              listingsAsync.whenOrNull(
                data: (listings) => showSearch<Listing?>(
                  context: context,
                  delegate: _ListingSearchDelegate(listings),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.adminDashboard),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addListing),
        icon: const Icon(Icons.add),
        label: const Text('Add listing'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(listingControllerProvider.notifier).fetchListings(),
        child: listingsAsync.when(
          data: (listings) {
            final featured = listings
                .where((listing) => listing.isFeatured)
                .toList();

            final filtered = _activeCategory == null
                ? listings
                : listings
                      .where(
                        (l) =>
                            l.product.category.toLowerCase() ==
                            _activeCategory!.toLowerCase(),
                      )
                      .toList();

            // If the selected category has no results, fall back to all listings.
            final visible = filtered.isNotEmpty ? filtered : listings;

            // If no items are explicitly featured, fall back to visible items
            // (respecting the active category) to avoid an empty carousel.
            final featuredOrFallback =
                (featured.isNotEmpty ? featured : visible).take(8).toList();

            return ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _SearchShortcut(
                  onTap: () => showSearch<Listing?>(
                    context: context,
                    delegate: _ListingSearchDelegate(listings),
                  ),
                ),
                const SizedBox(height: 16),
                _CategoriesStrip(
                  selectedCategory: _activeCategory,
                  onSelect: (category) => _setCategoryFilter(category),
                ),
                const SizedBox(height: 18),
                _SectionHeader(
                  title: 'Featured items',
                  icon: Icons.star,
                  action: featured.isEmpty ? null : 'See all',
                  onAction: featured.isEmpty
                      ? null
                      : () => showDialog<void>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Featured'),
                            content: const Text(
                              'Featured collection coming soon.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 260,
                  child: featuredOrFallback.isEmpty
                      ? const Center(child: Text('No featured items yet'))
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => SizedBox(
                            width: 260,
                            child: _FeaturedCard(
                              listing: featuredOrFallback[index],
                              onSelectCategory: _setCategoryFilter,
                            ),
                          ),
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemCount: featuredOrFallback.length,
                        ),
                ),
                const SizedBox(height: 20),
                const _SectionHeader(
                  title: 'Latest posts',
                  icon: Icons.fiber_new,
                ),
                const SizedBox(height: 10),
                ...visible.map(
                  (listing) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ListingTile(listing: listing),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(height: 32),
                _AboutCard(),
                const SizedBox(height: 16),
                _ContactCard(onEmailTap: _launchEmail),
              ],
            );
          },
          error: (err, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load listings: $err'),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _ListingTile extends StatelessWidget {
  const _ListingTile({required this.listing});

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
                    Text(
                      listing.seller.name,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.white60),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        listing.phoneNumber.isNotEmpty
                            ? listing.phoneNumber
                            : 'No phone provided',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ),
                    AddToCartButton(listing: listing),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.listing, required this.onSelectCategory});

  final Listing listing;
  final ValueChanged<String?> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final product = listing.product;
    return FrostedGlassCard(
      onTap: () => onSelectCategory(listing.product.category),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                _imageUrlForListing(listing),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
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
              const Icon(Icons.star, color: AppColors.accentTeal, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    this.action,
    this.onAction,
  });

  final String title;
  final IconData icon;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class _CategoriesStrip extends StatelessWidget {
  const _CategoriesStrip({this.onSelect, this.selectedCategory});

  static const _categories = <String>[
    'Books',
    'Electronics',
    'Services',
    'Food',
    'Furniture',
    'Clothing',
    'Other',
  ];

  final ValueChanged<String>? onSelect;
  final String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(c),
                  avatar: const Icon(Icons.tag, size: 16),
                  backgroundColor:
                      selectedCategory != null &&
                          selectedCategory!.toLowerCase() == c.toLowerCase()
                      ? AppColors.accentTeal.withOpacity(0.2)
                      : null,
                  labelStyle:
                      selectedCategory != null &&
                          selectedCategory!.toLowerCase() == c.toLowerCase()
                      ? const TextStyle(color: AppColors.accentTeal)
                      : null,
                  onPressed: () => onSelect?.call(c),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SearchShortcut extends StatelessWidget {
  const _SearchShortcut({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FrostedGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white70),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search items, services, food... ',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingSearchDelegate extends SearchDelegate<Listing?> {
  _ListingSearchDelegate(this.listings, {String? initialQuery}) {
    if (initialQuery != null && initialQuery.isNotEmpty) {
      query = initialQuery;
    }
  }

  final List<Listing> listings;

  @override
  String get searchFieldLabel => 'Search title, seller, phone';

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
      return const Center(child: Text('No matches found'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final listing = results[index];
        return _SearchTile(
          listing: listing,
          onTap: () {
            close(context, listing);
            Navigator.of(
              context,
            ).pushNamed(AppRoutes.productDetails, arguments: listing);
          },
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: results.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = _filtered();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final listing = results[index];
        return ListTile(
          leading: const Icon(Icons.shopping_bag_outlined),
          title: Text(listing.product.title),
          subtitle: Text(listing.product.category),
          onTap: () {
            close(context, listing);
            Navigator.of(
              context,
            ).pushNamed(AppRoutes.productDetails, arguments: listing);
          },
        );
      },
    );
  }

  List<Listing> _filtered() {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return listings;
    return listings.where((listing) {
      final text =
          '${listing.product.title} '
                  '${listing.product.description} '
                  '${listing.product.category} '
                  '${listing.seller.name} '
                  '${listing.phoneNumber}'
              .toLowerCase();
      return text.contains(q);
    }).toList();
  }
}

class _SearchTile extends StatelessWidget {
  const _SearchTile({required this.listing, required this.onTap});

  final Listing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final product = listing.product;
    return FrostedGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 64,
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
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Text(
            'Br ${product.price.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.accentTeal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'About UniBazzar',
      children: [
        Text(
          'UniBazzar is a campus-based marketplace for university students to buy, sell, and offer services safely within their campus.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _Pill(icon: Icons.verified_user_outlined, label: 'Student-only'),
            _Pill(icon: Icons.security_outlined, label: 'Verified campus'),
            _Pill(icon: Icons.shield_outlined, label: 'Local & secure'),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('About page coming soon.')),
              );
            },
            child: const Text('Learn more'),
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.onEmailTap});

  final VoidCallback onEmailTap;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Contact & Support',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.email_outlined, color: Colors.white70),
          title: const Text('Email'),
          subtitle: const Text('support@unibazzar.app'),
          onTap: onEmailTap,
        ),
        const Divider(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.chat_bubble_outline, color: Colors.white70),
          title: const Text('In-app support'),
          subtitle: const Text('Chat with our team'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Support chat coming soon.')),
            );
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: onEmailTap,
            icon: const Icon(Icons.contact_mail_outlined),
            label: const Text('Contact us'),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentTeal.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accentTeal),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.accentTeal),
          ),
        ],
      ),
    );
  }
}

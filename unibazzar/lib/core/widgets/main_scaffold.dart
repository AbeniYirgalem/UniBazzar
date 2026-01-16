import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/listing/presentation/views/home_page.dart';
import '../../features/listing/presentation/views/categories_page.dart';
import '../../features/listing/presentation/views/marketplace_page.dart';
import '../../features/payment/presentation/views/cart_page.dart';
import '../providers/bottom_nav_provider.dart';

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    final screens = [
      const HomePage(),
      const MarketplacePage(),
      const CategoriesPage(),
      const CartPage(),
    ];

    // Clamp to a valid index in case the saved nav index points past the list (e.g., after removing tabs).
    final currentIndex = selectedIndex.clamp(0, screens.length - 1);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
          },
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surface.withOpacity(0.92),
          indicatorColor: Theme.of(context).primaryColor.withOpacity(0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'Marketplace',
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined),
              selectedIcon: Icon(Icons.category),
              label: 'Categories',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
          ],
        ),
      ),
    );
  }
}

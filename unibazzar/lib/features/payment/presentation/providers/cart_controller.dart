import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../listing/domain/entities/listing.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/get_cart_items.dart';
import '../../domain/usecases/remove_from_cart.dart';
import '../../../../core/di/providers.dart';

class CartController extends StateNotifier<AsyncValue<List<CartItem>>> {
  CartController({
    required this.getCartItems,
    required this.addToCart,
    required this.removeFromCart,
  }) : super(const AsyncValue.loading()) {
    loadCart();
  }

  final GetCartItems getCartItems;
  final AddToCart addToCart;
  final RemoveFromCart removeFromCart;

  Future<void> loadCart() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => getCartItems());
  }

  Future<void> addItem(Listing listing, {int quantity = 1}) async {
    try {
      await addToCart(listing, quantity: quantity);
      await loadCart();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> removeItem(String listingId) async {
    try {
      await removeFromCart(listingId);
      await loadCart();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final cartControllerProvider =
    StateNotifierProvider<CartController, AsyncValue<List<CartItem>>>(
      (ref) => CartController(
        getCartItems: ref.read(getCartItemsProvider),
        addToCart: ref.read(addToCartProvider),
        removeFromCart: ref.read(removeFromCartProvider),
      ),
    );

void showCartError(BuildContext context, Object error) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(error.toString())));
}

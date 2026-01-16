import '../../../listing/domain/entities/listing.dart';
import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<void> addToCart(Listing listing, {int quantity = 1});
  Future<List<CartItem>> getCartItems();
  Future<void> removeFromCart(String listingId);
}

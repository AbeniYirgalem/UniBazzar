import '../../../listing/data/models/listing_model.dart';
import '../../../listing/domain/entities/listing.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';
import '../models/cart_item_model.dart';
import '../../../../core/services/auth_service.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this.remoteDataSource, this.authService);

  final CartRemoteDataSource remoteDataSource;
  final AuthService authService;

  String _requireUserId() {
    final user = authService.currentUser;
    if (user == null) {
      throw Exception('Please sign in to use your cart');
    }
    return user.uid;
  }

  @override
  Future<void> addToCart(Listing listing, {int quantity = 1}) async {
    final userId = _requireUserId();
    final listingModel = listing is ListingModel
        ? listing
        : ListingModel.fromListing(listing);
    final item = CartItemModel(
      listing: listingModel,
      quantity: quantity,
      addedAt: DateTime.now(),
    );
    await remoteDataSource.addCartItem(userId: userId, item: item);
  }

  @override
  Future<List<CartItem>> getCartItems() async {
    final userId = _requireUserId();
    return remoteDataSource.fetchCartItems(userId);
  }

  @override
  Future<void> removeFromCart(String listingId) async {
    final userId = _requireUserId();
    await remoteDataSource.removeCartItem(userId: userId, listingId: listingId);
  }
}

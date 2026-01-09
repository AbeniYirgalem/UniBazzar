import '../../../listing/domain/entities/listing.dart';
import '../repositories/cart_repository.dart';

class AddToCart {
  const AddToCart(this.repository);

  final CartRepository repository;

  Future<void> call(Listing listing, {int quantity = 1}) {
    return repository.addToCart(listing, quantity: quantity);
  }
}

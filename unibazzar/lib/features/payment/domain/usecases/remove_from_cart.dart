import '../repositories/cart_repository.dart';

class RemoveFromCart {
  const RemoveFromCart(this.repository);

  final CartRepository repository;

  Future<void> call(String listingId) {
    return repository.removeFromCart(listingId);
  }
}

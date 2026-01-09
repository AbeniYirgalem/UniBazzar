import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class GetCartItems {
  const GetCartItems(this.repository);

  final CartRepository repository;

  Future<List<CartItem>> call() => repository.getCartItems();
}

import '../../../listing/domain/entities/listing.dart';

class CartItem {
  const CartItem({required this.listing, required this.quantity, this.addedAt});

  final Listing listing;
  final int quantity;
  final DateTime? addedAt;
}

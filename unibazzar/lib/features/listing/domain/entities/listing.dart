import '../../../auth/domain/entities/user.dart';
import 'product.dart';

class Listing {
  const Listing({
    required this.id,
    required this.product,
    required this.seller,
    required this.status,
    required this.createdAt,
    required this.phoneNumber,
    this.isFeatured = false,
  });

  final String id;
  final Product product;
  final User seller;
  final String status;
  final DateTime createdAt;
  final String phoneNumber;
  final bool isFeatured;
}

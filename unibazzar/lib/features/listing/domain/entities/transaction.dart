import '../../../auth/domain/entities/user.dart';

class Transaction {
  const Transaction({
    required this.id,
    required this.listingId,
    required this.buyer,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String listingId;
  final User buyer;
  final double amount;
  final String status;
  final DateTime createdAt;
}

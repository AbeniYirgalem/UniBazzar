import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.listingId,
    required super.buyer,
    required super.amount,
    required super.status,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      buyer: UserModel.fromJson(json['buyer'] as Map<String, dynamic>),
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'listing_id': listingId,
    'buyer': (buyer as UserModel).toJson(),
    'amount': amount,
    'status': status,
    'created_at': createdAt.toIso8601String(),
  };
}

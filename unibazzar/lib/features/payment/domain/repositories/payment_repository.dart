import '../../../listing/domain/entities/transaction.dart';

abstract class PaymentRepository {
  Future<Transaction> makePayment({
    required String listingId,
    required double amount,
    required String paymentMethod,
  });

  Future<Transaction> recordChapaTransaction({
    required String listingId,
    required double amount,
    required String txRef,
    required String status,
  });
}

import '../../../listing/domain/entities/transaction.dart';
import '../repositories/payment_repository.dart';

class MakePayment {
  const MakePayment(this.repository);

  final PaymentRepository repository;

  Future<Transaction> call({
    required String listingId,
    required double amount,
    required String paymentMethod,
  }) {
    return repository.makePayment(
      listingId: listingId,
      amount: amount,
      paymentMethod: paymentMethod,
    );
  }
}

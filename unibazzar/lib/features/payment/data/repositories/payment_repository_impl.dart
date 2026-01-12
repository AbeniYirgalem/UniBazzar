import '../../../listing/domain/entities/transaction.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this.remoteDataSource);

  final PaymentRemoteDataSource remoteDataSource;

  @override
  Future<Transaction> makePayment({
    required String listingId,
    required double amount,
    required String paymentMethod,
  }) {
    // Only Telebirr is wired for now, additional gateways can branch here.
    return remoteDataSource.payWithTelebirr(
      listingId: listingId,
      amount: amount,
    );
  }

  @override
  Future<Transaction> recordChapaTransaction({
    required String listingId,
    required double amount,
    required String txRef,
    required String status,
  }) {
    return remoteDataSource.recordChapaTransaction(
      listingId: listingId,
      amount: amount,
      txRef: txRef,
      status: status,
    );
  }
}

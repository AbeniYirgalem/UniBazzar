import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../listing/domain/entities/transaction.dart';
import '../../domain/usecases/make_payment.dart';
import '../../../../core/di/providers.dart';

class PaymentController extends StateNotifier<AsyncValue<Transaction?>> {
  PaymentController(this.makePaymentUseCase)
    : super(const AsyncValue.data(null));

  final MakePayment makePaymentUseCase;

  Future<void> pay({
    required String listingId,
    required double amount,
    required String method,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => makePaymentUseCase(
        listingId: listingId,
        amount: amount,
        paymentMethod: method,
      ),
    );
  }

  void reset() => state = const AsyncValue.data(null);
}

final paymentControllerProvider =
    StateNotifierProvider<PaymentController, AsyncValue<Transaction?>>((ref) {
      return PaymentController(ref.read(makePaymentProvider));
    });

import 'package:ecommerce_sqlite_clean/features/payment/data/datasources/payment_local_data_source.dart';
import 'package:ecommerce_sqlite_clean/features/payment/data/models/payment_model.dart';
import 'package:ecommerce_sqlite_clean/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/payment_repository.dart';

final paymentLocalDataSourceProvider = Provider<PaymentLocalDataSource>((ref) {
  return PaymentLocalDataSourceImpl();
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(ref.watch(paymentLocalDataSourceProvider));
});

final paymentHistoryProvider =
    StateNotifierProvider<
      PaymentHistoryNotifier,
      AsyncValue<List<PaymentModel>>
    >((ref) {
      return PaymentHistoryNotifier(ref.watch(paymentRepositoryProvider));
    });

class PaymentHistoryNotifier
    extends StateNotifier<AsyncValue<List<PaymentModel>>> {
  final PaymentRepository _repository;

  PaymentHistoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPayments();
  }

  Future<void> loadPayments() async {
    state = const AsyncValue.loading();
    try {
      final payments = await _repository.getPayments();
      state = AsyncValue.data(payments);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addPayment(PaymentModel payment) async {
    try {
      await _repository.savePayment(payment);
      await loadPayments();
    } catch (e) {
      // Handle error if necessary
    }
  }
}

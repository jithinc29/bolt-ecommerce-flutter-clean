import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_local_data_source.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentLocalDataSource localDataSource;

  PaymentRepositoryImpl(this.localDataSource);

  @override
  Future<List<PaymentModel>> getPayments() {
    return localDataSource.getPayments();
  }

  @override
  Future<void> savePayment(PaymentModel payment) {
    return localDataSource.savePayment(payment);
  }
}

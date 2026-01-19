import '../../data/models/payment_model.dart';

abstract class PaymentRepository {
  Future<List<PaymentModel>> getPayments();
  Future<void> savePayment(PaymentModel payment);
}

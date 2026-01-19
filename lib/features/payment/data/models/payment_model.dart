class PaymentModel {
  final String? id;
  final String orderId;
  final String? paymentId;
  final double amount;
  final String status;
  final DateTime timestamp;

  PaymentModel({
    this.id,
    required this.orderId,
    this.paymentId,
    required this.amount,
    required this.status,
    required this.timestamp,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id']?.toString(),
      orderId: map['orderId'],
      paymentId: map['paymentId'],
      amount: map['amount'],
      status: map['status'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'paymentId': paymentId,
      'amount': amount,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

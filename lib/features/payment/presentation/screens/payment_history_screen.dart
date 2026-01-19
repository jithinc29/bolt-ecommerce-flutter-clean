import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/payment_provider.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(paymentHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: paymentState.when(
        data: (payments) {
          if (payments.isEmpty) {
            return const Center(child: Text('No payments found.'));
          }
          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Order ID: ${payment.orderId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: \$${payment.amount.toStringAsFixed(2)}'),
                      Text('Status: ${payment.status}'),
                      Text(
                        'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(payment.timestamp)}',
                      ),
                    ],
                  ),
                  trailing: Icon(
                    payment.status == 'Success'
                        ? Icons.check_circle
                        : Icons.error,
                    color: payment.status == 'Success'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

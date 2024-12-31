import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryanawe/models/customer.dart';
import 'package:ryanawe/models/order.dart';
import 'package:ryanawe/services/database_service.dart';

class DebtManagementScreen extends StatelessWidget {
  const DebtManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Management'),
      ),
      body: StreamBuilder<List<Customer>>(
        stream: context.read<DatabaseService>().getCustomersWithDebt(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final customers = snapshot.data!;
          final totalDebt = customers.fold<double>(
            0,
            (sum, customer) => sum + customer.totalDebt,
          );

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Outstanding Debt',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${totalDebt.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ExpansionTile(
                        title: Text(customer.name),
                        subtitle: Text(
                            'Debt: \$${customer.totalDebt.toStringAsFixed(2)}'),
                        children: [
                          ...customer.orders
                              .where((order) => order.paidAt == null)
                              .map((order) => ListTile(
                                    title: Text('Order #${order.id}'),
                                    subtitle: Text(
                                      'Created: ${order.createdAt.toLocal()}',
                                    ),
                                    trailing: Text(
                                      '\$${order.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () => _showPaymentDialog(
                                      context,
                                      customer,
                                      order,
                                    ),
                                  )),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPaymentDialog(
    BuildContext context,
    Customer customer,
    Order order,
  ) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order Total: \$${order.totalAmount}'),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                prefixText: '\$',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Record Payment'),
            onPressed: () {
              // Record payment in database
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

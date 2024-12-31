import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryanawe/models/customer.dart';
import 'package:ryanawe/services/database_service.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: StreamBuilder<List<Customer>>(
        stream: context.read<DatabaseService>().getCustomers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final customers = snapshot.data!;
            return ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return CustomerListItem(customer: customer);
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Navigate to customer creation screen
        },
      ),
    );
  }
}

class CustomerListItem extends StatelessWidget {
  final Customer customer;

  const CustomerListItem({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // Navigate to customer detail screen
      },
      leading: CircleAvatar(
        child: Text(customer.name.substring(0, 1).toUpperCase()),
      ),
      title: Text(customer.name),
      subtitle: Text(customer.email),
      trailing: Text(
        '\$${customer.totalDebt.toStringAsFixed(2)}',
        style: TextStyle(
          color: customer.totalDebt > 0 ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

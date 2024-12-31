import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryanawe/models/order.dart';
import 'package:ryanawe/services/database_service.dart';

class OrdersHistoryScreen extends StatelessWidget {
  const OrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders History'),
      ),
      body: const DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'All'),
                Tab(text: 'Paid'),
                Tab(text: 'Unpaid'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  OrdersList(filter: OrderFilter.all),
                  OrdersList(filter: OrderFilter.paid),
                  OrdersList(filter: OrderFilter.unpaid),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum OrderFilter { all, paid, unpaid }

class OrdersList extends StatelessWidget {
  final OrderFilter filter;

  const OrdersList({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: context.read<DatabaseService>().getOrders(filter),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!;
        if (orders.isEmpty) {
          return const Center(
            child: Text('No orders found'),
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: ExpansionTile(
                title: Text('Order #${order.id}'),
                subtitle: Text(
                  'Customer: ${order.customerName}\n'
                  'Date: ${order.createdAt.toLocal()}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: order.paidAt != null ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      order.paidAt != null ? 'Paid' : 'Unpaid',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                children: [
                  ...order.items.map(
                    (item) => ListTile(
                      title: Text(item.name),
                      trailing: Text(
                        '${item.quantity} x \$${item.price.toStringAsFixed(2)}',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

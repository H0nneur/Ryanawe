import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryanawe/models/product.dart';
import 'package:ryanawe/models/stock_history.dart';
import 'package:ryanawe/services/database_service.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: TabBar(
            tabs: [
              Tab(text: 'Stock Level'),
              Tab(text: 'Stock History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StockLevelTab(),
            StockHistoryTab(),
          ],
        ),
      ),
    );
  }
}

class StockLevelTab extends StatelessWidget {
  const StockLevelTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: context.read<DatabaseService>().getProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!;
        products.sort((a, b) => a.stock.compareTo(b.stock));

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(
                      product.images.isNotEmpty ? product.images[0] : '',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(product.name),
              subtitle: Text('Category: ${product.category}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.stock} in stock',
                    style: TextStyle(
                      color: product.stock < 10 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Min: 10',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              onTap: () => _showStockUpdateDialog(context, product),
            );
          },
        );
      },
    );
  }

  void _showStockUpdateDialog(BuildContext context, Product product) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current stock: ${product.stock}'),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New stock level',
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
            child: const Text('Update'),
            onPressed: () {
              // Update stock level in database
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class StockHistoryTab extends StatelessWidget {
  const StockHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StockHistory>>(
      stream: context.read<DatabaseService>().getStockHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final history = snapshot.data!;
        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final record = history[index];
            return ListTile(
              title: Text(record.productName),
              subtitle: Text(
                'Changed by ${record.updatedBy} on ${record.updatedAt.toLocal()}',
              ),
              trailing: Text(
                '${record.previousStock} → ${record.newStock}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        );
      },
    );
  }
}

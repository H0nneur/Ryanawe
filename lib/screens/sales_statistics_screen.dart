import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryanawe/models/product.dart';
import 'package:ryanawe/services/database_service.dart';

class SalesStatisticsScreen extends StatefulWidget {
  const SalesStatisticsScreen({super.key});

  @override
  State<SalesStatisticsScreen> createState() => _SalesStatisticsScreenState();
}

class _SalesStatisticsScreenState extends State<SalesStatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total revenue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            StreamBuilder<SalesData>(
              stream: context.read<DatabaseService>().getSalesData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final salesData = snapshot.data!;
                  return Text(
                    '\$${salesData.totalRevenue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Best Selling Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<Product>>(
              stream: context.read<DatabaseService>().getBestSellingProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final bestSellingProducts = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: bestSellingProducts.length,
                      itemBuilder: (context, index) {
                        final product = bestSellingProducts[index];
                        return ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: product.images.isNotEmpty
                                ? product.images[0]
                                : '',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                          title: Text(product.name),
                          subtitle: Text(
                            'Total Sales: ${product.totalSales}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

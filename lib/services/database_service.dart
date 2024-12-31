import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ryanawe/models/customer.dart';
import 'package:ryanawe/models/order.dart' as ryanawe_order;
import 'package:ryanawe/models/product.dart';
import 'package:ryanawe/models/stock_history.dart';
import 'package:ryanawe/screens/orders_history_screen.dart';

class SalesData {
  final double totalRevenue;
  final int totalOrders;

  SalesData({
    required this.totalRevenue,
    required this.totalOrders,
  });
}

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Product operations
  Future<void> addProduct(Product product) async {
    try {
      await _db.collection('products').add({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'stock': product.stock,
        'images': product.images,
        'category': product.category,
        'totalSales': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp()
      });
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProductStock(String productId, int newStock) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    try {
      // Get current product data
      final productDoc = await _db.collection('products').doc(productId).get();
      final previousStock = productDoc.data()?['stock'] ?? 0;

      // Update product stock
      await _db.collection('products').doc(productId).update({
        'stock': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Record stock history
      await _db.collection('stock_history').add({
        'productId': productId,
        'productName': productDoc.data()?['name'],
        'previousStock': previousStock,
        'newStock': newStock,
        'updatedBy': currentUser.email,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating product stock: $e');
      rethrow;
    }
  }

  Stream<List<StockHistory>> getStockHistory() {
    return _db
        .collection('stock_history')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return StockHistory(
          productName: data['productName'],
          updatedBy: data['updatedBy'],
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
          previousStock: data['previousStock'],
          newStock: data['newStock'],
        );
      }).toList();
    });
  }

  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromJson(doc.data());
      }).toList();
    });
  }

  // Customer operations
  Future<void> addCustomer(Customer customer) async {
    try {
      await _db.collection('customers').add({
        'name': customer.name,
        'email': customer.email,
        'phone': customer.phone,
        'totalDebt': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding customer: $e');
      rethrow;
    }
  }

  Stream<List<Customer>> getCustomersWithDebt() {
    return _db
        .collection('customers')
        .where('totalDebt', isGreaterThan: 0)
        .snapshots()
        .asyncMap((customerSnapshot) async {
      final customers = <Customer>[];

      for (var customerDoc in customerSnapshot.docs) {
        final customerData = customerDoc.data();

        // Fetch customer's unpaid orders
        final ordersSnapshot = await _db
            .collection('orders')
            .where('customerId', isEqualTo: customerDoc.id)
            .where('paidAt', isNull: true)
            .get();

        final orders = ordersSnapshot.docs.map((orderDoc) {
          final orderData = orderDoc.data();
          return ryanawe_order.Order(
            id: orderDoc.id,
            customerId: orderData['customerId'],
            items: (orderData['items'] as List)
                .map((item) => ryanawe_order.OrderItem(
                      productId: item['productId'],
                      name: item['name'],
                      price: item['price'],
                      quantity: item['quantity'],
                    ))
                .toList(),
            totalAmount: orderData['totalAmount'],
            createdAt: (orderData['createdAt'] as Timestamp).toDate(),
            paidAt: null,
          );
        }).toList();

        customers.add(Customer(
          id: customerDoc.id,
          name: customerData['name'],
          email: customerData['email'],
          phone: customerData['phone'],
          totalDebt: customerData['totalDebt'],
          orders: orders,
        ));
      }

      return customers;
    });
  }

  Stream<List<Customer>> getCustomers() {
    return _db.collection('customers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Customer.fromJson(doc.data());
      }).toList();
    });
  }

  // Order Management
  Future<void> createOrder(ryanawe_order.Order order) async {
    try {
      // Create order in Firestore
      final orderRef = await _db.collection('orders').add({
        'customerId': order.customerId,
        'items': order.items
            .map((item) => {
                  'productId': item.productId,
                  'name': item.name,
                  'price': item.price,
                  'quantity': item.quantity,
                })
            .toList(),
        'totalAmount': order.totalAmount,
        'createdAt': FieldValue.serverTimestamp(),
        'paidAt': null,
      });

      // Update product stocks
      final batch = _db.batch();
      for (var item in order.items) {
        final productDoc = _db.collection('products').doc(item.productId);
        batch.update(productDoc, {
          'stock': FieldValue.increment(-item.quantity),
          'totalSales': FieldValue.increment(item.quantity),
        });
      }

      // Update customer's total debt
      final customerDoc = _db.collection('customers').doc(order.customerId);
      batch.update(customerDoc, {
        'totalDebt': FieldValue.increment(order.totalAmount),
      });

      await batch.commit();
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  Future<void> recordPayment(
      ryanawe_order.Order order, double paymentAmount) async {
    try {
      final batch = _db.batch();

      // Update order with payment
      final orderDoc = _db.collection('orders').doc(order.id);
      batch.update(orderDoc, {
        'paidAt': FieldValue.serverTimestamp(),
      });

      // Update customer's total debt
      final customerDoc = _db.collection('customers').doc(order.customerId);
      batch.update(customerDoc, {
        'totalDebt': FieldValue.increment(-paymentAmount),
      });

      await batch.commit();
    } catch (e) {
      print('Error recording payment: $e');
      rethrow;
    }
  }

  Stream<List<ryanawe_order.Order>> getOrders(OrderFilter filter) {
    Query query = _db.collection('orders');

    switch (filter) {
      case OrderFilter.paid:
        query = query.where('paidAt', isNull: false);
        break;
      case OrderFilter.unpaid:
        query = query.where('paidAt', isNull: true);
        break;
      case OrderFilter.all:
      default:
        // No additional filtering
        break;
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final orders = <ryanawe_order.Order>[];

      for (var doc in snapshot.docs) {
        final orderData = doc.data() as Map<String, dynamic>;

        // Fetch customer name
        final customerDoc = await _db
            .collection('customers')
            .doc(orderData['customerId'])
            .get();

        orders.add(ryanawe_order.Order(
          id: doc.id,
          customerId: orderData['customerId'],
          customerName: customerDoc.data()?['name'] ?? 'Unknown Customer',
          items: (orderData['items'] as List)
              .map((item) => ryanawe_order.OrderItem(
                    productId: item['productId'],
                    name: item['name'],
                    price: item['price'],
                    quantity: item['quantity'],
                  ))
              .toList(),
          totalAmount: orderData['totalAmount'],
          createdAt: (orderData['createdAt'] as Timestamp).toDate(),
          paidAt: orderData['paidAt'] != null
              ? (orderData['paidAt'] as Timestamp).toDate()
              : null,
        ));
      }

      return orders;
    });
  }

  Stream<SalesData> getSalesData() {
    return _db.collection('orders').get().asStream().map((snapshot) {
      double totalRevenue = 0;
      int totalOrders = 0;
      for (final doc in snapshot.docs) {
        totalRevenue += doc.data()['totalAmount'].toDouble();
      }
      return SalesData(totalRevenue: totalRevenue, totalOrders: totalOrders);
    });
  }

  Stream<List<Product>> getBestSellingProducts() {
    return _db
        .collection('products')
        .orderBy('totalSales', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'],
          description: data['description'],
          price: data['price'],
          stock: data['stock'],
          images: List<String>.from(data['images']),
          category: data['category'],
          totalSales: data['totalSales'] ?? 0,
        );
      }).toList();
    });
  }
}

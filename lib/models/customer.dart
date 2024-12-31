import 'package:ryanawe/models/order.dart';

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final double totalDebt;
  final List<Order> orders;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.totalDebt,
    required this.orders,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        totalDebt: json['totalDebt'].toDouble(),
        orders: (json['orders'] as List<dynamic>)
            .map((order) => Order.fromJson(order))
            .toList());
  }
}

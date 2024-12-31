import 'package:flutter/material.dart';
import 'package:ryanawe/screens/customer_list_screen.dart';
import 'package:ryanawe/screens/inventory_screen.dart';
import 'package:ryanawe/screens/product_list_screen.dart';
import 'package:ryanawe/screens/sales_statistics_screen.dart';
import 'package:ryanawe/widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const ProductListScreen(),
    const CustomerListScreen(),
    const SalesStatisticsScreen(),
    const InventoryScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ryanǎwe Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 0:
        return FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            // Navigate to add product screen
          },
        );
      case 1:
        return FloatingActionButton(
          child: const Icon(Icons.person_add),
          onPressed: () {
            // Navigate to add customer screen
          },
        );
      default:
        return null;
    }
  }
}

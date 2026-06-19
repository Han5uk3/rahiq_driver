import 'package:flutter/material.dart';
import 'package:rahiq_driver/ui/auto_orders_page.dart';
import 'package:rahiq_driver/ui/orders/orders_page.dart';
import 'package:rahiq_driver/ui/profile/profile_tab.dart';
import 'package:rahiq_driver/ui/shared/custom_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Dashboard')), // Placeholder for Dashboard
    const OrdersPage(),
    const AutoOrdersPage(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to extend behind the floating nav bar
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          CustomBottomNavItem(icon: Icons.dashboard, label: 'Home'),
          CustomBottomNavItem(icon: Icons.list_alt, label: 'Orders'),
          CustomBottomNavItem(icon: Icons.autorenew, label: 'Autodelivery'),
          CustomBottomNavItem(icon: Icons.person, label: 'Profile'),
        ],
      ),
    );
  }
}

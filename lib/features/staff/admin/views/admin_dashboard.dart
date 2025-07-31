import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/router.dart'; 
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth / 2 - 32;  // Divide screen into two, minus padding

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN PANEL'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDashboardCard(
                    context,
                    icon: Icons.person,
                    label: 'Waiter Management',
                    color: Colors.blue,
                    width: cardWidth,
                    routeName: AppRouteNames.waiterDashboard,  // Replace with your actual route name
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.account_balance,
                    label: 'Accounts',
                    color: Colors.green,
                    width: cardWidth,
                    routeName: AppRouteNames.accountsDashboard,  // Replace with your actual route name
                  ),
                ],
              ),
              const SizedBox(height: 24),  // Space between rows
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDashboardCard(
                    context,
                    icon: Icons.restaurant_menu,
                    label: 'Chef Dashboard',
                    color: Colors.orange,
                    width: cardWidth,
                    routeName: AppRouteNames.chefDashboard,  // Replace with your actual route name
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.inventory,
                    label: 'Inventory',
                    color: Colors.purple,
                    width: cardWidth,
                    routeName: AppRouteNames.inventoryDashboard,  // Replace with your actual route name
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required double width,
    required String routeName,
  }) {
    return InkWell(
      onTap: () {
        context.goNamed(routeName);  // Navigate to the specified route
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: width,
          height: 150,  // Fixed height for uniformity
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

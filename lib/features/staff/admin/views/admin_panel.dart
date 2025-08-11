import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/route_names.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth / 2 - 32;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN PANEL'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            context.goNamed(AppRouteNames.adminDashboard);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    _buildDashboardCard(
                      context, 
                      icon: Icons.receipt_long_outlined, 
                      label: 'Bills', 
                      color: Colors.orange, 
                      width: cardWidth, 
                      routeName: AppRouteNames.adminBillsView),
                    _buildDashboardCard(
                      context, 
                      icon: Icons.table_bar_outlined, 
                      label: 'Table Status', 
                      color: Colors.blue, 
                      width: cardWidth, 
                      routeName: AppRouteNames.adminTableStatus),
                  ],
                ),
                Row(
                  children: [
                   _buildDashboardCard(
                      context, 
                      icon: Icons.list_alt_outlined, 
                      label: 'Orders', 
                      color: Colors.purple, 
                      width: cardWidth, 
                      routeName: AppRouteNames.adminOrdersView),
                    _buildDashboardCard(
                      context, 
                      icon: Icons.bar_chart_outlined, 
                      label: 'Finance Report', 
                      color: Colors.red, 
                      width: cardWidth, 
                      routeName: AppRouteNames.adminFinanceReport),
              
                  ],
                ),
                Row(
                  children: [
                    _buildDashboardCard(
                      context, 
                      icon: Icons.food_bank_outlined, 
                      label: 'Add New Dish', 
                      color: Colors.yellow, 
                      width: cardWidth, 
                      routeName: AppRouteNames.adminAddDish
                      ),
                    _buildDashboardCard(
                      context, 
                      icon: Icons.table_restaurant_outlined, 
                      label: 'Add New Table', 
                      color: Colors.green, 
                      width: cardWidth,
                      routeName: AppRouteNames.adminAddTable)
                  ],
                ),
                Row(
                  children: [
                    _buildDashboardCard(
                      context, 
                      icon: Icons.edit_note_outlined, 
                      label: 'Update Dish', 
                      color: Colors.cyan, 
                      width: cardWidth, 
                      routeName: AppRouteNames.adminUpdateDishView),
                    _buildDashboardCard(
                      context, 
                      icon: Icons.delete_outline, 
                      label: 'Delete Table', 
                      color: Colors.pink, 
                      width: cardWidth, 
                      routeName: AppRouteNames.adminTableDelete),
                  ],
                ),
              ],),
            ),
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
        context.goNamed(routeName);
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: width,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
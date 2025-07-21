import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Dashboard Overview'),
            const Text('Total Revenue: USD 1000'),
            const Text('Total Orders: 100'),
            const Text('Total Staff: 10'),
            const Text('Total Customers: 50'),
            const Text('Orders in Progress'),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Table $index'),
                    subtitle: const Text('Dish: Pizza'),
                  );
                }
              ),
            ),
            const Text('Bills Paid'),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Order #$index'),
                    subtitle: const Text('USD 100'),
                  );
                }
              ),
            ),
            const Text('Staff'),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Person $index'),
                    subtitle: const Text('Role'),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
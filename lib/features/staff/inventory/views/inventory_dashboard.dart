import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/router.dart';

class InventoryDashboard extends StatelessWidget {
  const InventoryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
          onPressed: () {
            context.goNamed(AppRouteNames.adminDashboard);
          },
        ),
        title: const Text('Inventory Dashboard'), 
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Required Inventory'),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Item $index', style: Theme.of(context).textTheme.titleMedium),
                                const Text('USD 100', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Handle item purchase
                            },
                            icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                          ),
                          IconButton(
                            onPressed: () {
                              // Handle item removal
                            },
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Text('Total Inventory'),
            Expanded(
              child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Item $index'),
                          subtitle: const Text('USD 100'),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ]
          ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Final bill payment logic
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
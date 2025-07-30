import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/router/router.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';
import 'package:hotelmanagement/core/models/dish.dart';

class BillView extends ConsumerWidget {
  final String tableNumber;
  const BillView({super.key, required this.tableNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableAsync = ref.watch(getTableByNumberProvider(tableNumber));
    const double taxRate = 0.15; // 15%

    return Scaffold(
      appBar: AppBar(
        title: Text('Bill for Table $tableNumber'),
      ),
      body: tableAsync.when(
        data: (table) {
          if (table == null) {
            return const Center(child: Text('Table not found.'));
          }

          // 1. Filter for orders that should be on the bill
          final billableOrders = table.orders.where(
              (o) => o.status == 'preparing' || o.status == 'delivered');

          if (billableOrders.isEmpty) {
            return const Center(child: Text('No items to bill for this table.'));
          }

          // 2. Create a flat list of all dishes from those orders
          final allDishes =
              billableOrders.expand((order) => order.dishes).toList();

          // 3. Group dishes to get quantities and calculate subtotal
          final Map<String, ({Dish dish, int quantity})> items = {};
          double subtotal = 0;

          for (var dish in allDishes) {
            subtotal += dish.price;
            items.update(
              dish.name,
              (value) => (dish: value.dish, quantity: value.quantity + 1),
              ifAbsent: () => (dish: dish, quantity: 1),
            );
          }

          final taxAmount = subtotal * taxRate;
          final grandTotal = subtotal + taxAmount;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items.values.elementAt(index);
                      return ListTile(
                        title: Text(item.dish.name),
                        subtitle: Text(
                            '${item.quantity} x €${item.dish.price.toStringAsFixed(2)}'),
                        trailing: Text(
                            '€${(item.dish.price * item.quantity).toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ),
                const Divider(thickness: 2),
                _buildBillRow('Subtotal', subtotal),
                _buildBillRow('Tax (15%)', taxAmount),
                const Divider(),
                _buildBillRow('Grand Total', grandTotal, isBold: true),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement payment logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment feature coming soon!')),);
                    context.goNamed(
                        AppRouteNames.customerDashboard,
                        pathParameters: {'tableNumber': tableNumber},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Pay Now'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading bill: $error')),
      ),
    );
  }

  Widget _buildBillRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '€${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

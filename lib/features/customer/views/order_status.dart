import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/models/order.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/router.dart';

class OrderStatus extends ConsumerWidget {
  final String tableNumber;
  const OrderStatus({super.key, required this.tableNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableAsync = ref.watch(getTableByNumberProvider(tableNumber));

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Status for Table $tableNumber'),
      ),
      body: tableAsync.when(
        data: (table) {
          if (table == null) {
            return const Center(child: Text('Table not found.'));
          }

          final activeOrder = table.orders.firstWhereOrNull(
              (o) => o.status == 'pending' || o.status == 'preparing');

          if (activeOrder == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No active order found for this table.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the cart to create a new order
                      context.goNamed(
                        AppRouteNames.customerDashboard,
                        pathParameters: {'tableNumber': tableNumber},
                      );
                    },
                    child: const Text('Create a New Order'),
                  )
                ],
              ),
            );
          }

          // Group dishes to show quantities
          final dishQuantities = activeOrder.dishes
              .groupListsBy((dish) => dish.name)
              .map((key, value) => MapEntry(key, value.length));

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer(

              builder: (context, ref, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Use the null-coalescing operator to handle potential nulls
                          Text('Order ID: ${activeOrder.orderId}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Consumer(builder: (context, ref, child) {
                            final statusAsyncValue = ref.watch(orderStatusProvider(activeOrder.orderId));
                            return statusAsyncValue.when(
                              data: (status) => Text('Status: $status',
                                  style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold)
                                      ),
                              loading: () => const Text('Status: Loading...', style: TextStyle(color: Colors.grey)),
                              error: (e, st) => Text('Status: Error ($e)', style: const TextStyle(color: Colors.red)),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Ordered Items',
                      style: Theme.of(context).textTheme.titleLarge),
                  Consumer(builder: (context, ref, child) {
                    final statusAsyncValue = ref.watch(orderStatusProvider(activeOrder.orderId));
                    return statusAsyncValue.when(
                      data: (status) => Expanded(
                        child: ListView.builder(
                          itemCount: dishQuantities.length,
                          itemBuilder: (context, index) {
                            final dishName = dishQuantities.keys.elementAt(index);
                            final quantity = dishQuantities.values.elementAt(index);
                            return ListTile(
                              leading: (status == 'pending' || status == 'preparing')
                                  ? const Icon(Icons.warning_amber_outlined,
                                      color: Color.fromARGB(255, 81, 255, 0))
                                  : (status == 'delivered')
                                      ? const Icon(Icons.check_circle,
                                          color: Colors.green)
                                      : (status == 'cancelled')
                                          ? const Icon(Icons.cancel,
                                              color: Colors.red)
                                          : null, // No leading icon for other statuses
                              title: Text(dishName),
                              subtitle: Text('Quantity: $quantity'),

                            );
                          },
                        ),
                      ),
                      loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
                      error: (e, st) => Expanded(child: Center(child: Text('Error loading status: $e'))),
                    );
                  }),
                  const Divider(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add More Items'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () {
                      context.goNamed(
                        AppRouteNames.customerDashboard,
                        pathParameters: {'tableNumber': tableNumber},
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text('Ask for Bill'),
                    onPressed: () {
                      context.goNamed(
                        AppRouteNames.bill,
                        pathParameters: {'tableNumber': tableNumber},
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel Full Order'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    // Cancel order confirmation dialog
                    onPressed: () => _showCancelConfirmationDialog(
                        context, ref, activeOrder, tableNumber),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

Future<void> _showCancelConfirmationDialog(
    BuildContext context, WidgetRef ref, Order order, String tableNumber) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Cancel Order'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('Are you sure you want to cancel this entire order?'),
              Text('This action cannot be undone.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Yes, Cancel'),
            onPressed: () async {
              Navigator.of(context).pop(); // Dismiss dialog
              try {
                // Create an updated order with 'cancelled' status
                final updatedOrder = order.copyWith(status: 'cancelled');

                // Update in 'orders' collection (full update for consistency)
                await ref.read(updateOrderProvider(updatedOrder).future);

                // Update in 'tables' document's orders array
                await ref.read(updateOrderInTableProvider(
                  (tableNumber: tableNumber, order: updatedOrder),
                ).future);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order has been cancelled.')),
                );

                // Invalidate the provider to refresh the UI with the updated table data
                ref.invalidate(getTableByNumberProvider(tableNumber));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to cancel order: $e')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

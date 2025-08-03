import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:collection/collection.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';


class OrderDetailsView extends ConsumerWidget {
  final String orderId;
  const OrderDetailsView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(getOrderByIdProvider(orderId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
          onPressed: () {
            context.goNamed(AppRouteNames.waiterDashboard);
          },
        ),
        centerTitle: true,
        title: const Text('Order Details'),
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found.'));
          }

          // Filter dishes (customize this if dishes have status; currently shows all)
          // Example: final activeDishes = order.dishes.where((dish) => dish.status == 'preparing').toList();
          final activeDishes = order.dishes; // Adjust filter as needed for 'preparing' items

          // Group active dishes to show quantities
          final dishQuantities = activeDishes
              .groupListsBy((dish) => dish.name)
              .map((key, value) => MapEntry(key, value.length));

          // Fetch table 
          final tableAsync = ref.watch(getTableByIdProvider(order.tableId));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order ID: ${order.orderId}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 8),
                          tableAsync.when(
                            data: (table) => Text('Table Number: ${table?.tableNumber ?? 'N/A'}',
                                style: const TextStyle(fontSize: 16)),
                            loading: () => const Text('Loading table...'),
                            error: (error, _) => Text('Error loading table: $error',
                                style: const TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(height: 8),
                          Text('Status: ${order.status}',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Timestamp: ${order.timeStamp}'),
                          const SizedBox(height: 8),
                          Text('Total Price: € ${order.price.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Special Instructions: ${order.specialInstructions ?? 'None'}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Ordered Items', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (dishQuantities.isEmpty)
                    const Text('No items in this order.')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dishQuantities.length,
                      itemBuilder: (context, index) {
                        final dishName = dishQuantities.keys.elementAt(index);
                        final quantity = dishQuantities.values.elementAt(index);
                        final dish = activeDishes.firstWhere((d) => d.name == dishName);
                        final itemTotal = (dish.price) * quantity;

                        return ListTile(
                          title: Text(dishName),
                          subtitle: Text(
                              'Quantity: $quantity | Price: € ${dish.price.toStringAsFixed(2)} each'),
                          trailing: Text('Subtotal: € ${itemTotal.toStringAsFixed(2)}'),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  if (order.status != 'served' && order.status != 'cancelled')
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // First update the order status in orders collection
                          await ref.read(updateOrderStatusProvider({'orderId': orderId, 'status': 'served'}).future);
                          
                          // Create updated order object with new status
                          final updatedOrder = order.copyWith(
                            status: 'served',
                            timeStamp: DateTime.now().toIso8601String(),
                          );
                          
                          // Update the order in tables collection with the correct status
                          await ref.read(updateOrderInTableProvider(
                              (tableNumber: tableAsync.value!.tableNumber, order: updatedOrder),
                            ).future);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Order $orderId marked as served!')),
                          );
                          context.goNamed(AppRouteNames.waiterDashboard);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update: $e')),
                          );
                        }
                      },
                      child: const Text('Mark as Served'),
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

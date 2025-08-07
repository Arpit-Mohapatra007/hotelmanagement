import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

// Helper widget to display table number from table ID
class ChefTableDisplayWidget extends ConsumerWidget {
  final String tableId;
  const ChefTableDisplayWidget({super.key, required this.tableId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableAsync = ref.watch(getTableByIdProvider(tableId));
    
    return tableAsync.when(
      data: (table) => Text('Table ${table?.tableNumber ?? tableId}'),
      loading: () => Text('Table $tableId'),
      error: (_, __) => Text('Table $tableId'),
    );
  }
}

class ChefDashboard extends ConsumerWidget {
  const ChefDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(ordersProvider);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
          onPressed: () {
            context.goNamed(AppRouteNames.adminDashboard);
          },
        ),
        title: const Text('Chef Dashboard'),
      ),
      body: orderAsync.when(
        data: (orders) {
          // Filter out cancelled, unknown, and paid orders
          final filteredOrders = orders.where((order) => 
            order.status != 'cancelled' && 
            order.status != 'unknown' && 
            order.status != 'paid' &&
            order.status != 'ready' &&
            order.status != 'served'
          ).toList();
          
          // Sort orders by priority: ready, preparing, served
          filteredOrders.sort((a, b) {
            const statusPriority = {
              'ready': 0,
              'preparing': 1,
              'served': 2,
            };
            return (statusPriority[a.status] ?? 3).compareTo(statusPriority[b.status] ?? 3);
          });
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orders (${filteredOrders.length})',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredOrders.isEmpty
                      ? const Center(
                          child: Text(
                            'No orders available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return _buildOrderCard(context, ref, order);
                          },
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading orders: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, WidgetRef ref, order) {
    // Get status color and icon
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (order.status) {
      case 'ready':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        statusText = 'READY';
        break;
      case 'preparing':
        statusColor = Colors.orange;
        statusIcon = Icons.restaurant;
        statusText = 'PREPARING';
        break;
      case 'served':
        statusColor = Colors.green;
        statusIcon = Icons.check;
        statusText = 'SERVED';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'CANCELLED';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'UNKNOWN';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(
            statusIcon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: ChefTableDisplayWidget(tableId: order.tableId),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          'Order ID: ${order.orderId}\n${order.dishes.length} items',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: _buildTrailingButton(context, ref, order, order.tableId),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dishes:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...order.dishes.map<Widget>((dish) => _buildDishCard(dish)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildTrailingButton(BuildContext context, WidgetRef ref, order, tableId) {
  final tableAsync = ref.watch(getTableByIdProvider(tableId));
  
  // Only show buttons for 'preparing' status
  if (order.status != 'preparing') {
    return null;
  }

  return Row(
    mainAxisSize: MainAxisSize.min, // Important: prevents overflow
    children: [
      // Cancel Button
      ElevatedButton(
        onPressed: () async {
          try {
            // Create an updated order with 'cancelled' status
            final updatedOrder = order.copyWith(status: 'cancelled');

            // Update in 'orders' collection (full update for consistency)
            await ref.read(updateOrderProvider(updatedOrder).future);

            // Update in 'tables' document's orders array
            await ref.read(updateOrderInTableProvider(
              (tableNumber: tableAsync.value!.tableNumber, order: updatedOrder),
            ).future);

            // Invalidate the provider to refresh the UI with the updated table data
            ref.invalidate(getTableByNumberProvider(tableAsync.value!.tableNumber));
            
            await ref.read(
              updateOrderStatusProvider({
                'orderId': order.orderId,
                'status': 'cancelled'
              }).future
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order ${order.orderId} has been cancelled!'),
                backgroundColor: Colors.red,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error cancelling order: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(60, 30), // Compact size
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(fontSize: 10),
        ),
      ),
      const SizedBox(width: 4), // Small space between buttons
      // Ready Button
      ElevatedButton(
        onPressed: () async {
          try {
            // Create an updated order with 'ready' status
            final updatedOrder = order.copyWith(status: 'ready');

            // Update in 'orders' collection (full update for consistency)
            await ref.read(updateOrderProvider(updatedOrder).future);

            // Update in 'tables' document's orders array
            await ref.read(updateOrderInTableProvider(
              (tableNumber: tableAsync.value!.tableNumber, order: updatedOrder),
            ).future);

            // Invalidate the provider to refresh the UI with the updated table data
            ref.invalidate(getTableByNumberProvider(tableAsync.value!.tableNumber));
            
            await ref.read(
              updateOrderStatusProvider({
                'orderId': order.orderId,
                'status': 'ready'
              }).future
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order ${order.orderId} marked as ready!'),
                backgroundColor: Colors.blue,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(60, 30), // Compact size
        ),
        child: const Text(
          'Ready',
          style: TextStyle(fontSize: 10),
        ),
      ),
    ],
  );
}


  Widget _buildDishCard(dish) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: const Color.fromARGB(255, 0, 0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dish.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Qty: 1',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ingredients: ${dish.ingredients}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Price: €${dish.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
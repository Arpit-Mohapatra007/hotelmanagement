import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/router.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

class WaiterDashboard extends ConsumerWidget {
  const WaiterDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
          onPressed: () {
            context.goNamed(AppRouteNames.adminDashboard);
          },
        ),
        title: const Text('Waiter Dashboard'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.topLeft,
              width: MediaQuery.of(context).size.width * 0.9,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ref.watch(getTotalTipsStreamProvider).when(
                data: (totalTips) => Text(
                  'Total Tips Collected: €${totalTips.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
                loading: () => const Text(
                  'Loading tips...',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
                error: (error, stack) => Text(
                  'Error loading tips: $error',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Text(
              'Orders',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: ordersAsync.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return const Center(child: Text('No orders available.'));
                  }
                  
                  // Filter out unknown and paid orders
                  final filteredOrders = orders.where((order) => 
                    order.status != 'unknown' && order.status != 'paid'
                  ).toList();
                  
                  // Sort orders by priority: ready, preparing, served, cancelled
                  filteredOrders.sort((a, b) {
                    const statusPriority = {
                      'ready': 0,
                      'preparing': 1,
                      'served': 2,
                      'cancelled': 3,
                    };
                    return (statusPriority[a.status] ?? 4).compareTo(statusPriority[b.status] ?? 4);
                  });
                  
                  return ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(context, ref, order);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            )
          ],
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
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
              child: Text('Order ID: ${order.orderId}'),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
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
          'Table ID: ${order.tableId}\n${order.dishes.length} dishes',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: _buildTrailingButton(context, ref, order),
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
                ...order.dishes.map<Widget>((dish) => _buildDishCard(dish, order.status)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildTrailingButton(BuildContext context, WidgetRef ref, order) {
    // Don't show dropdown for cancelled orders
    if (order.status == 'cancelled') {
      return null;
    }

    // Define available status options based on current status
    List<String> availableStatuses = [];
    switch (order.status) {
      case 'preparing':
        availableStatuses = ['ready', 'cancelled'];
        break;
      case 'ready':
        availableStatuses = ['served', 'cancelled'];
        break;
      case 'served':
        availableStatuses = ['ready']; // Allow to mark back as ready if needed
        break;
      default:
        return null;
    }

    return DropdownButton<String>(
      icon: const Icon(Icons.more_vert),
      underline: Container(),
      items: availableStatuses.map((String status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(
            _getStatusDisplayName(status),
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      onChanged: (String? newStatus) async {
        if (newStatus != null) {
          try {
            await ref.read(
              updateOrderStatusProvider({
                'orderId': order.orderId,
                'status': newStatus
              }).future
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Order ${order.orderId} marked as ${_getStatusDisplayName(newStatus)}!'
                ),
                backgroundColor: _getStatusColor(newStatus),
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
        }
      },
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'preparing':
        return 'Mark as Preparing';
      case 'ready':
        return 'Mark as Ready';
      case 'served':
        return 'Mark as Served';
      case 'cancelled':
        return 'Cancel Order';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ready':
        return Colors.blue;
      case 'preparing':
        return Colors.orange;
      case 'served':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ignore: strict_top_level_inference
  Widget _buildDishCard(dish, String orderStatus) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: orderStatus == 'ready' ? const Color.fromARGB(255, 11, 150, 249) : Colors.grey[150],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Price: €${dish.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (orderStatus == 'ready')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'READY',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

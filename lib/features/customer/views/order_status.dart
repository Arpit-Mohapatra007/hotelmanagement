// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/constants/order_status.dart';
import 'package:hotelmanagement/core/models/order.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/route_names.dart';

class OrderStatusWidget extends HookConsumerWidget {
  final String tableNumber;
  const OrderStatusWidget({super.key, required this.tableNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableAsync = ref.watch(getTableByNumberProvider(tableNumber));
    
    // Add periodic refresh as backup
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        ref.invalidate(getTableByNumberProvider(tableNumber));
      });
      
      return () => timer.cancel();
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Status - Table $tableNumber'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            context.goNamed(
              AppRouteNames.customerDashboard,
              pathParameters: {'tableNumber': tableNumber},
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(getTableByNumberProvider(tableNumber));
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: tableAsync.when(
          data: (table) {
            if (table == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Table not found', style: TextStyle(fontSize: 18)),
                  ],
                ),
              );
            }

            // Watch the orders stream for real-time updates
            final ordersAsync = ref.watch(getOrdersByTableIdProvider(table.tableId));
            
            return ordersAsync.when(
              data: (allOrders) {
                // Get active orders (preparing, ready, served)
                final activeOrders = allOrders
                    .where((order) => order.status != OrderStatus.cancelled.name)
                    .toList();

                if (activeOrders.isEmpty) {
                  return _buildEmptyState(context);
                }

                return _buildOrdersContent(activeOrders, table, context, ref);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading orders',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text('$error', 
                         style: const TextStyle(color: Colors.grey),
                         textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(getOrdersByTableIdProvider(table.tableId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error loading table data',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text('$error', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(getTableByNumberProvider(tableNumber));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No active orders for this table',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'All orders have been completed or there are no orders yet',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.goNamed(
                AppRouteNames.customerDashboard,
                pathParameters: {'tableNumber': tableNumber},
              );
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Place New Order'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersContent(List<Order> activeOrders, dynamic table, BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with order count and real-time indicator
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.receipt_long, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Active Orders',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${activeOrders.length} order${activeOrders.length > 1 ? 's' : ''} in progress • Live updates',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _buildOverallStatusIndicator(activeOrders),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Orders list grouped by status
          Expanded(
            child: _buildOrdersList(activeOrders),
          ),

          // Action buttons
          const SizedBox(height: 16),
          _buildActionButtons(context, activeOrders, tableNumber, ref),
        ],
      ),
    );
  }

  Widget _buildOverallStatusIndicator(List<Order> orders) {
    final preparingCount = orders.where((o) => o.status == OrderStatus.preparing.name).length;
    final readyCount = orders.where((o) => o.status == OrderStatus.ready.name).length;
    final servedCount = orders.where((o) => o.status == OrderStatus.served.name).length;

    Color indicatorColor;
    String statusText;

    if (readyCount > 0) {
      indicatorColor = Colors.blue;
      statusText = '$readyCount Ready';
    } else if (preparingCount > 0) {
      indicatorColor = Colors.orange;
      statusText = '$preparingCount Preparing';
    } else {
      indicatorColor = Colors.green;
      statusText = '$servedCount Served';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: indicatorColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: indicatorColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    // Group orders by status for better organization
    final ordersByStatus = orders.groupListsBy((order) => order.status);
    
    // Define status order for display
    final statusOrder = [
      OrderStatus.ready.name,
      OrderStatus.preparing.name,
      OrderStatus.served.name,
    ];

    return ListView(
      children: statusOrder.where((status) => ordersByStatus.containsKey(status)).map((status) {
        final statusOrders = ordersByStatus[status]!;
        return _buildStatusSection(status, statusOrders);
      }).toList(),
    );
  }

  Widget _buildStatusSection(String status, List<Order> orders) {
    final statusInfo = _getStatusInfo(status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: status == OrderStatus.ready.name, // Ready orders expanded by default
        leading: Icon(statusInfo['icon'], color: statusInfo['color']),
        title: Text(
          '${statusInfo['title']} (${orders.length})',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: statusInfo['color'],
          ),
        ),
        children: orders.map((order) => _buildOrderCard(order)).toList(),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusInfo = _getStatusInfo(order.status);
    
    // Group dishes by name to show quantities
    final dishQuantities = order.dishes
        .groupListsBy((dish) => dish.name)
        .map((key, value) => MapEntry(key, value.length));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusInfo['color'].withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusInfo['color'].withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          Row(
            children: [
              Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Order ${order.orderId.split('_').last.substring(0, 8)}...',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusInfo['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusInfo['display'],
                  style: TextStyle(
                    color: statusInfo['color'],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Dishes list
          ...dishQuantities.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusInfo['color'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  'Qty: ${entry.value}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'preparing':
        return {
          'icon': Icons.restaurant,
          'color': Colors.orange,
          'title': 'Preparing',
          'display': 'PREPARING',
        };
      case 'ready':
        return {
          'icon': Icons.check_circle,
          'color': Colors.blue,
          'title': 'Ready to Serve',
          'display': 'READY',
        };
      case 'served':
        return {
          'icon': Icons.check,
          'color': Colors.green,
          'title': 'Served',
          'display': 'SERVED',
        };
      default:
        return {
          'icon': Icons.help,
          'color': Colors.grey,
          'title': 'Unknown',
          'display': 'UNKNOWN',
        };
    }
  }

  Widget _buildActionButtons(BuildContext context, List<Order> orders, String tableNumber, WidgetRef ref) {
    return Column(
      children: [
        // Primary actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.goNamed(
                    AppRouteNames.customerDashboard,
                    pathParameters: {'tableNumber': tableNumber},
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add More Items'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.goNamed(
                    AppRouteNames.bill,
                    pathParameters: {'tableNumber': tableNumber},
                  );
                },
                icon: const Icon(Icons.payment),
                label: const Text('Ask for Bill'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Cancel order button
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _showCancelConfirmationDialog(context, ref, orders, tableNumber),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel All Active Orders'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// Enhanced cancel confirmation dialog
Future<void> _showCancelConfirmationDialog(
    BuildContext context, WidgetRef ref, List<Order> orders, String tableNumber) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red),
            SizedBox(width: 8),
            Text('Cancel Orders'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You are about to cancel ${orders.length} active order${orders.length > 1 ? 's' : ''}:'),
              const SizedBox(height: 12),
              ...orders.map((order) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_right, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Order ${order.orderId.split('_').last.substring(0, 8)}... (${order.dishes.length} items)',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 12),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Orders'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _cancelOrders(context, ref, orders, tableNumber);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel All'),
          ),
        ],
      );
    },
  );
}

// Updated cancel function with proper invalidation
Future<void> _cancelOrders(BuildContext context, WidgetRef ref, List<Order> orders, String tableNumber) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    for (final order in orders) {
      final updatedOrder = order.copyWith(status: OrderStatus.cancelled.name);
      
      await ref.read(updateOrderProvider(updatedOrder).future);
      await ref.read(updateOrderInTableProvider(
        (tableNumber: tableNumber, order: updatedOrder),
      ).future);
    }

    // Invalidate all relevant providers for immediate update
    ref.invalidate(getTableByNumberProvider(tableNumber));
    
    // Get table to invalidate orders provider
    final table = ref.read(getTableByNumberProvider(tableNumber)).valueOrNull;
    if (table != null) {
      ref.invalidate(getOrdersByTableIdProvider(table.tableId));
    }

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('${orders.length} order${orders.length > 1 ? 's' : ''} cancelled successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to cancel orders: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

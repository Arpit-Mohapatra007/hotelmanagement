// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/constants/order_status.dart';
import 'package:hotelmanagement/core/dialogs/cancel_all_order_dialog.dart';
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
    
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );
    
    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    // Add periodic refresh as backup
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        ref.invalidate(getTableByNumberProvider(tableNumber));
      });
      return () => timer.cancel();
    }, []);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF6B73FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              _buildCustomAppBar(context),

              Expanded(
                child: RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.blue.shade400,
                  onRefresh: () async {
                    ref.invalidate(getTableByNumberProvider(tableNumber));
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(parent: animationController, curve: Curves.easeOut),
                              ),
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                                  CurvedAnimation(parent: animationController, curve: Curves.elasticOut),
                                ),
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: tableAsync.when(
                          data: (table) {
                            if (table == null) {
                              return _buildTableNotFound();
                            }

                            final ordersAsync = ref.watch(getOrdersByTableIdProvider(table.tableId));
                            return ordersAsync.when(
                              data: (allOrders) {
                                final activeOrders = allOrders
                                    .where((order) => order.status != OrderStatus.cancelled.name)
                                    .toList();

                                if (activeOrders.isEmpty) {
                                  return _buildEmptyState(context);
                                }

                                return _buildOrdersContent(activeOrders, table, context, ref);
                              },
                              loading: () => _buildLoadingState(),
                              error: (error, stack) => _buildErrorState(
                                context,
                                'Error loading orders',
                                error,
                                () => ref.invalidate(getOrdersByTableIdProvider(table.tableId)),
                              ),
                            );
                          },
                          loading: () => _buildLoadingState(),
                          error: (error, stack) => _buildErrorState(
                            context,
                            'Error loading table data',
                            error,
                            () => ref.invalidate(getTableByNumberProvider(tableNumber)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Hero(
            tag: 'back_button_order_status',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () => context.goNamed(
                  AppRouteNames.customerDashboard,
                  pathParameters: {'tableNumber': tableNumber},
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: Text(
              'Order Status - Table $tableNumber',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersContent(List<Order> activeOrders, dynamic table, BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Status Header
        _buildStatusHeader(activeOrders),
        
        // Orders List
        Expanded(
          child: _buildOrdersList(activeOrders),
        ),
        
        // Action Buttons
        _buildActionButtons(context, activeOrders, tableNumber, ref),
      ],
    );
  }

  Widget _buildStatusHeader(List<Order> activeOrders) {
    final preparingCount = activeOrders.where((o) => o.status == OrderStatus.preparing.name).length;
    final readyCount = activeOrders.where((o) => o.status == OrderStatus.ready.name).length;
    final servedCount = activeOrders.where((o) => o.status == OrderStatus.served.name).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Hero(
                tag: 'order_status_icon',
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Active Orders',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1000),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, animation, child) {
                            return Transform.scale(
                              scale: 0.5 + (animation * 0.5),
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(animation),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Text(
                      '${activeOrders.length} order${activeOrders.length > 1 ? 's' : ''} in progress • Live updates',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Status Summary
          Row(
            children: [
              _buildStatusChip('Preparing', preparingCount, Colors.orange),
              const SizedBox(width: 8),
              _buildStatusChip('Ready', readyCount, Colors.blue),
              const SizedBox(width: 8),
              _buildStatusChip('Served', servedCount, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    final ordersByStatus = orders.groupListsBy((order) => order.status);
    final statusOrder = [
      OrderStatus.ready.name,
      OrderStatus.preparing.name,
      OrderStatus.served.name,
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: statusOrder
          .where((status) => ordersByStatus.containsKey(status))
          .map((status) {
        final statusOrders = ordersByStatus[status]!;
        return _buildStatusSection(status, statusOrders);
      }).toList(),
    );
  }

  Widget _buildStatusSection(String status, List<Order> orders) {
    final statusInfo = _getStatusInfo(status);
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                initiallyExpanded: status == OrderStatus.ready.name,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusInfo['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    statusInfo['icon'],
                    color: statusInfo['color'],
                    size: 20,
                  ),
                ),
                title: Text(
                  '${statusInfo['title']} (${orders.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusInfo['color'],
                    fontSize: 16,
                  ),
                ),
                children: orders
                    .asMap()
                    .entries
                    .map((entry) => _buildOrderCard(entry.value, entry.key))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(Order order, int index) {
    final statusInfo = _getStatusInfo(order.status);
    final dishQuantities = order.dishes
        .groupListsBy((dish) => dish.name)
        .map((key, value) => MapEntry(key, value.length));

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusInfo['color'].withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: statusInfo['color'].withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusInfo['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.receipt_rounded,
                          size: 16,
                          color: statusInfo['color'],
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: Text(
                          'Order #${order.orderId.split('_').last.substring(0, 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusInfo['color'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
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
                  
                  const SizedBox(height: 16),
                  
                  // Dishes List
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
                        
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Qty: ${entry.value}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  
                  if (order.specialInstructions?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.note_rounded, size: 16, color: Colors.blue.shade600),
                              const SizedBox(width: 8),
                              Text(
                                'Special Instructions',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.specialInstructions!,
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'preparing':
        return {
          'icon': Icons.restaurant_rounded,
          'color': Colors.orange,
          'title': 'Preparing',
          'display': 'PREPARING',
        };
      case 'ready':
        return {
          'icon': Icons.check_circle_rounded,
          'color': Colors.blue,
          'title': 'Ready to Serve',
          'display': 'READY',
        };
      case 'served':
        return {
          'icon': Icons.check_rounded,
          'color': Colors.green,
          'title': 'Served',
          'display': 'SERVED',
        };
      default:
        return {
          'icon': Icons.help_rounded,
          'color': Colors.grey,
          'title': 'Unknown',
          'display': 'UNKNOWN',
        };
    }
  }

  Widget _buildActionButtons(BuildContext context, List<Order> orders, String tableNumber, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Primary Actions
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'Add More Items',
                  icon: Icons.add_shopping_cart_rounded,
                  color: Colors.orange,
                  onPressed: () => context.goNamed(
                    AppRouteNames.customerDashboard,
                    pathParameters: {'tableNumber': tableNumber},
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: _buildActionButton(
                  label: 'Ask for Bill',
                  icon: Icons.payment_rounded,
                  color: Colors.green,
                  onPressed: () => context.goNamed(
                    AppRouteNames.bill,
                    pathParameters: {'tableNumber': tableNumber},
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Cancel Orders Button
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              label: 'Cancel All Active Orders',
              icon: Icons.cancel_outlined,
              color: Colors.red,
              isOutlined: true,
              onPressed: () async {
                final shouldCancelAll = await showCancelAllOrderDialog(context, orders, tableNumber);
                if (!shouldCancelAll) return;
                
                final tableAsync = ref.watch(getTableByNumberProvider(tableNumber));
                
                for (final order in orders) {
                  if (order.status != OrderStatus.cancelled.name &&
                      order.status != OrderStatus.paid.name &&
                      order.status != OrderStatus.served.name) {
                    try {
                      if (!tableAsync.hasValue || tableAsync.value == null) {
                        throw Exception('Table information not available');
                      }

                      final table = tableAsync.value!;
                      final updatedOrder = order.copyWith(status: OrderStatus.cancelled.name);
                      
                      await ref.read(updateOrderProvider(updatedOrder).future);
                      await ref.read(updateOrderInTableProvider((
                        tableNumber: table.tableNumber,
                        order: updatedOrder,
                      )).future);
                      
                      ref.invalidate(getTableByIdProvider(order.tableId));
                      await ref.read(updateOrderStatusProvider({
                        'orderId': order.orderId,
                        'status': OrderStatus.cancelled.name,
                      }).future);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isOutlined
            ? null
            : LinearGradient(colors: [color.withOpacity(0.8), color]),
        border: isOutlined ? Border.all(color: color, width: 1.5) : null,
        boxShadow: !isOutlined
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isOutlined ? color : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isOutlined ? color : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
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
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, animation, child) {
              return Transform.scale(
                scale: animation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.restaurant_menu_rounded,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'No Active Orders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'All orders have been completed or\nthere are no orders yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          _buildActionButton(
            label: 'Place New Order',
            icon: Icons.add_shopping_cart_rounded,
            color: Colors.blue,
            onPressed: () => context.goNamed(
              AppRouteNames.customerDashboard,
              pathParameters: {'tableNumber': tableNumber},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Loading order status...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String title,
    Object error,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red.shade400,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '$error',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          _buildActionButton(
            label: 'Retry',
            icon: Icons.refresh_rounded,
            color: Colors.blue,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }

  Widget _buildTableNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_restaurant_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Table Not Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'The requested table could not be found',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
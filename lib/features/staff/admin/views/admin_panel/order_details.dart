// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/constants/order_status.dart';
import 'package:hotelmanagement/core/models/dish.dart';
import 'package:hotelmanagement/core/models/order.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Safe opacity extension
extension ColorExtensions on Color {
  Color withOpacityFactor(double opacity) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return withAlpha((safeOpacity * 255).round());
  }
}

class OrderDetails extends HookConsumerWidget {
  final String orderId;
  const OrderDetails({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(getOrderByIdProvider(orderId));

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );
    
    final floatingController = useAnimationController(
      duration: const Duration(milliseconds: 3000),
    );

    final appBarController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    final statusCardController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    final infoCardController = useAnimationController(
      duration: const Duration(milliseconds: 900),
    );

    final dishesController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    final summaryController = useAnimationController(
      duration: const Duration(milliseconds: 1100),
    );

    final fadeAnimation = 
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      );

    final slideAnimation = 
      Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
      );

    final floatingAnimation = useAnimation(
      Tween<double>(begin: -4.0, end: 4.0).animate(
        CurvedAnimation(parent: floatingController, curve: Curves.easeInOut),
      ),
    );

    final appBarAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: appBarController, curve: Curves.easeOut),
      ),
    );

    final statusCardAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: statusCardController, curve: Curves.easeOutBack),
      ),
    );

    final infoCardAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: infoCardController, curve: Curves.easeOutBack),
      ),
    );

    final dishesAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: dishesController, curve: Curves.easeOutBack),
      ),
    );

    final summaryAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: summaryController, curve: Curves.easeOutBack),
      ),
    );

    useEffect(() {
      animationController.forward();
      floatingController.repeat(reverse: true);
      appBarController.forward();
      
      Future.delayed(const Duration(milliseconds: 200), () {
        statusCardController.forward();
      });
      
      Future.delayed(const Duration(milliseconds: 400), () {
        infoCardController.forward();
      });
      
      Future.delayed(const Duration(milliseconds: 600), () {
        dishesController.forward();
      });
      
      Future.delayed(const Duration(milliseconds: 800), () {
        summaryController.forward();
      });
      
      return null;
    }, []);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF9068BE),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildEnhancedAppBar(context, appBarAnimation),
              Expanded(
                child: Transform.translate(
                  offset: Offset(0, floatingAnimation),
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: _buildOrderDetailsContent(
                        context,
                        ref,
                        orderAsync,
                        statusCardAnimation,
                        infoCardAnimation,
                        dishesAnimation,
                        summaryAnimation,
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

  Widget _buildEnhancedAppBar(BuildContext context, double appBarAnimation) {
    return Transform.translate(
      offset: Offset(0, -50 * (1 - appBarAnimation)),
      child: Opacity(
        opacity: appBarAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Enhanced back button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () => context.goNamed(AppRouteNames.adminOrdersView),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacityFactor(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacityFactor(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacityFactor(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              
              // Title
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'ORDER DETAILS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacityFactor(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order ID: $orderId',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacityFactor(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailsContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue orderAsync,
    double statusCardAnimation,
    double infoCardAnimation,
    double dishesAnimation,
    double summaryAnimation,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacityFactor(0.15),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: orderAsync.when(
          data: (order) {
            if (order == null) {
              return const Center(
                child: Text(
                  'Order not found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Status Card
                  Transform.scale(
                    scale: statusCardAnimation,
                    child: _buildStatusCard(order),
                  ),
                  const SizedBox(height: 20),
                  
                  // Order Information Card
                  Transform.scale(
                    scale: infoCardAnimation,
                    child: _buildOrderInfoCard(order, ref),
                  ),
                  const SizedBox(height: 20),
                  
                  // Dishes List
                  Transform.scale(
                    scale: dishesAnimation,
                    child: _buildDishesSection(order),
                  ),
                  const SizedBox(height: 20),
                  
                  // Order Summary
                  Transform.scale(
                    scale: summaryAnimation,
                    child: _buildOrderSummary(order),
                  ),
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  _buildActionButtons(context, ref, order),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading order details...',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ],
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withOpacityFactor(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading order',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.withOpacityFactor(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  style: TextStyle(
                    color: Colors.red.withOpacityFactor(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(getOrderByIdProvider(orderId)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(Order order) {
    Color statusColor = _getStatusColor(order.status);
    IconData statusIcon = _getStatusIcon(order.status);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacityFactor(0.1), statusColor.withOpacityFactor(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacityFactor(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacityFactor(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacityFactor(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              statusIcon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacityFactor(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacityFactor(0.5)),
            ),
            child: Text(
              _getStatusDisplayName(order.status),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(Order order, WidgetRef ref) {
    final tableAsync = ref.watch(getTableByIdProvider(order.tableId));
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Order Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Order ID', order.orderId),
          _buildInfoRow('Table', tableAsync.when(
            data: (table) => 'Table ${table?.tableNumber ?? order.tableId}',
            loading: () => 'Loading...',
            error: (_, __) => order.tableId,
          )),
          _buildInfoRow('Order Time', _formatDateTime(order.timeStamp)),
          _buildInfoRow('Total Items', '${order.dishes.length}'),
          if (order.specialInstructions?.isNotEmpty == true)
            _buildInfoRow('Special Instructions', order.specialInstructions!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishesSection(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.red.shade400],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Ordered Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: order.dishes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final dish = order.dishes[index];
            return AnimatedDishCard(
              dish: dish,
              index: index,
            );
          },
        ),
      ],
    );
  }

  Widget _buildOrderSummary(Order order) {
    final subtotal = order.price;
    const tax = 0.0; // Adjust tax calculation as needed
    final total = subtotal + tax;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.teal.shade400],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal', '€${subtotal.toStringAsFixed(2)}'),
          if (tax > 0) _buildSummaryRow('Tax', '€${tax.toStringAsFixed(2)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(thickness: 1),
          ),
          _buildSummaryRow(
            'Total',
            '€${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.green.shade700 : Colors.grey[700],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.green.shade700 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Order order) {
    if (order.status == OrderStatus.paid.name || 
        order.status == OrderStatus.served.name || 
        order.status == OrderStatus.cancelled.name) {
      return const SizedBox.shrink(); // No actions for completed orders
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.pink.shade400],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (order.status == OrderStatus.preparing.name)
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await ref.read(updateOrderStatusProvider({
                    'orderId': order.orderId,
                    'status': OrderStatus.ready.name
                  }).future);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order marked as ready!'),
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
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark as Ready'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          if (order.status == OrderStatus.ready.name)
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await ref.read(updateOrderStatusProvider({
                    'orderId': order.orderId,
                    'status': OrderStatus.served.name
                  }).future);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order marked as served!'),
                      backgroundColor: Colors.green,
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
              icon: const Icon(Icons.check),
              label: const Text('Mark as Served'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          if (order.status == OrderStatus.preparing.name || order.status == OrderStatus.ready.name) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _showCancelConfirmationDialog(context, ref, order),
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Order'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status) {
      case 'preparing':
        return Colors.orange;
      case 'ready':
        return Colors.blue;
      case 'served':
        return Colors.green;
      case 'paid':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.check_circle;
      case 'served':
        return Icons.check;
      case 'paid':
        return Icons.payment;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'preparing':
        return 'PREPARING';
      case 'ready':
        return 'READY';
      case 'served':
        return 'SERVED';
      case 'paid':
        return 'PAID';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDateTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  Future<void> _showCancelConfirmationDialog(BuildContext context, WidgetRef ref, order) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Order'),
          content: Text('Are you sure you want to cancel order ${order.orderId}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ref.read(updateOrderStatusProvider({
                    'orderId': order.orderId,
                    'status': OrderStatus.cancelled.name
                  }).future);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order has been cancelled!'),
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }
}

// Separate HookWidget for individual dish cards
class AnimatedDishCard extends HookWidget {
  final Dish dish;
  final int index;

  const AnimatedDishCard({
    super.key,
    required this.dish,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final cardController = useAnimationController(
      duration: Duration(milliseconds: 600 + (index * 100)),
    );

    final cardAnimation = 
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: cardController, curve: Curves.easeOutBack),
      );

    final slideAnimation = 
      Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: cardController, curve: Curves.easeOut),
      );

    useEffect(() {
      Future.delayed(Duration(milliseconds: 200 + (index * 100)), () {
        cardController.forward();
      });
      return null;
    }, []);

    return SlideTransition(
      position: slideAnimation,
      child: ScaleTransition(
        scale: cardAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.withOpacityFactor(0.05),
                Colors.red.withOpacityFactor(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.orange.withOpacityFactor(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacityFactor(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Item number
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.red.shade400],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacityFactor(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Dish image or icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: dish.imageUrl?.isNotEmpty == true
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          dish.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.restaurant_menu);
                          },
                        ),
                      )
                    : const Icon(Icons.restaurant_menu),
              ),
              const SizedBox(width: 16),
              
              // Dish details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (dish.description.isNotEmpty)
                      Text(
                        dish.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (dish.category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacityFactor(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dish.category,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '€${dish.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  Text(
                    'Qty: 1',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

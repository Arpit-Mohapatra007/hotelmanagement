import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/constants/order_status.dart';
import 'package:hotelmanagement/core/dialogs/cancel_order_dialog.dart';
import 'package:hotelmanagement/core/models/dish.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

class WaiterDashboard extends ConsumerWidget {
  const WaiterDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

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
              _buildEnhancedAppBar(context),
              
              _buildAnimatedTipsCard(ref),
              
              _buildAnimatedOrdersTitle(),
              
              Expanded(
                child: _buildAnimatedOrdersList(ordersAsync, ref, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - animation)),
          child: Opacity(
            opacity: animation.clamp(0.0, 1.0), 
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () => context.goNamed(AppRouteNames.adminDashboard),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
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
                  
                  Expanded(
                    child: Text(
                      'Waiter Dashboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTipsCard(WidgetRef ref) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation)),
          child: Transform.scale(
            scale: (0.8 + (0.2 * animation)).clamp(0.0, 1.0), // Fixed: Clamp scale
            child: Opacity(
              opacity: animation.clamp(0.0, 1.0), // Fixed: Clamp opacity to valid range
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Animated icon
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1500),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, iconAnimation, child) {
                        return Transform.rotate(
                          angle: 0.1 * (1 - iconAnimation),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green.shade400, Colors.green.shade600],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.attach_money_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Tips content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Tips Collected',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 5),
                          ref.watch(getTotalTipsStreamProvider).when(
                            data: (totalTips) => TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 800),
                              tween: Tween<double>(begin: 0.0, end: totalTips),
                              builder: (context, animatedValue, child) {
                                return Text(
                                  '€${animatedValue.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                );
                              },
                            ),
                            loading: () => const Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.grey,
                              ),
                            ),
                            error: (error, stack) => Text(
                              'Error: $error',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedOrdersTitle() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation)),
          child: Opacity(
            opacity: animation.clamp(0.0, 1.0), // Fixed: Clamp opacity to valid range
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Active Orders',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedOrdersList(AsyncValue ordersAsync, WidgetRef ref, BuildContext context) {
    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return _buildEmptyState();
        }

        // Filter out unknown and paid orders
        final filteredOrders = orders.where((order) =>
            order.status != OrderStatus.paid.name &&
            order.status != OrderStatus.cancelled.name &&
            order.status != OrderStatus.served.name).toList();

        // Sort orders by priority
        filteredOrders.sort((a, b) {
          const statusPriority = {
            'ready': 0,
            'preparing': 1,
          };
          return (statusPriority[a.status] ?? 4).compareTo(statusPriority[b.status] ?? 4);
        });

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 600 + (index * 150)),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, animation, child) {
                return Transform.translate(
                  offset: Offset(50 * (1 - animation), 0),
                  child: Opacity(
                    opacity: animation.clamp(0.0, 1.0), // Fixed: Clamp opacity to valid range
                    child: _buildEnhancedOrderCard(context, ref, filteredOrders[index]),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Loading orders...',
              style: TextStyle(color: Colors.white, fontSize: 16),
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
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation.clamp(0.0, 1.0), // Fixed: Clamp scale
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No active orders',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'All orders are completed!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedOrderCard(BuildContext context, WidgetRef ref, order) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, animation, child) {
            return Transform.scale(
              scale: animation.clamp(0.0, 1.0), // Fixed: Clamp scale
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  statusIcon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            );
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Order ID: ${order.orderId}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            // Animated status badge
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, animation, child) {
                return Transform.scale(
                  scale: animation.clamp(0.0, 1.0), // Fixed: Clamp scale
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.8)),
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
                );
              },
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Table ID: ${order.tableId} • ${order.dishes.length} dishes',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        trailing: _buildEnhancedTrailingButton(context, ref, order),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_rounded,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Dishes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...order.dishes.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final dish = entry.value;
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, animation, child) {
                      return Transform.translate(
                        offset: Offset(30 * (1 - animation), 0),
                        child: Opacity(
                          opacity: animation.clamp(0.0, 1.0), // Fixed: Clamp opacity to valid range
                          child: _buildEnhancedDishCard(dish, order.status),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTrailingButton(BuildContext context, WidgetRef ref, order) {
    final tableAsync = ref.watch(getTableByIdProvider(order.tableId));
    List<String> availableStatuses = [];

    switch (order.status) {
      case 'preparing':
        availableStatuses = [OrderStatus.cancelled.name];
        break;
      case 'ready':
        availableStatuses = [OrderStatus.served.name, OrderStatus.cancelled.name];
        break;
      default:
        return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.more_vert,
          color: Colors.grey.shade600,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => availableStatuses.map((status) {
        return PopupMenuItem<String>(
          value: status,
          child: Row(
            children: [
              Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                _getStatusDisplayName(status),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onSelected: (String newStatus) async {
        if (newStatus == OrderStatus.cancelled.name) {
          final shouldCancel = await showCancelOrderDialog(context, orderId: '${order.orderId}');
          if (!shouldCancel) return;
        }

        try {
          if (!tableAsync.hasValue || tableAsync.value == null) {
            throw Exception('Table information not available');
          }

          final table = tableAsync.value!;
          final updatedOrder = order.copyWith(status: newStatus);

          await ref.read(updateOrderProvider(updatedOrder).future);
          await ref.read(updateOrderInTableProvider((
            tableNumber: table.tableNumber,
            order: updatedOrder,
          )).future);

          ref.invalidate(getTableByIdProvider(order.tableId));

          await ref.read(updateOrderStatusProvider({
            'orderId': order.orderId,
            'status': newStatus,
          }).future);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Order ${order.orderId} marked as ${_getStatusDisplayName(newStatus)}!',
                    ),
                  ),
                ],
              ),
              backgroundColor: _getStatusColor(newStatus),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Error: $e')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  Widget _buildEnhancedDishCard(Dish dish, String orderStatus) {
    final isReady = orderStatus == OrderStatus.ready.name;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isReady
            ? LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
              )
            : LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
              ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReady ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: isReady 
                ? Colors.blue.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Dish icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isReady ? Colors.blue.shade200 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.restaurant_rounded,
              color: isReady ? Colors.blue.shade700 : Colors.grey.shade600,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Dish details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isReady ? Colors.blue.shade800 : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Price: €${dish.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Ready badge
          if (isReady)
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              tween: Tween<double>(begin: 0.8, end: 1.0), // Fixed: Changed to valid range for scale
              builder: (context, animation, child) {
                return Transform.scale(
                  scale: animation.clamp(0.0, 1.0), // Fixed: Clamp scale to prevent issues
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'READY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'served':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
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
}
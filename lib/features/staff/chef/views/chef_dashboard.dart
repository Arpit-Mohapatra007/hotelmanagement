// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/constants/order_status.dart';
import 'package:hotelmanagement/core/dialogs/cancel_order_dialog.dart';
import 'package:hotelmanagement/core/dialogs/ingredients_unavailable_dialog.dart';
import 'package:hotelmanagement/core/models/dish.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/inventory/inventory_provider.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

// Safe opacity extension
extension ColorExtensions on Color {
  Color withOpacityFactor(double opacity) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return withAlpha((safeOpacity * 255).round());
  }
}

// Helper widget to display table number from table ID
class ChefTableDisplayWidget extends ConsumerWidget {
  final String tableId;
  const ChefTableDisplayWidget({super.key, required this.tableId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableAsync = ref.watch(getTableByIdProvider(tableId));
    return tableAsync.when(
      data: (table) => Text(
        'Table ${table?.tableNumber ?? tableId}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xFF2D3748),
        ),
      ),
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
              Expanded(
                child: _buildAnimatedOrdersList(orderAsync, ref, context),
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
        final safeOpacity = animation.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, -50 * (1 - animation)),
          child: Opacity(
            opacity: safeOpacity,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Enhanced back button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () => context.goNamed(AppRouteNames.adminDashboard),
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
                    child: Text(
                      'Chef Dashboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacityFactor(0.3),
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

  Widget _buildAnimatedOrdersList(AsyncValue orderAsync, WidgetRef ref, BuildContext context) {
    return orderAsync.when(
      data: (orders) {
        final filteredOrders = orders.where((order) =>
          order.status != OrderStatus.cancelled.name &&
          order.status != OrderStatus.paid.name &&
          order.status != OrderStatus.ready.name &&
          order.status != OrderStatus.served.name
        ).toList();

        filteredOrders.sort((a, b) {
          const statusPriority = {
            'ready': 0,
            'preparing': 1,
            'served': 2,
          };
          return (statusPriority[a.status] ?? 3).compareTo(statusPriority[b.status] ?? 3);
        });

        if (filteredOrders.isEmpty) {
          return _buildEnhancedEmptyState();
        }

        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, animation, child) {
            final safeOpacity = animation.clamp(0.0, 1.0);
            return Opacity(
              opacity: safeOpacity,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacityFactor(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Column(
                    children: [
                      _buildOrdersHeader(filteredOrders.length),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            return TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 600 + (index * 150)),
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              curve: Curves.easeOutBack,
                              builder: (context, itemAnimation, child) {
                                final safeItemOpacity = itemAnimation.clamp(0.0, 1.0);
                                return Transform.translate(
                                  offset: Offset(50 * (1 - itemAnimation), 0),
                                  child: Opacity(
                                    opacity: safeItemOpacity,
                                    child: _buildEnhancedOrderCard(context, ref, filteredOrders[index]),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => _buildEnhancedLoadingState(),
      error: (error, stack) => _buildEnhancedErrorState(error),
    );
  }

  Widget _buildOrdersHeader(int orderCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
        ),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, animation, child) {
              return Transform.scale(
                scale: animation,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacityFactor(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Orders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$orderCount orders to prepare',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacityFactor(0.1),
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
              scale: animation,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacityFactor(0.4),
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
              child: ChefTableDisplayWidget(tableId: order.tableId),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Order ID: ${order.orderId}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                '${order.dishes.length} dishes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Ingredient availability check
            Consumer(
              builder: (context, ref, child) {
                final ingredientCheck = ref.watch(checkOrderIngredientsProvider(order.orderId));
                return ingredientCheck.when(
                  data: (data) {
                    if (data['allAvailable'] == false) {
                      final unavailable = data['unavailableIngredients'] as List;
                      return TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        builder: (context, warningAnimation, child) {
                          return Transform.scale(
                            scale: warningAnimation,
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.red.shade50, Colors.red.shade100],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacityFactor(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_rounded, color: Colors.red.shade600, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Missing Ingredients',
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          unavailable.join(', '),
                                          style: TextStyle(
                                            color: Colors.red.shade600,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
        trailing: SizedBox(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status badge - reduced size to fit
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, animation, child) {
                  return Transform.scale(
                    scale: animation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacityFactor(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withOpacityFactor(0.8)),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (order.status == OrderStatus.preparing.name) ...[
                const SizedBox(height: 4),
                // Compact action button
                InkWell(
                  onTap: () => _showActionMenu(context, ref, order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.more_vert_rounded, color: Colors.blue.shade700, size: 16), 
                  ),
                ),
              ],
            ],
          ),
        ),
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
                      final safeDishOpacity = animation.clamp(0.0, 1.0);
                      return Transform.translate(
                        offset: Offset(30 * (1 - animation), 0),
                        child: Opacity(
                          opacity: safeDishOpacity,
                          child: _buildEnhancedDishCard(dish),
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

  void _showActionMenu(BuildContext context, WidgetRef ref, order) {
    final tableAsync = ref.watch(getTableByIdProvider(order.tableId));
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacityFactor(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.menu_rounded, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Order Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Cancel',
                    Icons.cancel_rounded,
                    Colors.red,
                    () async {
                      Navigator.pop(context);
                      final shouldCancel = await showCancelOrderDialog(context, orderId: order.orderId);
                      if (!shouldCancel) return;

                      try {
                        final updatedOrder = order.copyWith(status: OrderStatus.cancelled.name);
                        await ref.read(updateOrderProvider(updatedOrder).future);
                        await ref.read(updateOrderInTableProvider((
                          tableNumber: tableAsync.value!.tableNumber,
                          order: updatedOrder,
                        )).future);
                        ref.invalidate(getTableByNumberProvider(tableAsync.value!.tableNumber));
                        await ref.read(updateOrderStatusProvider({
                          'orderId': order.orderId,
                          'status': OrderStatus.cancelled.name
                        }).future);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.cancel, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(child: Text('Order ${order.orderId} cancelled!')),
                              ],
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error cancelling order: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    'Ready',
                    Icons.check_circle_rounded,
                    Colors.green,
                    () async {
                      Navigator.pop(context);
                      
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 20),
                                Text('Processing order...'),
                              ],
                            ),
                          ),
                        ),
                      );

                      try {
                        final deductionResult = await ref.read(deductInventoryForOrderProvider(order.orderId).future);
                        Navigator.of(context).pop();

                        if (deductionResult['success'] == true) {
                          final updatedOrder = order.copyWith(status: OrderStatus.ready.name);
                          await ref.read(updateOrderProvider(updatedOrder).future);
                          await ref.read(updateOrderInTableProvider((
                            tableNumber: tableAsync.value!.tableNumber,
                            order: updatedOrder,
                          )).future);
                          ref.invalidate(getTableByNumberProvider(tableAsync.value!.tableNumber));
                          await ref.read(updateOrderStatusProvider({
                            'orderId': order.orderId,
                            'status': OrderStatus.ready.name
                          }).future);
                          ref.invalidate(checkOrderIngredientsProvider(order.orderId));

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('Order ${order.orderId} ready! Ingredients deducted.')),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        } else {
                          final message = deductionResult['message'] as String;
                          await showIngredientsUnavailableDialog(context, message);
                        }
                      } catch (e) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacityFactor(0.1), color.withOpacityFactor(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacityFactor(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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

  Widget _buildEnhancedDishCard(Dish dish) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacityFactor(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Dish icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Dish name and quantity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '€${dish.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Quantity badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  'Qty: 1',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Ingredients
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.grass_rounded,
                  color: Colors.amber.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ingredients: ${dish.ingredients}',
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedEmptyState() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacityFactor(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.restaurant_outlined,
                    size: 80,
                    color: Colors.white.withOpacityFactor(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No orders to prepare',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacityFactor(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'All caught up! Great job, chef!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacityFactor(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedLoadingState() {
    return const Center(
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
    );
  }

  Widget _buildEnhancedErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.white.withOpacityFactor(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacityFactor(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$error',
            style: TextStyle(
              color: Colors.white.withOpacityFactor(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
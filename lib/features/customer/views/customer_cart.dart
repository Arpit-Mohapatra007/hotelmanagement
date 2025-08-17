import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hotelmanagement/core/constants/order_status.dart';
import 'package:hotelmanagement/core/models/order.dart';
import 'package:hotelmanagement/core/models/dish.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/customer/providers/current_order_provider.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';
import 'package:collection/collection.dart';

class CustomerCart extends HookConsumerWidget {
  final String tableNumber;

  const CustomerCart({super.key, required this.tableNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentOrderState = ref.watch(currentOrderProvider);
    final currentOrderDishes = currentOrderState.dishes;
    final currentOrderTotal = currentOrderState.totalAmount;
    final currentSpecialInstructions = currentOrderState.specialInstructions;
    final tableAsync = ref.watch(getTableByNumberProvider(tableNumber));

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    Order? activeOrder;
    if (tableAsync.hasValue && tableAsync.value != null) {
      activeOrder = tableAsync.value!.orders.firstWhereOrNull(
        (o) => o.status == OrderStatus.preparing.name,
      );
    }

    final Map<Dish, int> dishQuantities = {};
    for (var dish in currentOrderDishes) {
      dishQuantities[dish] = (dishQuantities[dish] ?? 0) + 1;
    }

    final uniqueDishesWithQuantities = dishQuantities.entries.toList();
    final instructionsController = useTextEditingController(text: currentSpecialInstructions);

    useEffect(() {
      if (instructionsController.text != (currentSpecialInstructions ?? '')) {
        instructionsController.text = currentSpecialInstructions ?? '';
      }
      return null;
    }, [currentSpecialInstructions]);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4facfe),
              Color(0xFF00f2fe),
              Color(0xFF4facfe),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Hero(
                      tag: 'back_button_cart',
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
                    const Expanded(
                      child: Text(
                        'Your Cart',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Hero(
                      tag: 'cart_icon',
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(parent: animationController, curve: Curves.easeOut),
                            ),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Cart Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade50,
                                Colors.cyan.shade50,
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  Icons.shopping_cart_rounded,
                                  color: Colors.blue.shade700,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${currentOrderDishes.length} Items',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    Text(
                                      'Total: €${currentOrderTotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Cart Items
                        Expanded(
                          child: currentOrderDishes.isEmpty
                              ? _buildEmptyCart()
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: uniqueDishesWithQuantities.length,
                                  itemBuilder: (context, index) {
                                    final entry = uniqueDishesWithQuantities[index];
                                    return _buildCartItem(entry, index, ref);
                                  },
                                ),
                        ),

                        // Bottom Section
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
                            children: [
                              // Special Instructions
                              _buildInstructionsField(instructionsController, ref),
                              
                              const SizedBox(height: 20),
                              
                              // Order Button
                              _buildOrderButton(
                                context,
                                ref,
                                currentOrderDishes,
                                tableAsync,
                                activeOrder,
                                currentOrderTotal,
                                currentSpecialInstructions,
                                tableNumber,
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildEmptyCart() {
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some delicious dishes to get started!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(MapEntry<Dish, int> entry, int index, WidgetRef ref) {
    final dish = entry.key;
    final dishCount = entry.value;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  // Dish Image
                  Hero(
                    tag: 'dish_${dish.name}_cart',
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                      ),
                      child: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                dish.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.restaurant_menu_rounded,
                              color: Colors.grey.shade400,
                              size: 32,
                            ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Dish Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '€${dish.price.toStringAsFixed(2)} each',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Quantity Controls
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQuantityButton(
                          icon: Icons.remove_circle_outline,
                          color: Colors.red.shade400,
                          onPressed: dishCount > 0
                              ? () {
                                  ref.read(currentOrderProvider.notifier).removeDish(dish);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${dish.name} quantity decreased!'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$dishCount',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ),
                        
                        _buildQuantityButton(
                          icon: Icons.add_circle_outline,
                          color: Colors.green.shade400,
                          onPressed: () {
                            ref.read(currentOrderProvider.notifier).addDish(dish);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${dish.name} quantity increased!'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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

  Widget _buildQuantityButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: onPressed != null ? color : Colors.grey.shade400,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsField(TextEditingController controller, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Special Instructions (optional)',
          hintText: 'Any special requests or dietary requirements...',
          prefixIcon: Icon(Icons.note_add_rounded, color: Colors.blue.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
        maxLines: 2,
        onChanged: (value) {
          ref.read(currentOrderProvider.notifier).updateSpecialInstructions(value);
        },
      ),
    );
  }

  Widget _buildOrderButton(
    BuildContext context,
    WidgetRef ref,
    List<Dish> currentOrderDishes,
    AsyncValue tableAsync,
    Order? activeOrder,
    double currentOrderTotal,
    String? currentSpecialInstructions,
    String tableNumber,
  ) {
    final isEnabled = currentOrderDishes.isNotEmpty && tableAsync.hasValue;
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: isEnabled
              ? [Colors.orange.shade400, Colors.orange.shade600]
              : [Colors.grey.shade300, Colors.grey.shade400],
        ),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: isEnabled
              ? () async {
                  final currentTable = tableAsync.value!;
                  try {
                    if (activeOrder != null) {
                      // Update existing order
                      final updatedDishes = [...activeOrder.dishes, ...currentOrderDishes];
                      final updatedTotal = updatedDishes.fold(0.0, (total, dish) => total + dish.price);
                      final updatedOrder = activeOrder.copyWith(
                        dishes: updatedDishes,
                        price: updatedTotal,
                        specialInstructions: currentSpecialInstructions ?? activeOrder.specialInstructions,
                        timeStamp: DateTime.now().toIso8601String(),
                      );

                      await ref.read(updateOrderProvider(updatedOrder).future);
                      await ref.read(updateOrderInTableProvider((
                        tableNumber: currentTable.tableNumber,
                        order: updatedOrder
                      )).future);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Order updated successfully!'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      // Create new order
                      final newOrder = Order(
                        tableId: currentTable.tableId,
                        orderId: '${currentTable.tableId}_order_${DateTime.now().millisecondsSinceEpoch}',
                        dishes: List.from(currentOrderDishes),
                        price: currentOrderTotal,
                        timeStamp: DateTime.now().toIso8601String(),
                        status: OrderStatus.preparing.name,
                        specialInstructions: currentSpecialInstructions,
                      );

                      await ref.read(addOrderProvider(newOrder).future);
                      await ref.read(addOrderToTableProvider((
                        tableNumber: currentTable.tableNumber,
                        order: newOrder
                      )).future);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Text('New order placed successfully!'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }

                    // Clear the cart
                    ref.read(currentOrderProvider.notifier).clearOrder();
                    // Invalidate providers to refresh UI
                    ref.invalidate(getTableByNumberProvider(tableNumber));
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to place/update order: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              : null,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  activeOrder != null ? Icons.update_rounded : Icons.send_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  activeOrder != null ? 'Update Order' : 'Place Order',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

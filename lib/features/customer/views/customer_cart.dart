import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart'; 
import 'package:hotelmanagement/core/models/order.dart';
import 'package:hotelmanagement/core/models/dish.dart';
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

    Order? activeOrder;
    if (tableAsync.hasValue && tableAsync.value != null) {
      activeOrder = tableAsync.value!.orders.firstWhereOrNull(
        (o) => o.status == 'pending' || o.status == 'preparing',
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
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: currentOrderDishes.isEmpty
                ? const Center(
                    child: Text(
                      'Your cart is empty. Add some dishes!',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    // Iterate over the list of unique dishes with their quantities
                    itemCount: uniqueDishesWithQuantities.length,
                    itemBuilder: (context, index) {
                      final entry = uniqueDishesWithQuantities[index];
                      final dish = entry.key;   // The unique Dish object
                      final dishCount = entry.value; // The quantity of this unique dish

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        elevation: 2.0,
                        child: ListTile(
                          leading: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(dish.imageUrl!),
                                )
                              : const CircleAvatar(
                                  child: Icon(Icons.restaurant_menu),
                                ),
                          title: Text(
                            dish.name,
                            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Price: €${dish.price.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 14.0, color: Colors.grey[300]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$dishCount',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              IconButton( // Changed to add_circle for cart
                                icon: const Icon(Icons.add_circle),
                                color: Colors.green,
                                onPressed: () {
                                  ref.read(currentOrderProvider.notifier).addDish(dish);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${dish.name} quantity increased!')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                color: Colors.red,
                                onPressed: dishCount > 0
                                    ? () {
                                        ref.read(currentOrderProvider.notifier).removeDish(dish);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${dish.name} quantity decreased!')),
                                        );
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: €${currentOrderTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                TextField( // Use the instructionsController
                  controller: instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'Special Instructions (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(currentOrderProvider.notifier).updateSpecialInstructions(value);
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton.icon(
                    onPressed: currentOrderDishes.isEmpty || !tableAsync.hasValue
                ? null
                : () async {
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

                        // Update in both collections
                        await ref.read(updateOrderProvider(updatedOrder).future);
                        await ref.read(updateOrderInTableProvider(
                          (tableNumber: currentTable.tableNumber, order: updatedOrder)
                        ).future);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order updated successfully!')),
                        );
                      } else {
                        // Create new order
                        final newOrder = Order(
                          tableId: currentTable.tableId,
                          orderId: '${currentTable.tableId}_order_${DateTime.now().millisecondsSinceEpoch}',
                          dishes: List.from(currentOrderDishes),
                          price: currentOrderTotal,
                          timeStamp: DateTime.now().toIso8601String(),
                          status: 'preparing', 
                          specialInstructions: currentSpecialInstructions,
                        );

                        // Add to both collections - FIXED: Use correct providers
                        await ref.read(addOrderProvider(newOrder).future);
                        await ref.read(addOrderToTableProvider(
                          (tableNumber: currentTable.tableNumber, order: newOrder)
                        ).future);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('New order placed successfully!')),
                        );
                      }

                      // Clear the cart
                      ref.read(currentOrderProvider.notifier).clearOrder();
                      
                      // Invalidate providers to refresh UI
                      ref.invalidate(getTableByNumberProvider(tableNumber));
                      
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to place/update order: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: Text(activeOrder != null ? 'Update Order' : 'Place Order'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
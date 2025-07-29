import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart'; 
import 'package:hotelmanagement/core/models/order.dart';
import 'package:hotelmanagement/core/models/dish.dart';
import 'package:hotelmanagement/features/customer/providers/current_order_provider.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

class CustomerCart extends HookConsumerWidget {
  final String tableNumber;
  const CustomerCart({super.key, required this.tableNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current order dishes and total from the global cart provider
    final currentOrderState = ref.watch(currentOrderProvider);
    final currentOrderDishes = currentOrderState.dishes;
    final currentOrderTotal = currentOrderState.totalAmount;
    final currentSpecialInstructions = currentOrderState.specialInstructions;

    // Watch the table data to get tableId for placing order
    final tableAsync = ref.watch(getTableByNumberProvider(tableNumber));

    // Create a map to store unique dishes and their quantities for display
    final Map<Dish, int> dishQuantities = {};
    for (var dish in currentOrderDishes) {
      dishQuantities[dish] = (dishQuantities[dish] ?? 0) + 1;
    }

    // Convert map entries to a list for ListView.builder to iterate over unique items
    final uniqueDishesWithQuantities = dishQuantities.entries.toList();
    
    // Use useTextEditingController for proper state management across rebuilds
    final instructionsController = useTextEditingController(text: currentSpecialInstructions);

    // Keep the controller's text in sync with the provider's state,
    // in case special instructions are updated from elsewhere or initially loaded.
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
                              // Display count of dish in order
                              Text(
                                '$dishCount', // Show the count of this specific dish
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              IconButton(
                                icon: const Icon(Icons.add_circle), // Changed to add_circle for cart
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
                                onPressed: dishCount > 0 // Only enable if dish is in cart
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
                TextField(
                  // Use the instructionsController
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
                      ? null // Disable button if order is empty or table data is not loaded
                      : () async {
                          final currentTable = tableAsync.value!; // Safe to use due to hasValue check
                          
                          try {
                            // Create the order with proper error handling
                            final newOrder = Order(
                              tableId: currentTable.tableId,
                              orderId: '${currentTable.tableId}_order_${DateTime.now().millisecondsSinceEpoch}',
                              dishes: List<Dish>.from(currentOrderDishes), // Ensure proper list type
                              price: currentOrderTotal,
                              timeStamp: DateTime.now().toIso8601String(),
                              status: 'preparing', // Fixed typo: 'prepairing' -> 'preparing'
                              specialInstructions: currentSpecialInstructions,
                            );
                            
                            
                            // Add order to its own 'orders' collection
                            await ref.read(addOrderProvider(newOrder).future);
                            
                            // Add the order to the table's 'orders' array in Firestore
                            await ref.read(addOrderToTableProvider(
                              (tableNumber: currentTable.tableNumber, order: newOrder)
                            ).future);

                            ref.read(currentOrderProvider.notifier).clearOrder();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order placed successfully!')),
                            );
                            Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to place order: $e')),
                            );
                          }
                        },
                  icon: const Icon(Icons.send),
                  label: const Text('Place Order'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // Make button full width
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
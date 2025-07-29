// Path: lib/features/customer/views/customer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/features/dish/dish_provider.dart';
import 'package:hotelmanagement/features/customer/providers/current_order_provider.dart';
import 'package:go_router/go_router.dart'; 
import 'package:hotelmanagement/core/router/router.dart';

class CustomerDashboard extends HookConsumerWidget {
  final String tableNumber;
  const CustomerDashboard({required this.tableNumber,super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController(); 
    final searchQuery = ref.watch(dishSearchQueryProvider);
    // Watch searchedDishesProvider directly based on the searchQuery
    final dishesAsync = ref.watch(searchedDishesProvider(searchQuery));
    // Watch the current order dishes and total for displaying in the UI
    final currentOrderDishes = ref.watch(currentOrderDishesProvider);
    final currentOrderTotal = ref.watch(currentOrderTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Table $tableNumber'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            iconSize: 30.0,
            onPressed: () {
                    context.goNamed(
                      AppRouteNames.customerCart,
                      pathParameters: {'tableNumber': tableNumber},
                    );
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8.0),
          // Display current order summary in AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Items: ${currentOrderDishes.length} | Total: €${currentOrderTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController, 
                    decoration: const InputDecoration(
                      labelText: 'Search your dish',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      // Automatically trigger search on submit (Enter key)
                      ref.read(dishSearchQueryProvider.notifier).state = value.trim();
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    // Trigger search on button press
                    ref.read(dishSearchQueryProvider.notifier).state = searchController.text.trim();
                  },
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          // Placeholder for an image of hot sale
          GestureDetector(
            onTap: () {

            },
            child: Container( 
              height: MediaQuery.of(context).size.height * 0.3, 
              decoration: BoxDecoration(
                color: Colors.grey, // Placeholder color
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: EdgeInsets.all(16.0),
            ),
          ),
          const SizedBox(height: 8.0),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: dishesAsync.when(
              data: (dishes) {
                if (dishes.isEmpty && searchQuery.isNotEmpty) {
                  return const Center(child: Text('No dishes found for your search.'));
                } else if (dishes.isEmpty) {
                  return const Center(child: Text('No dishes available.'));
                }
                return ListView.builder(
                  itemCount: dishes.length,
                  itemBuilder: (context, index) {
                    final dish = dishes[index];
                    // Watch the count of this specific dish in the current order
                    final dishCount = ref.watch(dishCountInOrderProvider(dish));
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
                          style: const TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          dish.description,
                          style: TextStyle(fontSize: 14.0, color: Colors.grey[300]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '€${dish.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8.0),
                            // Display count of dish in order
                            if (dishCount > 0)
                              Text(
                                '$dishCount',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            const SizedBox(width: 4.0),
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              color: Colors.green,
                              onPressed: dish.isAvailable
                                  ? () {
                                      ref.read(currentOrderProvider.notifier).addDish(dish);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${dish.name} added to order!')),
                                      );
                                    }
                                  : null, // Button is disabled if dish is not available
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              color: Colors.red,
                              onPressed: dishCount > 0 // Only enable if dish is in cart
                                  ? () {
                                      ref.read(currentOrderProvider.notifier).removeDish(dish);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${dish.name} removed from order!')),
                                      );
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
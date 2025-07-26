import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/features/dishes/providers/dish_providers.dart';

class CustomerDashboard extends HookConsumerWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final dishesAsync = ref.watch(dishesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Number: 1'),
      ),
      body: Column(
        children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded( // Added Expanded to prevent overflow
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () {
                  // Handle search action
                },
                child: Icon(Icons.search),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
          GestureDetector(
            onTap: () {
              //Hot Deal or Bestseller item 
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.95,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey[200],
              ),
            ),
          ),
        const SizedBox(height: 10.0),
        Expanded(
          child: dishesAsync.when(
            data: (dishes) {
              if (dishes.isEmpty) {
                return const Center(child: Text('No dishes available'));
              }
              return ListView.builder(
                itemCount: dishes.length,
                itemBuilder: (context, index) {
                  final dish = dishes[index];
                  return ListTile(
                    title: Text(dish.name),
                    subtitle: Text(dish.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(dish.price.toString()),
                        const SizedBox(width: 8.0),
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          color: Colors.green,
                          onPressed: dish.isAvailable
                            ? () {
                                // Add dish to cart/order
                              }
                            : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle),
                          color: Colors.red,
                          onPressed: () {
                            // Remove dish from cart/order
                          },
                        ),
                      ]
                    )
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
        ]
      ),
    );
  }
}
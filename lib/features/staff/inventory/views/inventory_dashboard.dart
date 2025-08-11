import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/core/models/inventory.dart';
import 'package:hotelmanagement/features/inventory/inventory_provider.dart';

class InventoryDashboard extends ConsumerWidget {
  const InventoryDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsyncValue = ref.watch(getInventoryStreamProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
          onPressed: () {
            context.goNamed(AppRouteNames.adminDashboard);
          },
        ),
        title: const Text('Inventory Dashboard'), 
      ),
      body: inventoryAsyncValue.when(
        data: (inventoryList) => _buildInventoryContent(context, ref, inventoryList),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading inventory: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(getInventoryStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInventoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInventoryContent(BuildContext context, WidgetRef ref, List<Inventory> inventoryList) {
    if (inventoryList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No inventory items found'),
            Text('Tap the + button to add items'),
          ],
        ),
      );
    }

    // Separate low stock items (quantity < 10) from regular inventory
    final lowStockItems = inventoryList.where((item) => item.quantity < 10).toList();
    final regularItems = inventoryList.where((item) => item.quantity >= 10).toList();

    return Column(
      children: [
        if (lowStockItems.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Low Stock Items (${lowStockItems.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: lowStockItems.length,
              itemBuilder: (context, index) => _buildInventoryCard(context, ref, lowStockItems[index], isLowStock: true),
            ),
          ),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.green.shade50,
          child: Row(
            children: [
              const Icon(Icons.inventory, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Regular Inventory (${regularItems.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: regularItems.length,
            itemBuilder: (context, index) => _buildInventoryCard(context, ref, regularItems[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard(BuildContext context, WidgetRef ref, Inventory item, {bool isLowStock = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isLowStock ? Colors.red.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isLowStock ? Colors.red.shade700 : null,
                    ),
                  ),
                  Text(
                    'Є ${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isLowStock ? Colors.red.shade600 : Colors.grey,
                    ),
                  ),
                  Text(
                    'Quantity: ${item.quantity}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isLowStock ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    final updateFunction = ref.read(updateInventoryProvider);
                    updateFunction(item.id, 1);
                  },
                  icon: const Icon(Icons.add, color: Colors.green),
                  tooltip: 'Increase quantity',
                ),
                IconButton(
                  onPressed: item.quantity > 0 
                      ? () {
                          final updateFunction = ref.read(updateInventoryProvider);
                          updateFunction(item.id, -1);
                        }
                      : null,
                  icon: const Icon(Icons.remove, color: Colors.orange),
                  tooltip: 'Decrease quantity',
                ),
                IconButton(
                  onPressed: () => _deleteInventoryItem(context, ref, item),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete item',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteInventoryItem(BuildContext context, WidgetRef ref, Inventory item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(deleteInventoryProvider(item.id));
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddInventoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final inventoryAsyncValue = ref.watch(getInventoryStreamProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Inventory Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price (Є)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  quantityController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                final newInventory = Inventory(
                  id: 'I0${inventoryAsyncValue.value!.length + 1}',
                  name: nameController.text,
                  quantity: int.parse(quantityController.text),
                  price: double.parse(priceController.text),
                );
                ref.read(addInventoryProvider(newInventory));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
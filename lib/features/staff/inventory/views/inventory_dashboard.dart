import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/dialogs/delete_item_dialog.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/core/models/inventory.dart';
import 'package:hotelmanagement/features/inventory/inventory_provider.dart';

// Safe opacity extension
extension ColorExtensions on Color {
  Color withOpacityFactor(double opacity) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return withAlpha((safeOpacity * 255).round());
  }
}

class InventoryDashboard extends ConsumerWidget {
  const InventoryDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsyncValue = ref.watch(getInventoryStreamProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2196F3),
              Color(0xFF21CBF3),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildEnhancedAppBar(context),
              Expanded(
                child: inventoryAsyncValue.when(
                  data: (inventoryList) => _buildAnimatedInventoryContent(context, ref, inventoryList),
                  loading: () => _buildEnhancedLoadingState(),
                  error: (error, stackTrace) => _buildEnhancedErrorState(error, ref),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildAnimatedFAB(context, ref),
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
                      'Inventory Dashboard',
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

  Widget _buildAnimatedInventoryContent(BuildContext context, WidgetRef ref, List<Inventory> inventoryList) {
    if (inventoryList.isEmpty) {
      return _buildEnhancedEmptyState();
    }

    final lowStockItems = inventoryList.where((item) => item.quantity < 10).toList();
    final regularItems = inventoryList.where((item) => item.quantity >= 10).toList();

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
                  // Low stock section
                  if (lowStockItems.isNotEmpty) ...[
                    _buildSectionHeader(
                      'Low Stock Alert',
                      lowStockItems.length,
                      Icons.warning_rounded,
                      Colors.red,
                      isWarning: true,
                    ),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: lowStockItems.length,
                        itemBuilder: (context, index) {
                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 400 + (index * 100)),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            builder: (context, itemAnimation, child) {
                              return Transform.translate(
                                offset: Offset(50 * (1 - itemAnimation), 0),
                                child: Opacity(
                                  opacity: itemAnimation,
                                  child: _buildEnhancedInventoryCard(
                                    context,
                                    ref,
                                    lowStockItems[index],
                                    isLowStock: true,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                  
                  // Regular inventory section
                  _buildSectionHeader(
                    'Regular Inventory',
                    regularItems.length,
                    Icons.inventory_2_rounded,
                    Colors.green,
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: regularItems.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 600 + (index * 100)),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, animation, child) {
                            return Transform.translate(
                              offset: Offset(30 * (1 - animation), 0),
                              child: Opacity(
                                opacity: animation,
                                child: _buildEnhancedInventoryCard(
                                  context,
                                  ref,
                                  regularItems[index],
                                ),
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
  }

  Widget _buildSectionHeader(String title, int count, IconData icon, Color color, {bool isWarning = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isWarning
              ? [Colors.red.shade50, Colors.red.shade100]
              : [Colors.green.shade50, Colors.green.shade100],
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacityFactor(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              );
            },
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '$count items',
                  style: TextStyle(
                    color: color.withOpacityFactor(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (isWarning)
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              tween: Tween<double>(begin: 0.8, end: 1.2),
              builder: (context, pulseAnimation, child) {
                return Transform.scale(
                  scale: pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacityFactor(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

  Widget _buildEnhancedInventoryCard(BuildContext context, WidgetRef ref, Inventory item, {bool isLowStock = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isLowStock
            ? LinearGradient(
                colors: [Colors.red.shade50, Colors.red.shade100],
              )
            : LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLowStock ? Colors.red.shade200 : Colors.grey.shade200,
          width: isLowStock ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isLowStock
                ? Colors.red.withOpacityFactor(0.1)
                : Colors.grey.withOpacityFactor(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Item icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLowStock ? Colors.red.shade200 : Colors.blue.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                color: isLowStock ? Colors.red.shade700 : Colors.blue.shade700,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLowStock ? Colors.red.shade700 : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '€${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLowStock ? Colors.red.shade200 : Colors.green.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Qty: ${item.quantity}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isLowStock ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Action buttons
            Column(
              children: [
                _buildActionButton(
                  Icons.add_rounded,
                  Colors.green,
                  'Increase',
                  () {
                    final updateFunction = ref.read(updateInventoryProvider);
                    updateFunction(item.id, 1);
                  },
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  Icons.remove_rounded,
                  Colors.orange,
                  'Decrease',
                  item.quantity > 0
                      ? () {
                          final updateFunction = ref.read(updateInventoryProvider);
                          updateFunction(item.id, -1);
                        }
                      : null,
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  Icons.delete_rounded,
                  Colors.red,
                  'Delete',
                  () => _showEnhancedDeleteDialog(context, ref, item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, String tooltip, VoidCallback? onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: onPressed != null ? color.withOpacityFactor(0.1) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: onPressed != null ? color.withOpacityFactor(0.3) : Colors.grey.shade300,
            ),
          ),
          child: Icon(
            icon,
            color: onPressed != null ? color : Colors.grey.shade400,
            size: 20,
          ),
        ),
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
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.white.withOpacityFactor(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No inventory items found',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacityFactor(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add items',
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
            'Loading inventory...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedErrorState(Object error, WidgetRef ref) {
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
            'Error loading inventory',
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.refresh(getInventoryStreamProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFAB(BuildContext context, WidgetRef ref) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation*0.8,
          child: FloatingActionButton.extended(
            onPressed: () => _showEnhancedAddInventoryDialog(context, ref),
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue.shade700,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Item',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }

  void _showEnhancedDeleteDialog(BuildContext context, WidgetRef ref, Inventory item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red.shade600),
            const SizedBox(width: 12),
            const Text('Delete Item'),
          ],
        ),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final shouldDelete = await showDeleteItemDialog(
                context: context,
                itemName: item.name,
              );
              if (!shouldDelete) return;

              ref.read(deleteInventoryProvider(item.id));
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${item.name} deleted successfully')),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEnhancedAddInventoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final inventoryAsyncValue = ref.watch(getInventoryStreamProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.add_box_rounded, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            const Text('Add Inventory Item'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.inventory_2_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price (€)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.euro_rounded),
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

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(child: Text('${newInventory.name} added successfully')),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmanagement/core/models/inventory.dart';
import 'package:hotelmanagement/features/inventory/inventory_repository.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) => InventoryRepository());

final getInventoryStreamProvider = StreamProvider<List<Inventory>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getInventoryStream();
});

final addInventoryProvider = FutureProvider.family<void, Inventory>((ref, inventory) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.addInventory(inventory);
});

final deleteInventoryProvider = FutureProvider.family<void, String>((ref, id) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.deleteInventory(id);
});

// Changed from FutureProvider.family to avoid caching issues
final updateInventoryProvider = Provider<Future<void> Function(String id, int quantityChange)>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  
  return (String id, int quantityChange) async {
    try {
      await repository.updateInventory(id, quantityChange);
    } catch (e) {
      rethrow;
    }
  };
});

// Check ingredient availability for an order
final checkOrderIngredientsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) async {
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  final order = await ref.read(getOrderByIdProvider(orderId).future);
  
  if (order == null) {
    throw Exception('Order not found');
  }

  final allIngredients = <String>[];
  final unavailableIngredients = <String>[];
  final ingredientQuantities = <String, int>{};

  // Collect all ingredients from all dishes
  for (final dish in order.dishes) {
    final ingredients = dish.ingredients.split(',');
    for (final ingredient in ingredients) {
      final trimmedIngredient = ingredient.toLowerCase().trim();
      allIngredients.add(trimmedIngredient);
    }
  }

  // Check availability for each unique ingredient
  final uniqueIngredients = allIngredients.toSet().toList();
  for (final ingredient in uniqueIngredients) {
    final quantity = await inventoryRepo.getIngredientQuantity(ingredient);
    ingredientQuantities[ingredient] = quantity;
    
    if (quantity <= 0) {
      unavailableIngredients.add(ingredient);
    }
  }

  return {
    'allAvailable': unavailableIngredients.isEmpty,
    'unavailableIngredients': unavailableIngredients,
    'ingredientQuantities': ingredientQuantities,
  };
});

// Deduct inventory for order (only if all ingredients are available)
final deductInventoryForOrderProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) async {
  final inventoryRepo = ref.watch(inventoryRepositoryProvider);
  final order = await ref.read(getOrderByIdProvider(orderId).future);
  
  if (order == null) {
    throw Exception('Order not found');
  }

  final allIngredients = <String>[];
  final deductionResults = <String, bool>{};
  final failedDeductions = <String>[];

  // Collect all ingredients
  for (final dish in order.dishes) {
    final ingredients = dish.ingredients.split(',');
    for (final ingredient in ingredients) {
      final trimmedIngredient = ingredient.toLowerCase().trim();
      allIngredients.add(trimmedIngredient);
    }
  }

  // First, check if all ingredients are available
  for (final ingredient in allIngredients) {
    final isAvailable = await inventoryRepo.checkIngredientAvailability(ingredient, 1);
    if (!isAvailable) {
      failedDeductions.add(ingredient);
    }
  }

  // If any ingredient is not available, don't deduct anything
  if (failedDeductions.isNotEmpty) {
    return {
      'success': false,
      'message': 'Ingredients not available: ${failedDeductions.join(', ')}',
      'unavailableIngredients': failedDeductions,
    };
  }

  // All ingredients are available, proceed with deduction
  for (final ingredient in allIngredients) {
    final success = await inventoryRepo.inventoryDeduction(ingredient);
    deductionResults[ingredient] = success;
    
    if (!success) {
      failedDeductions.add(ingredient);
    }
  }

  if (failedDeductions.isEmpty) {
    return {
      'success': true,
      'message': 'All ingredients deducted successfully',
      'deductedIngredients': allIngredients,
    };
  } else {
    return {
      'success': false,
      'message': 'Failed to deduct some ingredients: ${failedDeductions.join(', ')}',
      'failedIngredients': failedDeductions,
    };
  }
});
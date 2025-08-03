import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmanagement/core/models/inventory.dart';
import 'package:hotelmanagement/features/inventory/inventory_repository.dart';

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
    print('🎯 DEBUG: updateInventory function called');
    print('   - ID: "$id"');
    print('   - Quantity Change: $quantityChange');
    
    try {
      await repository.updateInventory(id, quantityChange);
      print('✅ Provider: Repository call completed successfully');
    } catch (e) {
      print('❌ ERROR in updateInventory: $e');
      print('   - Error type: ${e.runtimeType}');
      rethrow;
    }
  };
});
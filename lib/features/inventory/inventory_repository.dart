import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotelmanagement/core/models/inventory.dart';

class InventoryRepository {
  Future<void> addInventory(Inventory inventory) async {
    // Serialize inventory before saving
    final serializedInventory = inventory.toJson();
    
    // Use the inventory's ID as the document ID for consistency
    await FirebaseFirestore.instance
        .collection('inventory')
        .doc(inventory.id)
        .set(serializedInventory);
  }

  Future<void> updateInventory(String id, int quantityChange) async {
    await FirebaseFirestore.instance.collection('inventory').doc(id).update({'quantity': FieldValue.increment(quantityChange)});
  }

  Future<void> deleteInventory(String id) async {
    await FirebaseFirestore.instance.collection('inventory').doc(id).delete();
  }

  Stream<List<Inventory>> getInventoryStream() {
    return FirebaseFirestore.instance.collection('inventory').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Inventory.fromJson(doc.data())).toList();
    });
  }

  // Check if ingredient is available in sufficient quantity
  Future<bool> checkIngredientAvailability(String name, int requiredQuantity) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('inventory')
        .where('name', isEqualTo: name.toLowerCase().trim())
        .get();
    
    if (snapshot.docs.isEmpty) {
      return false; // Ingredient not found
    }
    
    final doc = snapshot.docs.first;
    final currentQuantity = doc.data()['quantity'] as int? ?? 0;
    return currentQuantity >= requiredQuantity;
  }

  // Check availability for multiple ingredients
  Future<Map<String, bool>> checkMultipleIngredientsAvailability(List<String> ingredients) async {
    final availabilityMap = <String, bool>{};
    
    for (final ingredient in ingredients) {
      final isAvailable = await checkIngredientAvailability(ingredient.toLowerCase().trim(), 1);
      availabilityMap[ingredient.toLowerCase().trim()] = isAvailable;
    }
    
    return availabilityMap;
  }

  Future<bool> inventoryDeduction(String name) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('inventory')
        .where('name', isEqualTo: name.toLowerCase().trim())
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final currentQuantity = doc.data()['quantity'] as int? ?? 0;
      
      if (currentQuantity > 0) {
        await updateInventory(doc.id, -1);
        return true;
      } else {
        return false; // Not enough quantity
      }
    } else {
      return false; // Ingredient not found
    }
  }

  // Get current quantity of an ingredient
  Future<int> getIngredientQuantity(String name) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('inventory')
        .where('name', isEqualTo: name.toLowerCase().trim())
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data()['quantity'] as int? ?? 0;
    }
    return 0;
  }
}
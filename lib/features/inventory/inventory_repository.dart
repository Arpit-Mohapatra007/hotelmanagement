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
}
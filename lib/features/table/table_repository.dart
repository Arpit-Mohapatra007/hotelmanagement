import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:hotelmanagement/core/models/table.dart';
import 'package:hotelmanagement/core/models/order.dart'; 

class TableRepository {
  //add table
  Future<void> addTable(Table table) async {
    await FirebaseFirestore.instance.collection('tables').add(table.toJson());
  }
  //delete table
  Future<void> deleteTable(String tableNumber) async {
    await FirebaseFirestore.instance.collection('tables').doc(tableNumber).delete();
  }
  //get all table
  Stream<List<Table>> getAllTables() {
    return FirebaseFirestore.instance.collection('tables').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Table.fromJson(doc.data())).toList();
    });
  }
  //get table by number
  Future<Table?> getTableByNumber(String tableNumber) async {
    final doc = await FirebaseFirestore.instance.collection('tables').doc(tableNumber).get();
    if (doc.exists) {
      return Table.fromJson(doc.data()!);
    }
    return null;
  }
  //add a order to a table
  Future<void> addOrderToTable(String tableNumber, Order order) async {
    await FirebaseFirestore.instance.collection('tables').doc(tableNumber).update({
      'orders': FieldValue.arrayUnion([order.toJson()]) // Convert Order to JSON
    });
  }
   //get all orders for a table
   Stream<List<Order>> getOrdersForTable(String tableNumber) {
    return FirebaseFirestore.instance.collection('tables').doc(tableNumber).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        final List<dynamic> orderMaps = doc.data()!['orders'] ?? [];
        return orderMaps.map((map) => Order.fromJson(map as Map<String, dynamic>)).toList();
      }
      return []; // Return an empty list if document doesn't exist or no orders
    });
  }
}
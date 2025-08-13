import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:hotelmanagement/core/models/table.dart';
import 'package:hotelmanagement/core/models/order.dart';

class TableRepository {
  // Add table
  Future addTable(Table table) async {
    await FirebaseFirestore.instance
        .collection('tables')
        .doc(table.tableNumber)
        .set(table.toJson());
  }

  // Delete table
  Future deleteTable(String tableNumber) async {
    await FirebaseFirestore.instance
        .collection('tables')
        .doc(tableNumber)
        .delete();
  }

  // Get all tables
  Stream<List<Table>> getAllTables() {
    return FirebaseFirestore.instance
        .collection('tables')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Table.fromJson(doc.data())).toList();
    });
  }

  // Get table by number
  Future<Table?> getTableByNumber(String tableNumber) async {
    final doc = await FirebaseFirestore.instance
        .collection('tables')
        .doc(tableNumber)
        .get();
    if (doc.exists) {
      return Table.fromJson(doc.data()!);
    }
    return null;
  }

  //get table by id
  Future<Table?> getTableById(String tableId) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('tables')
        .where('tableId', isEqualTo: tableId)
        .limit(1) 
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return Table.fromJson(doc.data());
    }
    return null;
  } catch (e) {
    return null; 
  }
}


  // Add a order to a table
  Future addOrderToTable(String tableNumber, Order order) async {
    // Serialize dishes before saving
    final serializedOrder = order.toJson();
    serializedOrder['dishes'] = order.dishes.map((d) => d.toJson()).toList();

    await FirebaseFirestore.instance
        .collection('tables')
        .doc(tableNumber)
        .update({
      'orders': FieldValue.arrayUnion([serializedOrder])
    });
  }

  // Get all orders for a table
  Stream<List<Order>> getOrdersForTable(String tableNumber) {
    return FirebaseFirestore.instance
        .collection('tables')
        .doc(tableNumber)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        final List<dynamic> orderMaps = doc.data()!['orders'] ?? [];
        return orderMaps
            .map((map) => Order.fromJson(map as Map<String, dynamic>))
            .toList();
      }
      return [];
    });
  }

  //check if table exists
  Future<bool> checkTableExists(String tableNumber) async {
    return FirebaseFirestore.instance
        .collection('tables')
        .doc(tableNumber)
        .get().then((doc) => doc.exists);
  }

  Future updateOrderInTable(String tableNumber, Order updatedOrder) async {
    final tableRef =
        FirebaseFirestore.instance.collection('tables').doc(tableNumber);
    try {
      // Use a transaction to safely read and write
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(tableRef);
        if (!snapshot.exists) {
          throw Exception("Table does not exist!");
        }

        // Get the current list of orders
        final List<dynamic> ordersList = snapshot.data()?['orders'] ?? [];

        // Find the index of the order we need to update
        final orderIndex = ordersList
            .indexWhere((o) => o['orderId'] == updatedOrder.orderId);

        // If the order is found, replace it with the updated version
        if (orderIndex != -1) {
          final mutableOrders = List.from(ordersList);

          // Serialize dishes before updating
          final serializedUpdatedOrder = updatedOrder.toJson();
          serializedUpdatedOrder['dishes'] = updatedOrder.dishes.map((d) => d.toJson()).toList();

          mutableOrders[orderIndex] = serializedUpdatedOrder; // Replace the old order

          // Update the document with the new list
          transaction.update(tableRef, {'orders': mutableOrders});
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  // Add tip to table
  Future<void> addTipToTable(String tableNumber, double tipAmount) async {
    await FirebaseFirestore.instance
        .collection('tables')
        .doc(tableNumber)
        .update({
      'tips': FieldValue.arrayUnion([{
        'amount': tipAmount,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }]),
      'totalTips': FieldValue.increment(tipAmount)
    });
  }

  // Get total tips stream for all tables
  Stream<double> getTotalTipsStream() {
    return FirebaseFirestore.instance
        .collection('tables')
        .snapshots()
        .map((snapshot) {
      double totalTips = 0.0;
      for (var doc in snapshot.docs) {
        if (doc.exists && doc.data().containsKey('totalTips')) {
          totalTips += (doc.data()['totalTips'] as num?)?.toDouble() ?? 0.0;
        }
      }
      return totalTips;
    });
  }

  Future<void>updateTableStatusProvider(String tableNumber, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('tables')
        .doc(tableNumber)
        .update({'status': newStatus});
  } 
}

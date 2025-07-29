import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:hotelmanagement/core/models/dish.dart';
import 'package:hotelmanagement/core/models/order.dart';

class OrderRepository {
  //add a order for a table
  Future<void> addOrder(Order order) async {
    try {
      // First, let's debug what we're working with
      print('Adding order with ${order.dishes.length} dishes');
      
      // Verify that each dish can be serialized
      final serializedDishes = <Map<String, dynamic>>[];
      for (int i = 0; i < order.dishes.length; i++) {
        final dish = order.dishes[i];
        print('Serializing dish $i: ${dish.name} (type: ${dish.runtimeType})');
        
        try {
          final dishJson = dish.toJson();
          print('Dish $i serialized successfully: ${dishJson.keys}');
          serializedDishes.add(dishJson);
        } catch (e) {
          print('Error serializing dish $i: $e');
          rethrow;
        }
      }
      
      // Manually create the map to ensure correct serialization
      final orderData = <String, dynamic>{
        'id': order.orderId,
        'dishes': serializedDishes, // Use the pre-serialized dishes
        'tableId': order.tableId,
        'timestamp': order.timeStamp,
        'status': order.status,
        'specialInstructions': order.specialInstructions,
      };
      
      print('Order data created successfully with ${orderData['dishes'].length} dishes');
      
      // Use the order's ID as the document ID for consistency
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.orderId)
          .set(orderData);
          
      print('Order saved to Firestore successfully');
      
    } catch (e, stackTrace) {
      print('Error in addOrder: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  //get all order
  Stream<List<Order>> getAllOrders() {
    return FirebaseFirestore.instance
        .collection('orders')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Order.fromJson(doc.data())).toList();
    });
  }

  //get total price of a order
  Future<double> getTotalPrice(String orderId) async {
    final doc =
        await FirebaseFirestore.instance.collection('orders').doc(orderId).get();
    if (doc.exists) {
      final order = Order.fromJson(doc.data()!);
      return order.dishes
          .fold<double>(0.0, (total, dish) => total + dish.price);
    }
    return 0.0;
  }

  //add dish to order
  Future<void> addDishToOrder(String orderId, Dish dish) async {
    try {
      // Serialize the dish before adding to Firestore
      final dishJson = dish.toJson();
      
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'dishes': FieldValue.arrayUnion([dishJson]) // Use serialized dish
      });
    } catch (e) {
      print('Error adding dish to order: $e');
      rethrow;
    }
  }

  //write special instruction
  Future<void> writeSpecialInstruction(
      String orderId, String instruction) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({
      'specialInstructions': instruction,
    });
  }

  //cancel order
  Future<void> cancelOrder(String orderId) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({
      'status': 'cancelled',
    });
  }

  //update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({
      'status': status,
    });
  }
}
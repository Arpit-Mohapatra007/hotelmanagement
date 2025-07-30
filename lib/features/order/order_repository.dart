import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import 'package:hotelmanagement/core/models/dish.dart';

import 'package:hotelmanagement/core/models/order.dart';

class OrderRepository {
  // Add a order for a table
  Future addOrder(Order order) async {
    // Serialize dishes before saving
    final serializedOrder = order.toJson();
    serializedOrder['dishes'] = order.dishes.map((d) => d.toJson()).toList();

    // Use the order's ID as the document ID for consistency
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(order.orderId)
        .set(serializedOrder);
  }

  // Get all orders
  Stream<List<Order>> getAllOrders() {
    return FirebaseFirestore.instance
        .collection('orders')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Order.fromJson(doc.data())).toList();
    });
  }

  // Get total price of a order
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

  // Add dish to order
  Future addDishToOrder(String orderId, Dish dish) async {
    try {
      // Serialize the dish before adding to Firestore
      final dishJson = dish.toJson();
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'dishes': FieldValue.arrayUnion([dishJson]) // Use serialized dish
      });
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing order
  Future updateOrder(Order order) async {
    // Serialize dishes before updating
    final serializedOrder = order.toJson();
    serializedOrder['dishes'] = order.dishes.map((d) => d.toJson()).toList();

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(order.orderId)
        .update(serializedOrder);
  }

  // Write special instruction
  Future writeSpecialInstruction(
      String orderId, String instruction) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({
      'specialInstructions': instruction,
    });
  }

  // Cancel order
  Future cancelOrder(String orderId) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({
      'status': 'cancelled',
    });
  }

  // Update order status
  Future updateOrderStatus(String orderId, String status) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({
      'status': status,
    });
  }
}

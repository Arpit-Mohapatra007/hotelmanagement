import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart'hide Order;
import 'package:hotelmanagement/core/models/dish.dart';
import 'package:hotelmanagement/core/models/order.dart' ;

class OrderRepository {
  //add a order for a table
  Future<void> addOrder(Order order) async {
    await FirebaseFirestore.instance.collection('orders').add(order.toJson());
  }
  //get all order
  Stream<List<Order>> getAllOrders() {
    return FirebaseFirestore.instance.collection('orders').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Order.fromJson(doc.data())).toList();
    });
  }
  //get total price of a order
  Future<double> getTotalPrice(String orderId) async {
    final doc = await FirebaseFirestore.instance.collection('orders').doc(orderId).get();
    if (doc.exists) {
      final order = Order.fromJson(doc.data()!);
      return order.dishes.fold<double>(0.0, (total, dish) => total + dish.price);
    } 
    return 0.0;
  }
  //add dish to order
  Future<void> addDishToOrder(String orderId, Dish dish) async {
    final doc = await FirebaseFirestore.instance.collection('orders').doc(orderId).get();
    if (doc.exists) {
      final order = Order.fromJson(doc.data()!);
      final updatedDishes = List<Dish>.from(order.dishes)..add(dish);
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'dishes': updatedDishes.map((d) => d.toJson()).toList(),
      });
    }
  }
  //write special instruction
  Future<void> writeSpecialInstruction(String orderId, String instruction) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'specialInstructions': instruction,
    });
  }
  //cancel order
  Future<void> cancelOrder(String orderId) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': 'cancelled',
    });
  }
  //update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': status,
    });
  }
}



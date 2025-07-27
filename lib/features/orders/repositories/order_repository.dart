import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:hotelmanagement/core/models/order.dart';

class OrderRepository {
  final FirebaseFirestore firestore;

  OrderRepository(this.firestore);

  Stream<List<Order>> getOrders() {
    return firestore
        .collection('orders')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromJson(doc.data()..['id'] = doc.id))
            .toList());
  }
  
  Stream<List<Order>> getOrdersByTableId(String tableId) {
    return firestore
        .collection('orders')
        .where('tableId', isEqualTo: tableId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromJson(doc.data()..['id'] = doc.id))
            .toList());
  }

  Future<void> addOrder(Order order) async {
    await firestore.collection('orders').add(order.toJson());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await firestore.collection('orders').doc(orderId).update({'status': status});
  }

  Future<void> deleteOrder(String orderId) async {
    await firestore.collection('orders').doc(orderId).delete();
  }

  Future<void> addDishToOrder(String orderId, String dishId, String dishName, int quantity) async {
    await firestore.collection('orders').doc(orderId).update({
      'dishIds': FieldValue.arrayUnion([dishId]),
      'dishNames': FieldValue.arrayUnion([dishName]),
      'quantity': FieldValue.increment(quantity),
    });
  }

  Future<void> removeDishFromOrder(String orderId, String dishId, int quantity) async {
    await firestore.collection('orders').doc(orderId).update({
      'dishIds': FieldValue.arrayRemove([dishId]),
      'quantity': FieldValue.increment(-quantity),
    });
  }

  Future<void> updateOrderPrice(String orderId, double price) async {
    await firestore.collection('orders').doc(orderId).update({'price': price});
  }
}
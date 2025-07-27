import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmanagement/core/models/order.dart';
import 'package:hotelmanagement/core/providers/firebase_providers.dart';
import 'package:hotelmanagement/features/orders/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(ref.watch(firestoreProvider)),
);

final allOrdersProvider = StreamProvider<List<Order>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrders();
});

final ordersProvider = StreamProvider.family<List<Order>, String>((ref, tableId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrdersByTableId(tableId);
});

final addOrderProvider = FutureProvider.family<void, Order>((ref, order) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.addOrder(order);
});

final updateOrderStatusProvider = FutureProvider.family<void, ({String orderId, String status})>((ref, args) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.updateOrderStatus(args.orderId, args.status);
});

final deleteOrderProvider = FutureProvider.family<void, String>((ref, orderId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.deleteOrder(orderId);
});

final addDishToOrderProvider = FutureProvider.family<void, ({String orderId, String dishId, String dishName, int quantity})>((ref, args) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.addDishToOrder(args.orderId, args.dishId, args.dishName, args.quantity);
});

final removeDishFromOrderProvider = FutureProvider.family<void, ({String orderId, String dishId, int quantity})>((ref, args) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.removeDishFromOrder(args.orderId, args.dishId, args.quantity);
});

final updateOrderPriceProvider = FutureProvider.family<void, ({String orderId, double price})>((ref, args) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.updateOrderPrice(args.orderId, args.price);
});
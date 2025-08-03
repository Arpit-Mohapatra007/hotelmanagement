import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/models/dish.dart';
import 'package:hotelmanagement/core/models/order.dart';
import 'package:hotelmanagement/features/order/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) => OrderRepository());

final ordersProvider = StreamProvider.autoDispose((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getAllOrders();
});

final totalOrderPriceProvider = FutureProvider.autoDispose.family<double, String>((ref, orderId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getTotalPrice(orderId);
});



final addOrderProvider = FutureProvider.autoDispose.family<void, Order>((ref, order) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.addOrder(order);
});

final updateOrderProvider =
    FutureProvider.autoDispose.family<void, Order>((ref, order) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.updateOrder(order);
});

final addDishToOrderProvider = FutureProvider.autoDispose.family<void, Map<String, dynamic>>((ref, args) {
  final repository = ref.watch(orderRepositoryProvider);
  final orderId = args['orderId'] as String;
  final dish = args['dish'] as Dish;
  return repository.addDishToOrder(orderId, dish);
});

final writeSpecialInstructionProvider = FutureProvider.autoDispose.family<void, Map<String, String>>((ref, args) {
  final repository = ref.watch(orderRepositoryProvider);
  final orderId = args['orderId']!;
  final instruction = args['instruction']!;
  return repository.writeSpecialInstruction(orderId, instruction);
});

final cancelOrderProvider = FutureProvider.family<void, String>((ref, orderId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.cancelOrder(orderId);
});

final orderStatusProvider = StreamProvider.family<String, String>((ref, orderId){
  final repository = ref.watch(orderRepositoryProvider);
  return repository.orderStatus(orderId);
});

final getOrderByIdProvider = FutureProvider.family<Order?, String>((ref, orderId) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrderById(orderId);
});

final updateOrderStatusProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, args) {
  final repository = ref.watch(orderRepositoryProvider);
  final orderId = args['orderId'] as String;
  final status = args['status'] as String;
  return repository.updateOrderStatus(orderId, status);
});

final deleteOrderProvider = FutureProvider.family<void, String>((ref, orderId){
  final repository = ref.watch(orderRepositoryProvider);
  return repository.deleteOrder(orderId);
});
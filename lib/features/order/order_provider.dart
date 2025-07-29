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

final orderStatusProvider = FutureProvider.autoDispose.family<void, Map<String, String>>((ref, args) {
  final repository = ref.watch(orderRepositoryProvider);
  final orderId = args['orderId']!;
  final status = args['status']!;
  return repository.updateOrderStatus(orderId, status);
});

final addOrderProvider = FutureProvider.autoDispose.family<void, Order>((ref, order) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.addOrder(order);
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

final cancelOrderProvider = FutureProvider.autoDispose.family<void, String>((ref, orderId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.cancelOrder(orderId);
});

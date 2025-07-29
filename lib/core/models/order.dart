import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hotelmanagement/core/models/dish.dart';
part 'order.freezed.dart';
part 'order.g.dart';
@freezed
abstract class Order with _$Order {
  const factory Order({
    required String tableId,
    required String orderId,
    required List<Dish> dishes,
    required double price,
    required String timeStamp,
    required String status,
    String? specialInstructions,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
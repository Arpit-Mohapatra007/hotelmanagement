import 'package:freezed_annotation/freezed_annotation.dart';
part 'order.freezed.dart';
part 'order.g.dart';
@freezed
abstract class Order with _$Order {
  const factory Order({
    required String orderId,
    required List<String> dishIds,
    required List<String> dishNames,
    required int quantity,
    required double price,
    required String timeStamp,
    required String status,
    required String specialInstructions,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
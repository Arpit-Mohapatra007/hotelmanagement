import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hotelmanagement/core/models/order.dart';
part 'table.freezed.dart';
part 'table.g.dart';

@freezed
abstract class Table with _$Table {
  const factory Table({
    required String tableId,
    required String tableNumber,
    required String status,
    required List<Order> orders,
    required double currentBill,
    required int capacity,
    required String sessionInfo,
  }) = _Table;

  factory Table.fromJson(Map<String, dynamic> json) => _$TableFromJson(json);
}
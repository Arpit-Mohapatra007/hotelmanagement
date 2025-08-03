import 'package:freezed_annotation/freezed_annotation.dart';
part 'inventory.freezed.dart';
part 'inventory.g.dart';
@freezed
abstract class Inventory with _$Inventory {
  const factory Inventory({
    required String id,
    required String name,
    required int quantity,
    required double price,
  }) = _Inventory; 
  factory Inventory.fromJson(Map<String, dynamic> json) => _$InventoryFromJson(json);
}
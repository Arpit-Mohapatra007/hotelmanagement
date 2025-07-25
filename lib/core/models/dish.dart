import 'package:freezed_annotation/freezed_annotation.dart';

part 'dish.freezed.dart';
part 'dish.g.dart';

@freezed
abstract class Dish with _$Dish {
  const factory Dish({
    required String id,
    required String name,
    required String description,
    required String category,
    String? review,
    required String ingredients,
    required bool isAvailable,
    required double price,
    String? imageUrl,
  }) = _Dish;

  factory Dish.fromJson(Map<String, dynamic> json) => _$DishFromJson(json);
}


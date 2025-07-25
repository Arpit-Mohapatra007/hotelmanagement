// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dish.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Dish _$DishFromJson(Map<String, dynamic> json) => _Dish(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  review: json['review'] as String?,
  ingredients: json['ingredients'] as String,
  isAvailable: json['isAvailable'] as bool,
  price: (json['price'] as num).toDouble(),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$DishToJson(_Dish instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'category': instance.category,
  'review': instance.review,
  'ingredients': instance.ingredients,
  'isAvailable': instance.isAvailable,
  'price': instance.price,
  'imageUrl': instance.imageUrl,
};

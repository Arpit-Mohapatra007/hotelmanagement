// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  tableId: json['tableId'] as String,
  orderId: json['orderId'] as String,
  dishes: (json['dishes'] as List<dynamic>)
      .map((e) => Dish.fromJson(e as Map<String, dynamic>))
      .toList(),
  price: (json['price'] as num).toDouble(),
  timeStamp: json['timeStamp'] as String,
  status: json['status'] as String,
  specialInstructions: json['specialInstructions'] as String?,
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'tableId': instance.tableId,
  'orderId': instance.orderId,
  'dishes': instance.dishes,
  'price': instance.price,
  'timeStamp': instance.timeStamp,
  'status': instance.status,
  'specialInstructions': instance.specialInstructions,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  tableId: json['tableId'] as String,
  orderId: json['orderId'] as String,
  dishIds: (json['dishIds'] as List<dynamic>).map((e) => e as String).toList(),
  dishNames: (json['dishNames'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  quantity: (json['quantity'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  timeStamp: json['timeStamp'] as String,
  status: json['status'] as String,
  specialInstructions: json['specialInstructions'] as String?,
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'tableId': instance.tableId,
  'orderId': instance.orderId,
  'dishIds': instance.dishIds,
  'dishNames': instance.dishNames,
  'quantity': instance.quantity,
  'price': instance.price,
  'timeStamp': instance.timeStamp,
  'status': instance.status,
  'specialInstructions': instance.specialInstructions,
};

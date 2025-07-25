// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Table _$TableFromJson(Map<String, dynamic> json) => _Table(
  tableId: json['tableId'] as String,
  tableNumber: json['tableNumber'] as String,
  status: json['status'] as String,
  orders: (json['orders'] as List<dynamic>).map((e) => e as String).toList(),
  currentBill: (json['currentBill'] as num).toDouble(),
  capacity: (json['capacity'] as num).toInt(),
  sessionInfo: json['sessionInfo'] as String,
);

Map<String, dynamic> _$TableToJson(_Table instance) => <String, dynamic>{
  'tableId': instance.tableId,
  'tableNumber': instance.tableNumber,
  'status': instance.status,
  'orders': instance.orders,
  'currentBill': instance.currentBill,
  'capacity': instance.capacity,
  'sessionInfo': instance.sessionInfo,
};

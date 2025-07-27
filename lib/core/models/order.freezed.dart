// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Order {

 String get tableId; String get orderId; List<String> get dishIds; List<String> get dishNames; int get quantity; double get price; String get timeStamp; String get status; String? get specialInstructions;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.tableId, tableId) || other.tableId == tableId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&const DeepCollectionEquality().equals(other.dishIds, dishIds)&&const DeepCollectionEquality().equals(other.dishNames, dishNames)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.timeStamp, timeStamp) || other.timeStamp == timeStamp)&&(identical(other.status, status) || other.status == status)&&(identical(other.specialInstructions, specialInstructions) || other.specialInstructions == specialInstructions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tableId,orderId,const DeepCollectionEquality().hash(dishIds),const DeepCollectionEquality().hash(dishNames),quantity,price,timeStamp,status,specialInstructions);

@override
String toString() {
  return 'Order(tableId: $tableId, orderId: $orderId, dishIds: $dishIds, dishNames: $dishNames, quantity: $quantity, price: $price, timeStamp: $timeStamp, status: $status, specialInstructions: $specialInstructions)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String tableId, String orderId, List<String> dishIds, List<String> dishNames, int quantity, double price, String timeStamp, String status, String? specialInstructions
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tableId = null,Object? orderId = null,Object? dishIds = null,Object? dishNames = null,Object? quantity = null,Object? price = null,Object? timeStamp = null,Object? status = null,Object? specialInstructions = freezed,}) {
  return _then(_self.copyWith(
tableId: null == tableId ? _self.tableId : tableId // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,dishIds: null == dishIds ? _self.dishIds : dishIds // ignore: cast_nullable_to_non_nullable
as List<String>,dishNames: null == dishNames ? _self.dishNames : dishNames // ignore: cast_nullable_to_non_nullable
as List<String>,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,timeStamp: null == timeStamp ? _self.timeStamp : timeStamp // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,specialInstructions: freezed == specialInstructions ? _self.specialInstructions : specialInstructions // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tableId,  String orderId,  List<String> dishIds,  List<String> dishNames,  int quantity,  double price,  String timeStamp,  String status,  String? specialInstructions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.tableId,_that.orderId,_that.dishIds,_that.dishNames,_that.quantity,_that.price,_that.timeStamp,_that.status,_that.specialInstructions);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tableId,  String orderId,  List<String> dishIds,  List<String> dishNames,  int quantity,  double price,  String timeStamp,  String status,  String? specialInstructions)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.tableId,_that.orderId,_that.dishIds,_that.dishNames,_that.quantity,_that.price,_that.timeStamp,_that.status,_that.specialInstructions);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tableId,  String orderId,  List<String> dishIds,  List<String> dishNames,  int quantity,  double price,  String timeStamp,  String status,  String? specialInstructions)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.tableId,_that.orderId,_that.dishIds,_that.dishNames,_that.quantity,_that.price,_that.timeStamp,_that.status,_that.specialInstructions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
  const _Order({required this.tableId, required this.orderId, required final  List<String> dishIds, required final  List<String> dishNames, required this.quantity, required this.price, required this.timeStamp, required this.status, required this.specialInstructions}): _dishIds = dishIds,_dishNames = dishNames;
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  String tableId;
@override final  String orderId;
 final  List<String> _dishIds;
@override List<String> get dishIds {
  if (_dishIds is EqualUnmodifiableListView) return _dishIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dishIds);
}

 final  List<String> _dishNames;
@override List<String> get dishNames {
  if (_dishNames is EqualUnmodifiableListView) return _dishNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dishNames);
}

@override final  int quantity;
@override final  double price;
@override final  String timeStamp;
@override final  String status;
@override final  String? specialInstructions;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.tableId, tableId) || other.tableId == tableId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&const DeepCollectionEquality().equals(other._dishIds, _dishIds)&&const DeepCollectionEquality().equals(other._dishNames, _dishNames)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.timeStamp, timeStamp) || other.timeStamp == timeStamp)&&(identical(other.status, status) || other.status == status)&&(identical(other.specialInstructions, specialInstructions) || other.specialInstructions == specialInstructions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tableId,orderId,const DeepCollectionEquality().hash(_dishIds),const DeepCollectionEquality().hash(_dishNames),quantity,price,timeStamp,status,specialInstructions);

@override
String toString() {
  return 'Order(tableId: $tableId, orderId: $orderId, dishIds: $dishIds, dishNames: $dishNames, quantity: $quantity, price: $price, timeStamp: $timeStamp, status: $status, specialInstructions: $specialInstructions)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String tableId, String orderId, List<String> dishIds, List<String> dishNames, int quantity, double price, String timeStamp, String status, String? specialInstructions
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tableId = null,Object? orderId = null,Object? dishIds = null,Object? dishNames = null,Object? quantity = null,Object? price = null,Object? timeStamp = null,Object? status = null,Object? specialInstructions = freezed,}) {
  return _then(_Order(
tableId: null == tableId ? _self.tableId : tableId // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,dishIds: null == dishIds ? _self._dishIds : dishIds // ignore: cast_nullable_to_non_nullable
as List<String>,dishNames: null == dishNames ? _self._dishNames : dishNames // ignore: cast_nullable_to_non_nullable
as List<String>,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,timeStamp: null == timeStamp ? _self.timeStamp : timeStamp // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,specialInstructions: freezed == specialInstructions ? _self.specialInstructions : specialInstructions // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

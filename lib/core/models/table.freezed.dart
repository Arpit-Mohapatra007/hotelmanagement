// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'table.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Table {

 String get tableId; String get tableNumber; String get status; List<String> get orders; double get currentBill; int get capacity; String get sessionInfo;
/// Create a copy of Table
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TableCopyWith<Table> get copyWith => _$TableCopyWithImpl<Table>(this as Table, _$identity);

  /// Serializes this Table to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Table&&(identical(other.tableId, tableId) || other.tableId == tableId)&&(identical(other.tableNumber, tableNumber) || other.tableNumber == tableNumber)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.orders, orders)&&(identical(other.currentBill, currentBill) || other.currentBill == currentBill)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.sessionInfo, sessionInfo) || other.sessionInfo == sessionInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tableId,tableNumber,status,const DeepCollectionEquality().hash(orders),currentBill,capacity,sessionInfo);

@override
String toString() {
  return 'Table(tableId: $tableId, tableNumber: $tableNumber, status: $status, orders: $orders, currentBill: $currentBill, capacity: $capacity, sessionInfo: $sessionInfo)';
}


}

/// @nodoc
abstract mixin class $TableCopyWith<$Res>  {
  factory $TableCopyWith(Table value, $Res Function(Table) _then) = _$TableCopyWithImpl;
@useResult
$Res call({
 String tableId, String tableNumber, String status, List<String> orders, double currentBill, int capacity, String sessionInfo
});




}
/// @nodoc
class _$TableCopyWithImpl<$Res>
    implements $TableCopyWith<$Res> {
  _$TableCopyWithImpl(this._self, this._then);

  final Table _self;
  final $Res Function(Table) _then;

/// Create a copy of Table
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tableId = null,Object? tableNumber = null,Object? status = null,Object? orders = null,Object? currentBill = null,Object? capacity = null,Object? sessionInfo = null,}) {
  return _then(_self.copyWith(
tableId: null == tableId ? _self.tableId : tableId // ignore: cast_nullable_to_non_nullable
as String,tableNumber: null == tableNumber ? _self.tableNumber : tableNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,orders: null == orders ? _self.orders : orders // ignore: cast_nullable_to_non_nullable
as List<String>,currentBill: null == currentBill ? _self.currentBill : currentBill // ignore: cast_nullable_to_non_nullable
as double,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,sessionInfo: null == sessionInfo ? _self.sessionInfo : sessionInfo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Table].
extension TablePatterns on Table {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Table value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Table() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Table value)  $default,){
final _that = this;
switch (_that) {
case _Table():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Table value)?  $default,){
final _that = this;
switch (_that) {
case _Table() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tableId,  String tableNumber,  String status,  List<String> orders,  double currentBill,  int capacity,  String sessionInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Table() when $default != null:
return $default(_that.tableId,_that.tableNumber,_that.status,_that.orders,_that.currentBill,_that.capacity,_that.sessionInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tableId,  String tableNumber,  String status,  List<String> orders,  double currentBill,  int capacity,  String sessionInfo)  $default,) {final _that = this;
switch (_that) {
case _Table():
return $default(_that.tableId,_that.tableNumber,_that.status,_that.orders,_that.currentBill,_that.capacity,_that.sessionInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tableId,  String tableNumber,  String status,  List<String> orders,  double currentBill,  int capacity,  String sessionInfo)?  $default,) {final _that = this;
switch (_that) {
case _Table() when $default != null:
return $default(_that.tableId,_that.tableNumber,_that.status,_that.orders,_that.currentBill,_that.capacity,_that.sessionInfo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Table implements Table {
  const _Table({required this.tableId, required this.tableNumber, required this.status, required final  List<String> orders, required this.currentBill, required this.capacity, required this.sessionInfo}): _orders = orders;
  factory _Table.fromJson(Map<String, dynamic> json) => _$TableFromJson(json);

@override final  String tableId;
@override final  String tableNumber;
@override final  String status;
 final  List<String> _orders;
@override List<String> get orders {
  if (_orders is EqualUnmodifiableListView) return _orders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_orders);
}

@override final  double currentBill;
@override final  int capacity;
@override final  String sessionInfo;

/// Create a copy of Table
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TableCopyWith<_Table> get copyWith => __$TableCopyWithImpl<_Table>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TableToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Table&&(identical(other.tableId, tableId) || other.tableId == tableId)&&(identical(other.tableNumber, tableNumber) || other.tableNumber == tableNumber)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._orders, _orders)&&(identical(other.currentBill, currentBill) || other.currentBill == currentBill)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.sessionInfo, sessionInfo) || other.sessionInfo == sessionInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tableId,tableNumber,status,const DeepCollectionEquality().hash(_orders),currentBill,capacity,sessionInfo);

@override
String toString() {
  return 'Table(tableId: $tableId, tableNumber: $tableNumber, status: $status, orders: $orders, currentBill: $currentBill, capacity: $capacity, sessionInfo: $sessionInfo)';
}


}

/// @nodoc
abstract mixin class _$TableCopyWith<$Res> implements $TableCopyWith<$Res> {
  factory _$TableCopyWith(_Table value, $Res Function(_Table) _then) = __$TableCopyWithImpl;
@override @useResult
$Res call({
 String tableId, String tableNumber, String status, List<String> orders, double currentBill, int capacity, String sessionInfo
});




}
/// @nodoc
class __$TableCopyWithImpl<$Res>
    implements _$TableCopyWith<$Res> {
  __$TableCopyWithImpl(this._self, this._then);

  final _Table _self;
  final $Res Function(_Table) _then;

/// Create a copy of Table
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tableId = null,Object? tableNumber = null,Object? status = null,Object? orders = null,Object? currentBill = null,Object? capacity = null,Object? sessionInfo = null,}) {
  return _then(_Table(
tableId: null == tableId ? _self.tableId : tableId // ignore: cast_nullable_to_non_nullable
as String,tableNumber: null == tableNumber ? _self.tableNumber : tableNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,orders: null == orders ? _self._orders : orders // ignore: cast_nullable_to_non_nullable
as List<String>,currentBill: null == currentBill ? _self.currentBill : currentBill // ignore: cast_nullable_to_non_nullable
as double,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,sessionInfo: null == sessionInfo ? _self.sessionInfo : sessionInfo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

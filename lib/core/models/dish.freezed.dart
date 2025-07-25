// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dish.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Dish {

 String get id; String get name; String get description; String get category; String? get review; String get ingredients; bool get isAvailable; double get price; String? get imageUrl;
/// Create a copy of Dish
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DishCopyWith<Dish> get copyWith => _$DishCopyWithImpl<Dish>(this as Dish, _$identity);

  /// Serializes this Dish to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Dish&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.review, review) || other.review == review)&&(identical(other.ingredients, ingredients) || other.ingredients == ingredients)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,category,review,ingredients,isAvailable,price,imageUrl);

@override
String toString() {
  return 'Dish(id: $id, name: $name, description: $description, category: $category, review: $review, ingredients: $ingredients, isAvailable: $isAvailable, price: $price, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $DishCopyWith<$Res>  {
  factory $DishCopyWith(Dish value, $Res Function(Dish) _then) = _$DishCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String category, String? review, String ingredients, bool isAvailable, double price, String? imageUrl
});




}
/// @nodoc
class _$DishCopyWithImpl<$Res>
    implements $DishCopyWith<$Res> {
  _$DishCopyWithImpl(this._self, this._then);

  final Dish _self;
  final $Res Function(Dish) _then;

/// Create a copy of Dish
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? category = null,Object? review = freezed,Object? ingredients = null,Object? isAvailable = null,Object? price = null,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as String?,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as String,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Dish].
extension DishPatterns on Dish {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Dish value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Dish() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Dish value)  $default,){
final _that = this;
switch (_that) {
case _Dish():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Dish value)?  $default,){
final _that = this;
switch (_that) {
case _Dish() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String category,  String? review,  String ingredients,  bool isAvailable,  double price,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Dish() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.category,_that.review,_that.ingredients,_that.isAvailable,_that.price,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String category,  String? review,  String ingredients,  bool isAvailable,  double price,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _Dish():
return $default(_that.id,_that.name,_that.description,_that.category,_that.review,_that.ingredients,_that.isAvailable,_that.price,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String category,  String? review,  String ingredients,  bool isAvailable,  double price,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _Dish() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.category,_that.review,_that.ingredients,_that.isAvailable,_that.price,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Dish implements Dish {
  const _Dish({required this.id, required this.name, required this.description, required this.category, this.review, required this.ingredients, required this.isAvailable, required this.price, this.imageUrl});
  factory _Dish.fromJson(Map<String, dynamic> json) => _$DishFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String category;
@override final  String? review;
@override final  String ingredients;
@override final  bool isAvailable;
@override final  double price;
@override final  String? imageUrl;

/// Create a copy of Dish
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DishCopyWith<_Dish> get copyWith => __$DishCopyWithImpl<_Dish>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DishToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Dish&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.review, review) || other.review == review)&&(identical(other.ingredients, ingredients) || other.ingredients == ingredients)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,category,review,ingredients,isAvailable,price,imageUrl);

@override
String toString() {
  return 'Dish(id: $id, name: $name, description: $description, category: $category, review: $review, ingredients: $ingredients, isAvailable: $isAvailable, price: $price, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$DishCopyWith<$Res> implements $DishCopyWith<$Res> {
  factory _$DishCopyWith(_Dish value, $Res Function(_Dish) _then) = __$DishCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String category, String? review, String ingredients, bool isAvailable, double price, String? imageUrl
});




}
/// @nodoc
class __$DishCopyWithImpl<$Res>
    implements _$DishCopyWith<$Res> {
  __$DishCopyWithImpl(this._self, this._then);

  final _Dish _self;
  final $Res Function(_Dish) _then;

/// Create a copy of Dish
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? category = null,Object? review = freezed,Object? ingredients = null,Object? isAvailable = null,Object? price = null,Object? imageUrl = freezed,}) {
  return _then(_Dish(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as String?,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as String,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

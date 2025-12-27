// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BaseDTO<T> {

@JsonKey(name: 'code') int get code;@JsonKey(name: 'message') String get message;@JsonKey(name: 'data') T? get data;
/// Create a copy of BaseDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BaseDTOCopyWith<T, BaseDTO<T>> get copyWith => _$BaseDTOCopyWithImpl<T, BaseDTO<T>>(this as BaseDTO<T>, _$identity);

  /// Serializes this BaseDTO to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BaseDTO<T>&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,message,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'BaseDTO<$T>(code: $code, message: $message, data: $data)';
}


}

/// @nodoc
abstract mixin class $BaseDTOCopyWith<T,$Res>  {
  factory $BaseDTOCopyWith(BaseDTO<T> value, $Res Function(BaseDTO<T>) _then) = _$BaseDTOCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'code') int code,@JsonKey(name: 'message') String message,@JsonKey(name: 'data') T? data
});




}
/// @nodoc
class _$BaseDTOCopyWithImpl<T,$Res>
    implements $BaseDTOCopyWith<T, $Res> {
  _$BaseDTOCopyWithImpl(this._self, this._then);

  final BaseDTO<T> _self;
  final $Res Function(BaseDTO<T>) _then;

/// Create a copy of BaseDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? message = null,Object? data = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,
  ));
}

}


/// Adds pattern-matching-related methods to [BaseDTO].
extension BaseDTOPatterns<T> on BaseDTO<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BaseDTO<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BaseDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BaseDTO<T> value)  $default,){
final _that = this;
switch (_that) {
case _BaseDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BaseDTO<T> value)?  $default,){
final _that = this;
switch (_that) {
case _BaseDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int code, @JsonKey(name: 'message')  String message, @JsonKey(name: 'data')  T? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BaseDTO() when $default != null:
return $default(_that.code,_that.message,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'code')  int code, @JsonKey(name: 'message')  String message, @JsonKey(name: 'data')  T? data)  $default,) {final _that = this;
switch (_that) {
case _BaseDTO():
return $default(_that.code,_that.message,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'code')  int code, @JsonKey(name: 'message')  String message, @JsonKey(name: 'data')  T? data)?  $default,) {final _that = this;
switch (_that) {
case _BaseDTO() when $default != null:
return $default(_that.code,_that.message,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _BaseDTO<T> implements BaseDTO<T> {
   _BaseDTO({@JsonKey(name: 'code') required this.code, @JsonKey(name: 'message') required this.message, @JsonKey(name: 'data') this.data});
  factory _BaseDTO.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$BaseDTOFromJson(json,fromJsonT);

@override@JsonKey(name: 'code') final  int code;
@override@JsonKey(name: 'message') final  String message;
@override@JsonKey(name: 'data') final  T? data;

/// Create a copy of BaseDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BaseDTOCopyWith<T, _BaseDTO<T>> get copyWith => __$BaseDTOCopyWithImpl<T, _BaseDTO<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$BaseDTOToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BaseDTO<T>&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,message,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'BaseDTO<$T>(code: $code, message: $message, data: $data)';
}


}

/// @nodoc
abstract mixin class _$BaseDTOCopyWith<T,$Res> implements $BaseDTOCopyWith<T, $Res> {
  factory _$BaseDTOCopyWith(_BaseDTO<T> value, $Res Function(_BaseDTO<T>) _then) = __$BaseDTOCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'code') int code,@JsonKey(name: 'message') String message,@JsonKey(name: 'data') T? data
});




}
/// @nodoc
class __$BaseDTOCopyWithImpl<T,$Res>
    implements _$BaseDTOCopyWith<T, $Res> {
  __$BaseDTOCopyWithImpl(this._self, this._then);

  final _BaseDTO<T> _self;
  final $Res Function(_BaseDTO<T>) _then;

/// Create a copy of BaseDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,Object? data = freezed,}) {
  return _then(_BaseDTO<T>(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,
  ));
}


}

// dart format on

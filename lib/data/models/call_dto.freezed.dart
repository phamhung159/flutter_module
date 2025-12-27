// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CallDto {

 String get callId; String get callerId; String get callerName; String? get callerAvatar; CallType get callType; DateTime get timestamp;
/// Create a copy of CallDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallDtoCopyWith<CallDto> get copyWith => _$CallDtoCopyWithImpl<CallDto>(this as CallDto, _$identity);

  /// Serializes this CallDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallDto&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.callerId, callerId) || other.callerId == callerId)&&(identical(other.callerName, callerName) || other.callerName == callerName)&&(identical(other.callerAvatar, callerAvatar) || other.callerAvatar == callerAvatar)&&(identical(other.callType, callType) || other.callType == callType)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,callId,callerId,callerName,callerAvatar,callType,timestamp);

@override
String toString() {
  return 'CallDto(callId: $callId, callerId: $callerId, callerName: $callerName, callerAvatar: $callerAvatar, callType: $callType, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $CallDtoCopyWith<$Res>  {
  factory $CallDtoCopyWith(CallDto value, $Res Function(CallDto) _then) = _$CallDtoCopyWithImpl;
@useResult
$Res call({
 String callId, String callerId, String callerName, String? callerAvatar, CallType callType, DateTime timestamp
});




}
/// @nodoc
class _$CallDtoCopyWithImpl<$Res>
    implements $CallDtoCopyWith<$Res> {
  _$CallDtoCopyWithImpl(this._self, this._then);

  final CallDto _self;
  final $Res Function(CallDto) _then;

/// Create a copy of CallDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? callId = null,Object? callerId = null,Object? callerName = null,Object? callerAvatar = freezed,Object? callType = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,callerId: null == callerId ? _self.callerId : callerId // ignore: cast_nullable_to_non_nullable
as String,callerName: null == callerName ? _self.callerName : callerName // ignore: cast_nullable_to_non_nullable
as String,callerAvatar: freezed == callerAvatar ? _self.callerAvatar : callerAvatar // ignore: cast_nullable_to_non_nullable
as String?,callType: null == callType ? _self.callType : callType // ignore: cast_nullable_to_non_nullable
as CallType,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CallDto].
extension CallDtoPatterns on CallDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallDto value)  $default,){
final _that = this;
switch (_that) {
case _CallDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallDto value)?  $default,){
final _that = this;
switch (_that) {
case _CallDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String callId,  String callerId,  String callerName,  String? callerAvatar,  CallType callType,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallDto() when $default != null:
return $default(_that.callId,_that.callerId,_that.callerName,_that.callerAvatar,_that.callType,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String callId,  String callerId,  String callerName,  String? callerAvatar,  CallType callType,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _CallDto():
return $default(_that.callId,_that.callerId,_that.callerName,_that.callerAvatar,_that.callType,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String callId,  String callerId,  String callerName,  String? callerAvatar,  CallType callType,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _CallDto() when $default != null:
return $default(_that.callId,_that.callerId,_that.callerName,_that.callerAvatar,_that.callType,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CallDto implements CallDto {
  const _CallDto({required this.callId, required this.callerId, required this.callerName, this.callerAvatar, required this.callType, required this.timestamp});
  factory _CallDto.fromJson(Map<String, dynamic> json) => _$CallDtoFromJson(json);

@override final  String callId;
@override final  String callerId;
@override final  String callerName;
@override final  String? callerAvatar;
@override final  CallType callType;
@override final  DateTime timestamp;

/// Create a copy of CallDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallDtoCopyWith<_CallDto> get copyWith => __$CallDtoCopyWithImpl<_CallDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallDto&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.callerId, callerId) || other.callerId == callerId)&&(identical(other.callerName, callerName) || other.callerName == callerName)&&(identical(other.callerAvatar, callerAvatar) || other.callerAvatar == callerAvatar)&&(identical(other.callType, callType) || other.callType == callType)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,callId,callerId,callerName,callerAvatar,callType,timestamp);

@override
String toString() {
  return 'CallDto(callId: $callId, callerId: $callerId, callerName: $callerName, callerAvatar: $callerAvatar, callType: $callType, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$CallDtoCopyWith<$Res> implements $CallDtoCopyWith<$Res> {
  factory _$CallDtoCopyWith(_CallDto value, $Res Function(_CallDto) _then) = __$CallDtoCopyWithImpl;
@override @useResult
$Res call({
 String callId, String callerId, String callerName, String? callerAvatar, CallType callType, DateTime timestamp
});




}
/// @nodoc
class __$CallDtoCopyWithImpl<$Res>
    implements _$CallDtoCopyWith<$Res> {
  __$CallDtoCopyWithImpl(this._self, this._then);

  final _CallDto _self;
  final $Res Function(_CallDto) _then;

/// Create a copy of CallDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? callId = null,Object? callerId = null,Object? callerName = null,Object? callerAvatar = freezed,Object? callType = null,Object? timestamp = null,}) {
  return _then(_CallDto(
callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,callerId: null == callerId ? _self.callerId : callerId // ignore: cast_nullable_to_non_nullable
as String,callerName: null == callerName ? _self.callerName : callerName // ignore: cast_nullable_to_non_nullable
as String,callerAvatar: freezed == callerAvatar ? _self.callerAvatar : callerAvatar // ignore: cast_nullable_to_non_nullable
as String?,callType: null == callType ? _self.callType : callType // ignore: cast_nullable_to_non_nullable
as CallType,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

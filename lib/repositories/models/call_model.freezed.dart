// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CallModel {

 String get callId; String get callerId; String get callerName; String? get callerAvatar; CallType get callType; CallStatus get status; DateTime get timestamp; int? get duration;
/// Create a copy of CallModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallModelCopyWith<CallModel> get copyWith => _$CallModelCopyWithImpl<CallModel>(this as CallModel, _$identity);

  /// Serializes this CallModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallModel&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.callerId, callerId) || other.callerId == callerId)&&(identical(other.callerName, callerName) || other.callerName == callerName)&&(identical(other.callerAvatar, callerAvatar) || other.callerAvatar == callerAvatar)&&(identical(other.callType, callType) || other.callType == callType)&&(identical(other.status, status) || other.status == status)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,callId,callerId,callerName,callerAvatar,callType,status,timestamp,duration);

@override
String toString() {
  return 'CallModel(callId: $callId, callerId: $callerId, callerName: $callerName, callerAvatar: $callerAvatar, callType: $callType, status: $status, timestamp: $timestamp, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $CallModelCopyWith<$Res>  {
  factory $CallModelCopyWith(CallModel value, $Res Function(CallModel) _then) = _$CallModelCopyWithImpl;
@useResult
$Res call({
 String callId, String callerId, String callerName, String? callerAvatar, CallType callType, CallStatus status, DateTime timestamp, int? duration
});




}
/// @nodoc
class _$CallModelCopyWithImpl<$Res>
    implements $CallModelCopyWith<$Res> {
  _$CallModelCopyWithImpl(this._self, this._then);

  final CallModel _self;
  final $Res Function(CallModel) _then;

/// Create a copy of CallModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? callId = null,Object? callerId = null,Object? callerName = null,Object? callerAvatar = freezed,Object? callType = null,Object? status = null,Object? timestamp = null,Object? duration = freezed,}) {
  return _then(_self.copyWith(
callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,callerId: null == callerId ? _self.callerId : callerId // ignore: cast_nullable_to_non_nullable
as String,callerName: null == callerName ? _self.callerName : callerName // ignore: cast_nullable_to_non_nullable
as String,callerAvatar: freezed == callerAvatar ? _self.callerAvatar : callerAvatar // ignore: cast_nullable_to_non_nullable
as String?,callType: null == callType ? _self.callType : callType // ignore: cast_nullable_to_non_nullable
as CallType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CallStatus,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CallModel].
extension CallModelPatterns on CallModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallModel value)  $default,){
final _that = this;
switch (_that) {
case _CallModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallModel value)?  $default,){
final _that = this;
switch (_that) {
case _CallModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String callId,  String callerId,  String callerName,  String? callerAvatar,  CallType callType,  CallStatus status,  DateTime timestamp,  int? duration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallModel() when $default != null:
return $default(_that.callId,_that.callerId,_that.callerName,_that.callerAvatar,_that.callType,_that.status,_that.timestamp,_that.duration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String callId,  String callerId,  String callerName,  String? callerAvatar,  CallType callType,  CallStatus status,  DateTime timestamp,  int? duration)  $default,) {final _that = this;
switch (_that) {
case _CallModel():
return $default(_that.callId,_that.callerId,_that.callerName,_that.callerAvatar,_that.callType,_that.status,_that.timestamp,_that.duration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String callId,  String callerId,  String callerName,  String? callerAvatar,  CallType callType,  CallStatus status,  DateTime timestamp,  int? duration)?  $default,) {final _that = this;
switch (_that) {
case _CallModel() when $default != null:
return $default(_that.callId,_that.callerId,_that.callerName,_that.callerAvatar,_that.callType,_that.status,_that.timestamp,_that.duration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CallModel implements CallModel {
  const _CallModel({required this.callId, required this.callerId, required this.callerName, this.callerAvatar, required this.callType, required this.status, required this.timestamp, this.duration});
  factory _CallModel.fromJson(Map<String, dynamic> json) => _$CallModelFromJson(json);

@override final  String callId;
@override final  String callerId;
@override final  String callerName;
@override final  String? callerAvatar;
@override final  CallType callType;
@override final  CallStatus status;
@override final  DateTime timestamp;
@override final  int? duration;

/// Create a copy of CallModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallModelCopyWith<_CallModel> get copyWith => __$CallModelCopyWithImpl<_CallModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallModel&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.callerId, callerId) || other.callerId == callerId)&&(identical(other.callerName, callerName) || other.callerName == callerName)&&(identical(other.callerAvatar, callerAvatar) || other.callerAvatar == callerAvatar)&&(identical(other.callType, callType) || other.callType == callType)&&(identical(other.status, status) || other.status == status)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,callId,callerId,callerName,callerAvatar,callType,status,timestamp,duration);

@override
String toString() {
  return 'CallModel(callId: $callId, callerId: $callerId, callerName: $callerName, callerAvatar: $callerAvatar, callType: $callType, status: $status, timestamp: $timestamp, duration: $duration)';
}


}

/// @nodoc
abstract mixin class _$CallModelCopyWith<$Res> implements $CallModelCopyWith<$Res> {
  factory _$CallModelCopyWith(_CallModel value, $Res Function(_CallModel) _then) = __$CallModelCopyWithImpl;
@override @useResult
$Res call({
 String callId, String callerId, String callerName, String? callerAvatar, CallType callType, CallStatus status, DateTime timestamp, int? duration
});




}
/// @nodoc
class __$CallModelCopyWithImpl<$Res>
    implements _$CallModelCopyWith<$Res> {
  __$CallModelCopyWithImpl(this._self, this._then);

  final _CallModel _self;
  final $Res Function(_CallModel) _then;

/// Create a copy of CallModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? callId = null,Object? callerId = null,Object? callerName = null,Object? callerAvatar = freezed,Object? callType = null,Object? status = null,Object? timestamp = null,Object? duration = freezed,}) {
  return _then(_CallModel(
callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,callerId: null == callerId ? _self.callerId : callerId // ignore: cast_nullable_to_non_nullable
as String,callerName: null == callerName ? _self.callerName : callerName // ignore: cast_nullable_to_non_nullable
as String,callerAvatar: freezed == callerAvatar ? _self.callerAvatar : callerAvatar // ignore: cast_nullable_to_non_nullable
as String?,callType: null == callType ? _self.callType : callType // ignore: cast_nullable_to_non_nullable
as CallType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CallStatus,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

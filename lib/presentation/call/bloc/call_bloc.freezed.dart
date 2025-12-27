// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CallState {

 CallModel? get currentCall; bool get isMuted; bool get isSpeakerOn; bool get isVideoEnabled; int get callDuration; bool get isLoading; String? get error;
/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallStateCopyWith<CallState> get copyWith => _$CallStateCopyWithImpl<CallState>(this as CallState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallState&&(identical(other.currentCall, currentCall) || other.currentCall == currentCall)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isSpeakerOn, isSpeakerOn) || other.isSpeakerOn == isSpeakerOn)&&(identical(other.isVideoEnabled, isVideoEnabled) || other.isVideoEnabled == isVideoEnabled)&&(identical(other.callDuration, callDuration) || other.callDuration == callDuration)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,currentCall,isMuted,isSpeakerOn,isVideoEnabled,callDuration,isLoading,error);

@override
String toString() {
  return 'CallState(currentCall: $currentCall, isMuted: $isMuted, isSpeakerOn: $isSpeakerOn, isVideoEnabled: $isVideoEnabled, callDuration: $callDuration, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class $CallStateCopyWith<$Res>  {
  factory $CallStateCopyWith(CallState value, $Res Function(CallState) _then) = _$CallStateCopyWithImpl;
@useResult
$Res call({
 CallModel? currentCall, bool isMuted, bool isSpeakerOn, bool isVideoEnabled, int callDuration, bool isLoading, String? error
});


$CallModelCopyWith<$Res>? get currentCall;

}
/// @nodoc
class _$CallStateCopyWithImpl<$Res>
    implements $CallStateCopyWith<$Res> {
  _$CallStateCopyWithImpl(this._self, this._then);

  final CallState _self;
  final $Res Function(CallState) _then;

/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentCall = freezed,Object? isMuted = null,Object? isSpeakerOn = null,Object? isVideoEnabled = null,Object? callDuration = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
currentCall: freezed == currentCall ? _self.currentCall : currentCall // ignore: cast_nullable_to_non_nullable
as CallModel?,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isSpeakerOn: null == isSpeakerOn ? _self.isSpeakerOn : isSpeakerOn // ignore: cast_nullable_to_non_nullable
as bool,isVideoEnabled: null == isVideoEnabled ? _self.isVideoEnabled : isVideoEnabled // ignore: cast_nullable_to_non_nullable
as bool,callDuration: null == callDuration ? _self.callDuration : callDuration // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CallModelCopyWith<$Res>? get currentCall {
    if (_self.currentCall == null) {
    return null;
  }

  return $CallModelCopyWith<$Res>(_self.currentCall!, (value) {
    return _then(_self.copyWith(currentCall: value));
  });
}
}


/// Adds pattern-matching-related methods to [CallState].
extension CallStatePatterns on CallState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallState value)  $default,){
final _that = this;
switch (_that) {
case _CallState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallState value)?  $default,){
final _that = this;
switch (_that) {
case _CallState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CallModel? currentCall,  bool isMuted,  bool isSpeakerOn,  bool isVideoEnabled,  int callDuration,  bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallState() when $default != null:
return $default(_that.currentCall,_that.isMuted,_that.isSpeakerOn,_that.isVideoEnabled,_that.callDuration,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CallModel? currentCall,  bool isMuted,  bool isSpeakerOn,  bool isVideoEnabled,  int callDuration,  bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _CallState():
return $default(_that.currentCall,_that.isMuted,_that.isSpeakerOn,_that.isVideoEnabled,_that.callDuration,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CallModel? currentCall,  bool isMuted,  bool isSpeakerOn,  bool isVideoEnabled,  int callDuration,  bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _CallState() when $default != null:
return $default(_that.currentCall,_that.isMuted,_that.isSpeakerOn,_that.isVideoEnabled,_that.callDuration,_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CallState extends CallState {
  const _CallState({this.currentCall, this.isMuted = false, this.isSpeakerOn = false, this.isVideoEnabled = false, this.callDuration = 0, this.isLoading = false, this.error}): super._();
  

@override final  CallModel? currentCall;
@override@JsonKey() final  bool isMuted;
@override@JsonKey() final  bool isSpeakerOn;
@override@JsonKey() final  bool isVideoEnabled;
@override@JsonKey() final  int callDuration;
@override@JsonKey() final  bool isLoading;
@override final  String? error;

/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallStateCopyWith<_CallState> get copyWith => __$CallStateCopyWithImpl<_CallState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallState&&(identical(other.currentCall, currentCall) || other.currentCall == currentCall)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isSpeakerOn, isSpeakerOn) || other.isSpeakerOn == isSpeakerOn)&&(identical(other.isVideoEnabled, isVideoEnabled) || other.isVideoEnabled == isVideoEnabled)&&(identical(other.callDuration, callDuration) || other.callDuration == callDuration)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,currentCall,isMuted,isSpeakerOn,isVideoEnabled,callDuration,isLoading,error);

@override
String toString() {
  return 'CallState(currentCall: $currentCall, isMuted: $isMuted, isSpeakerOn: $isSpeakerOn, isVideoEnabled: $isVideoEnabled, callDuration: $callDuration, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$CallStateCopyWith<$Res> implements $CallStateCopyWith<$Res> {
  factory _$CallStateCopyWith(_CallState value, $Res Function(_CallState) _then) = __$CallStateCopyWithImpl;
@override @useResult
$Res call({
 CallModel? currentCall, bool isMuted, bool isSpeakerOn, bool isVideoEnabled, int callDuration, bool isLoading, String? error
});


@override $CallModelCopyWith<$Res>? get currentCall;

}
/// @nodoc
class __$CallStateCopyWithImpl<$Res>
    implements _$CallStateCopyWith<$Res> {
  __$CallStateCopyWithImpl(this._self, this._then);

  final _CallState _self;
  final $Res Function(_CallState) _then;

/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentCall = freezed,Object? isMuted = null,Object? isSpeakerOn = null,Object? isVideoEnabled = null,Object? callDuration = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_CallState(
currentCall: freezed == currentCall ? _self.currentCall : currentCall // ignore: cast_nullable_to_non_nullable
as CallModel?,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isSpeakerOn: null == isSpeakerOn ? _self.isSpeakerOn : isSpeakerOn // ignore: cast_nullable_to_non_nullable
as bool,isVideoEnabled: null == isVideoEnabled ? _self.isVideoEnabled : isVideoEnabled // ignore: cast_nullable_to_non_nullable
as bool,callDuration: null == callDuration ? _self.callDuration : callDuration // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CallModelCopyWith<$Res>? get currentCall {
    if (_self.currentCall == null) {
    return null;
  }

  return $CallModelCopyWith<$Res>(_self.currentCall!, (value) {
    return _then(_self.copyWith(currentCall: value));
  });
}
}

/// @nodoc
mixin _$CallEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent()';
}


}

/// @nodoc
class $CallEventCopyWith<$Res>  {
$CallEventCopyWith(CallEvent _, $Res Function(CallEvent) __);
}


/// Adds pattern-matching-related methods to [CallEvent].
extension CallEventPatterns on CallEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Initialized value)?  initEvent,TResult Function( MakeCall value)?  makeCall,TResult Function( ReceiveCall value)?  receiveCall,TResult Function( AcceptCall value)?  acceptCall,TResult Function( DeclineCall value)?  declineCall,TResult Function( EndCall value)?  endCall,TResult Function( ToggleMute value)?  toggleMute,TResult Function( ToggleSpeaker value)?  toggleSpeaker,TResult Function( ToggleVideo value)?  toggleVideo,TResult Function( UpdateCallStatus value)?  updateCallStatus,TResult Function( UpdateDuration value)?  updateDuration,TResult Function( HandleCallKitEvent value)?  handleCallKitEvent,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Initialized() when initEvent != null:
return initEvent(_that);case MakeCall() when makeCall != null:
return makeCall(_that);case ReceiveCall() when receiveCall != null:
return receiveCall(_that);case AcceptCall() when acceptCall != null:
return acceptCall(_that);case DeclineCall() when declineCall != null:
return declineCall(_that);case EndCall() when endCall != null:
return endCall(_that);case ToggleMute() when toggleMute != null:
return toggleMute(_that);case ToggleSpeaker() when toggleSpeaker != null:
return toggleSpeaker(_that);case ToggleVideo() when toggleVideo != null:
return toggleVideo(_that);case UpdateCallStatus() when updateCallStatus != null:
return updateCallStatus(_that);case UpdateDuration() when updateDuration != null:
return updateDuration(_that);case HandleCallKitEvent() when handleCallKitEvent != null:
return handleCallKitEvent(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Initialized value)  initEvent,required TResult Function( MakeCall value)  makeCall,required TResult Function( ReceiveCall value)  receiveCall,required TResult Function( AcceptCall value)  acceptCall,required TResult Function( DeclineCall value)  declineCall,required TResult Function( EndCall value)  endCall,required TResult Function( ToggleMute value)  toggleMute,required TResult Function( ToggleSpeaker value)  toggleSpeaker,required TResult Function( ToggleVideo value)  toggleVideo,required TResult Function( UpdateCallStatus value)  updateCallStatus,required TResult Function( UpdateDuration value)  updateDuration,required TResult Function( HandleCallKitEvent value)  handleCallKitEvent,}){
final _that = this;
switch (_that) {
case Initialized():
return initEvent(_that);case MakeCall():
return makeCall(_that);case ReceiveCall():
return receiveCall(_that);case AcceptCall():
return acceptCall(_that);case DeclineCall():
return declineCall(_that);case EndCall():
return endCall(_that);case ToggleMute():
return toggleMute(_that);case ToggleSpeaker():
return toggleSpeaker(_that);case ToggleVideo():
return toggleVideo(_that);case UpdateCallStatus():
return updateCallStatus(_that);case UpdateDuration():
return updateDuration(_that);case HandleCallKitEvent():
return handleCallKitEvent(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Initialized value)?  initEvent,TResult? Function( MakeCall value)?  makeCall,TResult? Function( ReceiveCall value)?  receiveCall,TResult? Function( AcceptCall value)?  acceptCall,TResult? Function( DeclineCall value)?  declineCall,TResult? Function( EndCall value)?  endCall,TResult? Function( ToggleMute value)?  toggleMute,TResult? Function( ToggleSpeaker value)?  toggleSpeaker,TResult? Function( ToggleVideo value)?  toggleVideo,TResult? Function( UpdateCallStatus value)?  updateCallStatus,TResult? Function( UpdateDuration value)?  updateDuration,TResult? Function( HandleCallKitEvent value)?  handleCallKitEvent,}){
final _that = this;
switch (_that) {
case Initialized() when initEvent != null:
return initEvent(_that);case MakeCall() when makeCall != null:
return makeCall(_that);case ReceiveCall() when receiveCall != null:
return receiveCall(_that);case AcceptCall() when acceptCall != null:
return acceptCall(_that);case DeclineCall() when declineCall != null:
return declineCall(_that);case EndCall() when endCall != null:
return endCall(_that);case ToggleMute() when toggleMute != null:
return toggleMute(_that);case ToggleSpeaker() when toggleSpeaker != null:
return toggleSpeaker(_that);case ToggleVideo() when toggleVideo != null:
return toggleVideo(_that);case UpdateCallStatus() when updateCallStatus != null:
return updateCallStatus(_that);case UpdateDuration() when updateDuration != null:
return updateDuration(_that);case HandleCallKitEvent() when handleCallKitEvent != null:
return handleCallKitEvent(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initEvent,TResult Function( String calleeId,  String calleeName,  String? calleeAvatar,  CallType callType)?  makeCall,TResult Function( String callId,  String callerId,  String callerName,  String? callerAvatar,  CallType callType)?  receiveCall,TResult Function()?  acceptCall,TResult Function()?  declineCall,TResult Function()?  endCall,TResult Function()?  toggleMute,TResult Function()?  toggleSpeaker,TResult Function()?  toggleVideo,TResult Function( CallStatus status)?  updateCallStatus,TResult Function( int seconds)?  updateDuration,TResult Function( CallKitEvent event)?  handleCallKitEvent,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Initialized() when initEvent != null:
return initEvent();case MakeCall() when makeCall != null:
return makeCall(_that.calleeId,_that.calleeName,_that.calleeAvatar,_that.callType);case ReceiveCall() when receiveCall != null:
return receiveCall(_that.callId,_that.callerId,_that.callerName,_that.callerAvatar,_that.callType);case AcceptCall() when acceptCall != null:
return acceptCall();case DeclineCall() when declineCall != null:
return declineCall();case EndCall() when endCall != null:
return endCall();case ToggleMute() when toggleMute != null:
return toggleMute();case ToggleSpeaker() when toggleSpeaker != null:
return toggleSpeaker();case ToggleVideo() when toggleVideo != null:
return toggleVideo();case UpdateCallStatus() when updateCallStatus != null:
return updateCallStatus(_that.status);case UpdateDuration() when updateDuration != null:
return updateDuration(_that.seconds);case HandleCallKitEvent() when handleCallKitEvent != null:
return handleCallKitEvent(_that.event);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initEvent,required TResult Function( String calleeId,  String calleeName,  String? calleeAvatar,  CallType callType)  makeCall,required TResult Function( String callId,  String callerId,  String callerName,  String? callerAvatar,  CallType callType)  receiveCall,required TResult Function()  acceptCall,required TResult Function()  declineCall,required TResult Function()  endCall,required TResult Function()  toggleMute,required TResult Function()  toggleSpeaker,required TResult Function()  toggleVideo,required TResult Function( CallStatus status)  updateCallStatus,required TResult Function( int seconds)  updateDuration,required TResult Function( CallKitEvent event)  handleCallKitEvent,}) {final _that = this;
switch (_that) {
case Initialized():
return initEvent();case MakeCall():
return makeCall(_that.calleeId,_that.calleeName,_that.calleeAvatar,_that.callType);case ReceiveCall():
return receiveCall(_that.callId,_that.callerId,_that.callerName,_that.callerAvatar,_that.callType);case AcceptCall():
return acceptCall();case DeclineCall():
return declineCall();case EndCall():
return endCall();case ToggleMute():
return toggleMute();case ToggleSpeaker():
return toggleSpeaker();case ToggleVideo():
return toggleVideo();case UpdateCallStatus():
return updateCallStatus(_that.status);case UpdateDuration():
return updateDuration(_that.seconds);case HandleCallKitEvent():
return handleCallKitEvent(_that.event);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initEvent,TResult? Function( String calleeId,  String calleeName,  String? calleeAvatar,  CallType callType)?  makeCall,TResult? Function( String callId,  String callerId,  String callerName,  String? callerAvatar,  CallType callType)?  receiveCall,TResult? Function()?  acceptCall,TResult? Function()?  declineCall,TResult? Function()?  endCall,TResult? Function()?  toggleMute,TResult? Function()?  toggleSpeaker,TResult? Function()?  toggleVideo,TResult? Function( CallStatus status)?  updateCallStatus,TResult? Function( int seconds)?  updateDuration,TResult? Function( CallKitEvent event)?  handleCallKitEvent,}) {final _that = this;
switch (_that) {
case Initialized() when initEvent != null:
return initEvent();case MakeCall() when makeCall != null:
return makeCall(_that.calleeId,_that.calleeName,_that.calleeAvatar,_that.callType);case ReceiveCall() when receiveCall != null:
return receiveCall(_that.callId,_that.callerId,_that.callerName,_that.callerAvatar,_that.callType);case AcceptCall() when acceptCall != null:
return acceptCall();case DeclineCall() when declineCall != null:
return declineCall();case EndCall() when endCall != null:
return endCall();case ToggleMute() when toggleMute != null:
return toggleMute();case ToggleSpeaker() when toggleSpeaker != null:
return toggleSpeaker();case ToggleVideo() when toggleVideo != null:
return toggleVideo();case UpdateCallStatus() when updateCallStatus != null:
return updateCallStatus(_that.status);case UpdateDuration() when updateDuration != null:
return updateDuration(_that.seconds);case HandleCallKitEvent() when handleCallKitEvent != null:
return handleCallKitEvent(_that.event);case _:
  return null;

}
}

}

/// @nodoc


class Initialized implements CallEvent {
  const Initialized();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Initialized);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent.initEvent()';
}


}




/// @nodoc


class MakeCall implements CallEvent {
  const MakeCall({required this.calleeId, required this.calleeName, this.calleeAvatar, required this.callType});
  

 final  String calleeId;
 final  String calleeName;
 final  String? calleeAvatar;
 final  CallType callType;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MakeCallCopyWith<MakeCall> get copyWith => _$MakeCallCopyWithImpl<MakeCall>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MakeCall&&(identical(other.calleeId, calleeId) || other.calleeId == calleeId)&&(identical(other.calleeName, calleeName) || other.calleeName == calleeName)&&(identical(other.calleeAvatar, calleeAvatar) || other.calleeAvatar == calleeAvatar)&&(identical(other.callType, callType) || other.callType == callType));
}


@override
int get hashCode => Object.hash(runtimeType,calleeId,calleeName,calleeAvatar,callType);

@override
String toString() {
  return 'CallEvent.makeCall(calleeId: $calleeId, calleeName: $calleeName, calleeAvatar: $calleeAvatar, callType: $callType)';
}


}

/// @nodoc
abstract mixin class $MakeCallCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory $MakeCallCopyWith(MakeCall value, $Res Function(MakeCall) _then) = _$MakeCallCopyWithImpl;
@useResult
$Res call({
 String calleeId, String calleeName, String? calleeAvatar, CallType callType
});




}
/// @nodoc
class _$MakeCallCopyWithImpl<$Res>
    implements $MakeCallCopyWith<$Res> {
  _$MakeCallCopyWithImpl(this._self, this._then);

  final MakeCall _self;
  final $Res Function(MakeCall) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? calleeId = null,Object? calleeName = null,Object? calleeAvatar = freezed,Object? callType = null,}) {
  return _then(MakeCall(
calleeId: null == calleeId ? _self.calleeId : calleeId // ignore: cast_nullable_to_non_nullable
as String,calleeName: null == calleeName ? _self.calleeName : calleeName // ignore: cast_nullable_to_non_nullable
as String,calleeAvatar: freezed == calleeAvatar ? _self.calleeAvatar : calleeAvatar // ignore: cast_nullable_to_non_nullable
as String?,callType: null == callType ? _self.callType : callType // ignore: cast_nullable_to_non_nullable
as CallType,
  ));
}


}

/// @nodoc


class ReceiveCall implements CallEvent {
  const ReceiveCall({required this.callId, required this.callerId, required this.callerName, this.callerAvatar, required this.callType});
  

 final  String callId;
 final  String callerId;
 final  String callerName;
 final  String? callerAvatar;
 final  CallType callType;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiveCallCopyWith<ReceiveCall> get copyWith => _$ReceiveCallCopyWithImpl<ReceiveCall>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiveCall&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.callerId, callerId) || other.callerId == callerId)&&(identical(other.callerName, callerName) || other.callerName == callerName)&&(identical(other.callerAvatar, callerAvatar) || other.callerAvatar == callerAvatar)&&(identical(other.callType, callType) || other.callType == callType));
}


@override
int get hashCode => Object.hash(runtimeType,callId,callerId,callerName,callerAvatar,callType);

@override
String toString() {
  return 'CallEvent.receiveCall(callId: $callId, callerId: $callerId, callerName: $callerName, callerAvatar: $callerAvatar, callType: $callType)';
}


}

/// @nodoc
abstract mixin class $ReceiveCallCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory $ReceiveCallCopyWith(ReceiveCall value, $Res Function(ReceiveCall) _then) = _$ReceiveCallCopyWithImpl;
@useResult
$Res call({
 String callId, String callerId, String callerName, String? callerAvatar, CallType callType
});




}
/// @nodoc
class _$ReceiveCallCopyWithImpl<$Res>
    implements $ReceiveCallCopyWith<$Res> {
  _$ReceiveCallCopyWithImpl(this._self, this._then);

  final ReceiveCall _self;
  final $Res Function(ReceiveCall) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? callId = null,Object? callerId = null,Object? callerName = null,Object? callerAvatar = freezed,Object? callType = null,}) {
  return _then(ReceiveCall(
callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,callerId: null == callerId ? _self.callerId : callerId // ignore: cast_nullable_to_non_nullable
as String,callerName: null == callerName ? _self.callerName : callerName // ignore: cast_nullable_to_non_nullable
as String,callerAvatar: freezed == callerAvatar ? _self.callerAvatar : callerAvatar // ignore: cast_nullable_to_non_nullable
as String?,callType: null == callType ? _self.callType : callType // ignore: cast_nullable_to_non_nullable
as CallType,
  ));
}


}

/// @nodoc


class AcceptCall implements CallEvent {
  const AcceptCall();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcceptCall);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent.acceptCall()';
}


}




/// @nodoc


class DeclineCall implements CallEvent {
  const DeclineCall();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeclineCall);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent.declineCall()';
}


}




/// @nodoc


class EndCall implements CallEvent {
  const EndCall();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EndCall);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent.endCall()';
}


}




/// @nodoc


class ToggleMute implements CallEvent {
  const ToggleMute();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToggleMute);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent.toggleMute()';
}


}




/// @nodoc


class ToggleSpeaker implements CallEvent {
  const ToggleSpeaker();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToggleSpeaker);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent.toggleSpeaker()';
}


}




/// @nodoc


class ToggleVideo implements CallEvent {
  const ToggleVideo();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToggleVideo);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallEvent.toggleVideo()';
}


}




/// @nodoc


class UpdateCallStatus implements CallEvent {
  const UpdateCallStatus(this.status);
  

 final  CallStatus status;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateCallStatusCopyWith<UpdateCallStatus> get copyWith => _$UpdateCallStatusCopyWithImpl<UpdateCallStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateCallStatus&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'CallEvent.updateCallStatus(status: $status)';
}


}

/// @nodoc
abstract mixin class $UpdateCallStatusCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory $UpdateCallStatusCopyWith(UpdateCallStatus value, $Res Function(UpdateCallStatus) _then) = _$UpdateCallStatusCopyWithImpl;
@useResult
$Res call({
 CallStatus status
});




}
/// @nodoc
class _$UpdateCallStatusCopyWithImpl<$Res>
    implements $UpdateCallStatusCopyWith<$Res> {
  _$UpdateCallStatusCopyWithImpl(this._self, this._then);

  final UpdateCallStatus _self;
  final $Res Function(UpdateCallStatus) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(UpdateCallStatus(
null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CallStatus,
  ));
}


}

/// @nodoc


class UpdateDuration implements CallEvent {
  const UpdateDuration(this.seconds);
  

 final  int seconds;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateDurationCopyWith<UpdateDuration> get copyWith => _$UpdateDurationCopyWithImpl<UpdateDuration>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateDuration&&(identical(other.seconds, seconds) || other.seconds == seconds));
}


@override
int get hashCode => Object.hash(runtimeType,seconds);

@override
String toString() {
  return 'CallEvent.updateDuration(seconds: $seconds)';
}


}

/// @nodoc
abstract mixin class $UpdateDurationCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory $UpdateDurationCopyWith(UpdateDuration value, $Res Function(UpdateDuration) _then) = _$UpdateDurationCopyWithImpl;
@useResult
$Res call({
 int seconds
});




}
/// @nodoc
class _$UpdateDurationCopyWithImpl<$Res>
    implements $UpdateDurationCopyWith<$Res> {
  _$UpdateDurationCopyWithImpl(this._self, this._then);

  final UpdateDuration _self;
  final $Res Function(UpdateDuration) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? seconds = null,}) {
  return _then(UpdateDuration(
null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class HandleCallKitEvent implements CallEvent {
  const HandleCallKitEvent(this.event);
  

 final  CallKitEvent event;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HandleCallKitEventCopyWith<HandleCallKitEvent> get copyWith => _$HandleCallKitEventCopyWithImpl<HandleCallKitEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandleCallKitEvent&&(identical(other.event, event) || other.event == event));
}


@override
int get hashCode => Object.hash(runtimeType,event);

@override
String toString() {
  return 'CallEvent.handleCallKitEvent(event: $event)';
}


}

/// @nodoc
abstract mixin class $HandleCallKitEventCopyWith<$Res> implements $CallEventCopyWith<$Res> {
  factory $HandleCallKitEventCopyWith(HandleCallKitEvent value, $Res Function(HandleCallKitEvent) _then) = _$HandleCallKitEventCopyWithImpl;
@useResult
$Res call({
 CallKitEvent event
});




}
/// @nodoc
class _$HandleCallKitEventCopyWithImpl<$Res>
    implements $HandleCallKitEventCopyWith<$Res> {
  _$HandleCallKitEventCopyWithImpl(this._self, this._then);

  final HandleCallKitEvent _self;
  final $Res Function(HandleCallKitEvent) _then;

/// Create a copy of CallEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? event = null,}) {
  return _then(HandleCallKitEvent(
null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as CallKitEvent,
  ));
}


}

// dart format on

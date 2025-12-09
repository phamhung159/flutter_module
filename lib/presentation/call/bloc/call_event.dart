part of 'call_bloc.dart';

@freezed
class CallEvent with _$CallEvent {
  const factory CallEvent.initEvent() = Initialized;
  
  const factory CallEvent.makeCall({
    required String calleeId,
    required String calleeName,
    String? calleeAvatar,
    required CallType callType,
  }) = MakeCall;
  
  const factory CallEvent.receiveCall({
    required String callId,
    required String callerId,
    required String callerName,
    String? callerAvatar,
    required CallType callType,
  }) = ReceiveCall;
  
  const factory CallEvent.acceptCall() = AcceptCall;
  
  const factory CallEvent.declineCall() = DeclineCall;
  
  const factory CallEvent.endCall() = EndCall;
  
  const factory CallEvent.toggleMute() = ToggleMute;
  
  const factory CallEvent.toggleSpeaker() = ToggleSpeaker;
  
  const factory CallEvent.toggleVideo() = ToggleVideo;
  
  const factory CallEvent.updateCallStatus(CallStatus status) = UpdateCallStatus;
  
  const factory CallEvent.updateDuration(int seconds) = UpdateDuration;
  
  const factory CallEvent.handleCallKitEvent(CallKitEvent event) = HandleCallKitEvent;
}


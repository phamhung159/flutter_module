part of 'call_bloc.dart';

@freezed
abstract class CallState with _$CallState {
  const factory CallState({
    CallModel? currentCall,
    @Default(false) bool isMuted,
    @Default(false) bool isSpeakerOn,
    @Default(false) bool isVideoEnabled,
    @Default(0) int callDuration,
    @Default(false) bool isLoading,
    String? error,
  }) = _CallState;
  
  const CallState._();
  
  bool get hasActiveCall => currentCall != null && 
    (currentCall!.status == CallStatus.connected || 
     currentCall!.status == CallStatus.connecting ||
     currentCall!.status == CallStatus.outgoing ||
     currentCall!.status == CallStatus.incoming);
  
  bool get isInCall => currentCall?.status == CallStatus.connected;
  
  bool get isIncoming => currentCall?.status == CallStatus.incoming;
  
  bool get isOutgoing => currentCall?.status == CallStatus.outgoing;
}


import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_module/data/models/call_dto.dart';
import 'package:flutter_module/data/services/callkit_service.dart';
import 'package:flutter_module/data/services/tencent_call_service.dart';
import 'package:flutter_module/repositories/models/call_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'call_state.dart';
part 'call_event.dart';
part 'call_bloc.freezed.dart';

@injectable
class CallBloc extends Bloc<CallEvent, CallState> {
  final CallKitService _callKitService;
  final TencentCallService _tencentService;
  StreamSubscription? _callKitSubscription;
  StreamSubscription? _tencentSubscription;
  Timer? _durationTimer;

  CallBloc(this._callKitService, this._tencentService)
    : super(const CallState()) {
    on<Initialized>(_onInitializedEvent);
    on<MakeCall>(_onMakeCallEvent);
    on<ReceiveCall>(_onReceiveCallEvent);
    on<AcceptCall>(_onAcceptCallEvent);
    on<DeclineCall>(_onDeclineCallEvent);
    on<EndCall>(_onEndCallEvent);
    on<ToggleMute>(_onToggleMuteEvent);
    on<ToggleSpeaker>(_onToggleSpeakerEvent);
    on<ToggleVideo>(_onToggleVideoEvent);
    on<UpdateCallStatus>(_onUpdateCallStatusEvent);
    on<UpdateDuration>(_onUpdateDurationEvent);
    on<HandleCallKitEvent>(_onHandleCallKitEvent);
  }

  Future<void> _onInitializedEvent(
    Initialized event,
    Emitter<CallState> emit,
  ) async {
    await _callKitService.initialize();

    _callKitSubscription = _callKitService.eventStream.listen((callKitEvent) {
      add(CallEvent.handleCallKitEvent(callKitEvent));
    });

    _tencentSubscription = _tencentService.eventStream.listen((tencentEvent) {
      _handleTencentEvent(tencentEvent);
    });
  }

  Future<void> _onMakeCallEvent(MakeCall event, Emitter<CallState> emit) async {
    try {
      final callId = _callKitService.generateCallId();

      final call = CallModel(
        callId: callId,
        callerId: '', // Current user would be the caller
        callerName: 'Me',
        callerAvatar: null,
        callType: event.callType,
        status: CallStatus.outgoing,
        timestamp: DateTime.now(),
      );

      emit(state.copyWith(currentCall: call, isLoading: false));

      await _callKitService.startOutgoingCall(
        callId: callId,
        calleeId: event.calleeId,
        calleeName: event.calleeName,
        calleeAvatar: event.calleeAvatar,
        isVideo: event.callType == CallType.video,
      );

      await _tencentService.call(
        userId: event.calleeId,
        isVideo: event.callType == CallType.video,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onReceiveCallEvent(
    ReceiveCall event,
    Emitter<CallState> emit,
  ) async {
    try {
      final call = CallModel(
        callId: event.callId,
        callerId: event.callerId,
        callerName: event.callerName,
        callerAvatar: event.callerAvatar,
        callType: event.callType,
        status: CallStatus.incoming,
        timestamp: DateTime.now(),
      );

      emit(state.copyWith(currentCall: call));

      // Show incoming call in CallKit
      await _callKitService.showIncomingCall(
        callId: event.callId,
        callerId: event.callerId,
        callerName: event.callerName,
        callerAvatar: event.callerAvatar,
        isVideo: event.callType == CallType.video,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAcceptCallEvent(
    AcceptCall event,
    Emitter<CallState> emit,
  ) async {
    if (state.currentCall == null) return;

    try {
      final updatedCall = state.currentCall!.copyWith(
        status: CallStatus.connecting,
      );
      emit(state.copyWith(currentCall: updatedCall));

      await _tencentService.acceptCall();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeclineCallEvent(
    DeclineCall event,
    Emitter<CallState> emit,
  ) async {
    if (state.currentCall == null) return;

    try {
      await _callKitService.endCall(state.currentCall!.callId);
      await _tencentService.rejectCall();

      final updatedCall = state.currentCall!.copyWith(
        status: CallStatus.declined,
      );
      emit(state.copyWith(currentCall: updatedCall));

      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(currentCall: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onEndCallEvent(EndCall event, Emitter<CallState> emit) async {
    if (state.currentCall == null) return;

    try {
      await _callKitService.endCall(state.currentCall!.callId);
      await _tencentService.hangup();

      final updatedCall = state.currentCall!.copyWith(
        status: CallStatus.ended,
        duration: state.callDuration,
      );
      emit(state.copyWith(currentCall: updatedCall));

      _stopDurationTimer();

      await Future.delayed(const Duration(seconds: 1));
      emit(const CallState());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onToggleMuteEvent(ToggleMute event, Emitter<CallState> emit) {
    final newMuteState = !state.isMuted;
    emit(state.copyWith(isMuted: newMuteState));
    _tencentService.setMicMute(newMuteState);
  }

  void _onToggleSpeakerEvent(ToggleSpeaker event, Emitter<CallState> emit) {
    final newSpeakerState = !state.isSpeakerOn;
    emit(state.copyWith(isSpeakerOn: newSpeakerState));
    _tencentService.setSpeaker(newSpeakerState);
  }

  void _onToggleVideoEvent(ToggleVideo event, Emitter<CallState> emit) {
    if (state.currentCall?.callType == CallType.video) {
      final newVideoState = !state.isVideoEnabled;
      emit(state.copyWith(isVideoEnabled: newVideoState));
      _tencentService.setVideoMute(!newVideoState);
    }
  }

  void _onUpdateCallStatusEvent(
    UpdateCallStatus event,
    Emitter<CallState> emit,
  ) {
    if (state.currentCall == null) return;

    final updatedCall = state.currentCall!.copyWith(status: event.status);
    emit(state.copyWith(currentCall: updatedCall));

    // Start duration timer when connected
    if (event.status == CallStatus.connected) {
      _startDurationTimer();
    } else if (event.status == CallStatus.ended ||
        event.status == CallStatus.declined ||
        event.status == CallStatus.missed) {
      _stopDurationTimer();
    }
  }

  void _onUpdateDurationEvent(UpdateDuration event, Emitter<CallState> emit) {
    emit(state.copyWith(callDuration: event.seconds));
  }

  Future<void> _onHandleCallKitEvent(
    HandleCallKitEvent event,
    Emitter<CallState> emit,
  ) async {
    final callKitEvent = event.event;

    switch (callKitEvent) {
      case CallKitEventAccepted():
        add(const CallEvent.acceptCall());
        break;
      case CallKitEventDeclined():
        add(const CallEvent.declineCall());
        break;
      case CallKitEventEnded():
        add(const CallEvent.endCall());
        break;
      case CallKitEventTimeout():
        if (state.currentCall != null) {
          final updatedCall = state.currentCall!.copyWith(
            status: CallStatus.missed,
          );
          emit(state.copyWith(currentCall: updatedCall));
          await Future.delayed(const Duration(milliseconds: 500));
          emit(state.copyWith(currentCall: null));
        }
        break;
      case CallKitEventMute():
        add(const CallEvent.toggleMute());
        break;
      default:
        break;
    }
  }

  void _startDurationTimer() {
    _stopDurationTimer();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(CallEvent.updateDuration(timer.tick));
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void _handleTencentEvent(TencentCallEvent event) {
    switch (event) {
      case TencentCallReceived(callerId: final id, isVideo: final video):
        add(
          CallEvent.receiveCall(
            callId: 'tencent-$id',
            callerId: id,
            callerName: id,
            callType: video ? CallType.video : CallType.audio,
          ),
        );
        break;
      case TencentCallBegan():
        add(const CallEvent.updateCallStatus(CallStatus.connected));
        break;
      case TencentCallEnded(duration: final duration):
        add(CallEvent.updateDuration(duration));
        add(const CallEvent.endCall());
        break;
      case TencentCallCancelled():
        add(const CallEvent.declineCall());
        break;
      case TencentUserRejected():
      case TencentUserNoResponse():
      case TencentUserBusy():
        add(const CallEvent.endCall());
        break;
      default:
        break;
    }
  }

  @override
  Future<void> close() {
    _callKitSubscription?.cancel();
    _tencentSubscription?.cancel();
    _stopDurationTimer();
    return super.close();
  }
}

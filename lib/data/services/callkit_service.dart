import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
class CallKitService {
  StreamSubscription? _subscription;
  final StreamController<CallKitEvent> _eventController = StreamController.broadcast();

  Stream<CallKitEvent> get eventStream => _eventController.stream;

  Future<void> initialize() async {
    if (Platform.isIOS || Platform.isAndroid) {
      _subscription = FlutterCallkitIncoming.onEvent.listen((event) {
        debugPrint('📞 CallKit Event: ${event?.event}');
        
        switch (event!.event) {
          case Event.actionCallIncoming:
            _eventController.add(CallKitEvent.incoming(event.body));
            break;
          case Event.actionCallStart:
            _eventController.add(CallKitEvent.started(event.body));
            break;
          case Event.actionCallAccept:
            _eventController.add(CallKitEvent.accepted(event.body));
            break;
          case Event.actionCallDecline:
            _eventController.add(CallKitEvent.declined(event.body));
            break;
          case Event.actionCallEnded:
            _eventController.add(CallKitEvent.ended(event.body));
            break;
          case Event.actionCallTimeout:
            _eventController.add(CallKitEvent.timeout(event.body));
            break;
          case Event.actionCallCallback:
            _eventController.add(CallKitEvent.callback(event.body));
            break;
          case Event.actionCallToggleHold:
            _eventController.add(CallKitEvent.hold(event.body));
            break;
          case Event.actionCallToggleMute:
            _eventController.add(CallKitEvent.mute(event.body));
            break;
          case Event.actionCallToggleDmtf:
            _eventController.add(CallKitEvent.dmtf(event.body));
            break;
          case Event.actionCallToggleGroup:
            _eventController.add(CallKitEvent.group(event.body));
            break;
          case Event.actionCallToggleAudioSession:
            _eventController.add(CallKitEvent.audioSession(event.body));
            break;
          case Event.actionDidUpdateDevicePushTokenVoip:
            _eventController.add(CallKitEvent.pushToken(event.body));
            break;
          case Event.actionCallConnected:
            // Call connected event - can be used for analytics
            break;
          case Event.actionCallCustom:
            // Custom call event
            break;
        }
      });
    }
  }

  Future<void> showIncomingCall({
    required String callId,
    required String callerId,
    required String callerName,
    String? callerAvatar,
    bool isVideo = false,
  }) async {
    final params = CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: 'Flutter Module',
      avatar: callerAvatar,
      handle: callerId,
      type: isVideo ? 1 : 0, // 0: Audio, 1: Video
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: <String, dynamic>{
        'callId': callId,
        'callerId': callerId,
        'callerName': callerName,
        'isVideo': isVideo,
      },
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: '',
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call",
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  Future<void> startOutgoingCall({
    required String callId,
    required String calleeId,
    required String calleeName,
    String? calleeAvatar,
    bool isVideo = false,
  }) async {
    final params = CallKitParams(
      id: callId,
      nameCaller: calleeName,
      appName: 'Flutter Module',
      avatar: calleeAvatar,
      handle: calleeId,
      type: isVideo ? 1 : 0,
      duration: 30000,
      extra: <String, dynamic>{
        'callId': callId,
        'calleeId': calleeId,
        'calleeName': calleeName,
        'isVideo': isVideo,
      },
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.startCall(params);
  }

  Future<void> endCall(String callId) async {
    await FlutterCallkitIncoming.endCall(callId);
  }

  Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }

  Future<List<dynamic>> getActiveCalls() async {
    final calls = await FlutterCallkitIncoming.activeCalls();
    return calls ?? [];
  }

  Future<Map<String, dynamic>?> getCallData(String callId) async {
    final calls = await getActiveCalls();
    for (var call in calls) {
      if (call['id'] == callId) {
        return call;
      }
    }
    return null;
  }

  String generateCallId() {
    return const Uuid().v4();
  }

  void dispose() {
    _subscription?.cancel();
    _eventController.close();
  }
}

sealed class CallKitEvent {
  final Map<String, dynamic>? data;
  const CallKitEvent(this.data);

  const factory CallKitEvent.incoming(Map<String, dynamic>? data) = CallKitEventIncoming;
  const factory CallKitEvent.started(Map<String, dynamic>? data) = CallKitEventStarted;
  const factory CallKitEvent.accepted(Map<String, dynamic>? data) = CallKitEventAccepted;
  const factory CallKitEvent.declined(Map<String, dynamic>? data) = CallKitEventDeclined;
  const factory CallKitEvent.ended(Map<String, dynamic>? data) = CallKitEventEnded;
  const factory CallKitEvent.timeout(Map<String, dynamic>? data) = CallKitEventTimeout;
  const factory CallKitEvent.callback(Map<String, dynamic>? data) = CallKitEventCallback;
  const factory CallKitEvent.hold(Map<String, dynamic>? data) = CallKitEventHold;
  const factory CallKitEvent.mute(Map<String, dynamic>? data) = CallKitEventMute;
  const factory CallKitEvent.dmtf(Map<String, dynamic>? data) = CallKitEventDmtf;
  const factory CallKitEvent.group(Map<String, dynamic>? data) = CallKitEventGroup;
  const factory CallKitEvent.audioSession(Map<String, dynamic>? data) = CallKitEventAudioSession;
  const factory CallKitEvent.pushToken(Map<String, dynamic>? data) = CallKitEventPushToken;
}

class CallKitEventIncoming extends CallKitEvent {
  const CallKitEventIncoming(super.data);
}

class CallKitEventStarted extends CallKitEvent {
  const CallKitEventStarted(super.data);
}

class CallKitEventAccepted extends CallKitEvent {
  const CallKitEventAccepted(super.data);
}

class CallKitEventDeclined extends CallKitEvent {
  const CallKitEventDeclined(super.data);
}

class CallKitEventEnded extends CallKitEvent {
  const CallKitEventEnded(super.data);
}

class CallKitEventTimeout extends CallKitEvent {
  const CallKitEventTimeout(super.data);
}

class CallKitEventCallback extends CallKitEvent {
  const CallKitEventCallback(super.data);
}

class CallKitEventHold extends CallKitEvent {
  const CallKitEventHold(super.data);
}

class CallKitEventMute extends CallKitEvent {
  const CallKitEventMute(super.data);
}

class CallKitEventDmtf extends CallKitEvent {
  const CallKitEventDmtf(super.data);
}

class CallKitEventGroup extends CallKitEvent {
  const CallKitEventGroup(super.data);
}

class CallKitEventAudioSession extends CallKitEvent {
  const CallKitEventAudioSession(super.data);
}

class CallKitEventPushToken extends CallKitEvent {
  const CallKitEventPushToken(super.data);
}


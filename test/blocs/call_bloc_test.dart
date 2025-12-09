import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_module/presentation/call/bloc/call_bloc.dart';
import 'package:flutter_module/data/services/callkit_service.dart';
import 'package:flutter_module/data/services/tencent_call_service.dart';
import 'package:flutter_module/data/models/call_dto.dart';
import 'package:flutter_module/repositories/models/call_model.dart';

class MockCallKitService extends Mock implements CallKitService {}

class MockTencentCallService extends Mock implements TencentCallService {}

void main() {
  late CallBloc callBloc;
  late MockCallKitService mockCallKitService;
  late MockTencentCallService mockTencentService;
  late StreamController<CallKitEvent> callKitEventController;
  late StreamController<TencentCallEvent> tencentEventController;

  setUp(() {
    mockCallKitService = MockCallKitService();
    mockTencentService = MockTencentCallService();
    callKitEventController = StreamController<CallKitEvent>.broadcast();
    tencentEventController = StreamController<TencentCallEvent>.broadcast();

    when(() => mockCallKitService.initialize()).thenAnswer((_) async => {});
    when(
      () => mockCallKitService.eventStream,
    ).thenAnswer((_) => callKitEventController.stream);
    when(() => mockCallKitService.generateCallId()).thenReturn('test-call-id');
    when(
      () => mockCallKitService.showIncomingCall(
        callId: any(named: 'callId'),
        callerId: any(named: 'callerId'),
        callerName: any(named: 'callerName'),
        callerAvatar: any(named: 'callerAvatar'),
        isVideo: any(named: 'isVideo'),
      ),
    ).thenAnswer((_) async => {});
    when(
      () => mockCallKitService.startOutgoingCall(
        callId: any(named: 'callId'),
        calleeId: any(named: 'calleeId'),
        calleeName: any(named: 'calleeName'),
        calleeAvatar: any(named: 'calleeAvatar'),
        isVideo: any(named: 'isVideo'),
      ),
    ).thenAnswer((_) async => {});
    when(() => mockCallKitService.endCall(any())).thenAnswer((_) async => {});

    when(
      () => mockTencentService.eventStream,
    ).thenAnswer((_) => tencentEventController.stream);
    when(
      () => mockTencentService.call(
        userId: any(named: 'userId'),
        isVideo: any(named: 'isVideo'),
      ),
    ).thenAnswer((_) async => {});
    when(() => mockTencentService.acceptCall()).thenAnswer((_) async => {});
    when(() => mockTencentService.rejectCall()).thenAnswer((_) async => {});
    when(() => mockTencentService.hangup()).thenAnswer((_) async => {});
    when(
      () => mockTencentService.setMicMute(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockTencentService.setSpeaker(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockTencentService.setVideoMute(any()),
    ).thenAnswer((_) async => {});

    callBloc = CallBloc(mockCallKitService, mockTencentService);
  });

  tearDown(() {
    callBloc.close();
    callKitEventController.close();
    tencentEventController.close();
  });

  group('CallBloc - Initial State', () {
    test('initial state has correct default values', () {
      expect(callBloc.state.currentCall, null);
      expect(callBloc.state.isMuted, false);
      expect(callBloc.state.isSpeakerOn, false);
      expect(callBloc.state.isVideoEnabled, false);
      expect(callBloc.state.callDuration, 0);
      expect(callBloc.state.isLoading, false);
      expect(callBloc.state.error, null);
      expect(callBloc.state.hasActiveCall, false);
      expect(callBloc.state.isInCall, false);
    });
  });

  group('CallBloc - Initialized Event', () {
    blocTest<CallBloc, CallState>(
      'initializes CallKit service',
      build: () => callBloc,
      act: (bloc) => bloc.add(const CallEvent.initEvent()),
      verify: (_) {
        verify(() => mockCallKitService.initialize()).called(1);
      },
    );

    blocTest<CallBloc, CallState>(
      'subscribes to CallKit event stream',
      build: () => callBloc,
      act: (bloc) => bloc.add(const CallEvent.initEvent()),
      verify: (_) {
        verify(() => mockCallKitService.eventStream).called(1);
      },
    );
  });

  group('CallBloc - MakeCall Event', () {
    blocTest<CallBloc, CallState>(
      'emits state with outgoing call',
      build: () => callBloc,
      act: (bloc) => bloc.add(
        const CallEvent.makeCall(
          calleeId: 'user123',
          calleeName: 'John Doe',
          calleeAvatar: null,
          callType: CallType.audio,
        ),
      ),
      expect: () => [
        predicate<CallState>(
          (state) =>
              state.currentCall != null &&
              state.currentCall!.status == CallStatus.outgoing &&
              state.currentCall!.callType == CallType.audio,
        ),
      ],
      verify: (_) {
        verify(
          () => mockCallKitService.startOutgoingCall(
            callId: any(named: 'callId'),
            calleeId: 'user123',
            calleeName: 'John Doe',
            calleeAvatar: null,
            isVideo: false,
          ),
        ).called(1);
        verify(
          () => mockTencentService.call(userId: 'user123', isVideo: false),
        ).called(1);
      },
    );

    blocTest<CallBloc, CallState>(
      'generates unique call ID',
      build: () => callBloc,
      act: (bloc) => bloc.add(
        const CallEvent.makeCall(
          calleeId: 'user123',
          calleeName: 'John Doe',
          callType: CallType.audio,
        ),
      ),
      verify: (_) {
        verify(() => mockCallKitService.generateCallId()).called(1);
      },
    );

    blocTest<CallBloc, CallState>(
      'makes video call when callType is video',
      build: () => callBloc,
      act: (bloc) => bloc.add(
        const CallEvent.makeCall(
          calleeId: 'user123',
          calleeName: 'John Doe',
          callType: CallType.video,
        ),
      ),
      verify: (_) {
        verify(
          () => mockCallKitService.startOutgoingCall(
            callId: any(named: 'callId'),
            calleeId: any(named: 'calleeId'),
            calleeName: any(named: 'calleeName'),
            calleeAvatar: any(named: 'calleeAvatar'),
            isVideo: true,
          ),
        ).called(1);
        verify(
          () => mockTencentService.call(
            userId: any(named: 'userId'),
            isVideo: true,
          ),
        ).called(1);
      },
    );

    blocTest<CallBloc, CallState>(
      'handles error when making call fails',
      build: () {
        when(
          () => mockCallKitService.startOutgoingCall(
            callId: any(named: 'callId'),
            calleeId: any(named: 'calleeId'),
            calleeName: any(named: 'calleeName'),
            calleeAvatar: any(named: 'calleeAvatar'),
            isVideo: any(named: 'isVideo'),
          ),
        ).thenThrow(Exception('Call failed'));
        return callBloc;
      },
      act: (bloc) => bloc.add(
        const CallEvent.makeCall(
          calleeId: 'user123',
          calleeName: 'John Doe',
          callType: CallType.audio,
        ),
      ),
      expect: () => [
        predicate<CallState>(
          (state) =>
              state.currentCall != null &&
              state.currentCall!.status == CallStatus.outgoing,
        ),
        predicate<CallState>(
          (state) =>
              state.error != null && state.error!.contains('Call failed'),
        ),
      ],
    );
  });

  group('CallBloc - ReceiveCall Event', () {
    blocTest<CallBloc, CallState>(
      'emits state with incoming call',
      build: () => callBloc,
      act: (bloc) => bloc.add(
        const CallEvent.receiveCall(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callerAvatar: null,
          callType: CallType.audio,
        ),
      ),
      expect: () => [
        predicate<CallState>(
          (state) =>
              state.currentCall != null &&
              state.currentCall!.callId == 'call123' &&
              state.currentCall!.callerId == 'user456' &&
              state.currentCall!.callerName == 'Jane Smith' &&
              state.currentCall!.status == CallStatus.incoming,
        ),
      ],
      verify: (_) {
        verify(
          () => mockCallKitService.showIncomingCall(
            callId: 'call123',
            callerId: 'user456',
            callerName: 'Jane Smith',
            callerAvatar: null,
            isVideo: false,
          ),
        ).called(1);
      },
    );

    blocTest<CallBloc, CallState>(
      'shows video call UI for incoming video call',
      build: () => callBloc,
      act: (bloc) => bloc.add(
        const CallEvent.receiveCall(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.video,
        ),
      ),
      verify: (_) {
        verify(
          () => mockCallKitService.showIncomingCall(
            callId: any(named: 'callId'),
            callerId: any(named: 'callerId'),
            callerName: any(named: 'callerName'),
            callerAvatar: any(named: 'callerAvatar'),
            isVideo: true,
          ),
        ).called(1);
      },
    );

    blocTest<CallBloc, CallState>(
      'handles error when showing incoming call fails',
      build: () {
        when(
          () => mockCallKitService.showIncomingCall(
            callId: any(named: 'callId'),
            callerId: any(named: 'callerId'),
            callerName: any(named: 'callerName'),
            callerAvatar: any(named: 'callerAvatar'),
            isVideo: any(named: 'isVideo'),
          ),
        ).thenThrow(Exception('Show call failed'));
        return callBloc;
      },
      act: (bloc) => bloc.add(
        const CallEvent.receiveCall(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
        ),
      ),
      expect: () => [
        predicate<CallState>((state) => state.currentCall != null),
        predicate<CallState>((state) => state.error != null),
      ],
    );
  });

  group('CallBloc - AcceptCall Event', () {
    blocTest<CallBloc, CallState>(
      'transitions from incoming to connecting',
      build: () => callBloc,
      seed: () => CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.incoming,
          timestamp: DateTime.now(),
        ),
      ),
      act: (bloc) => bloc.add(const CallEvent.acceptCall()),
      expect: () => [
        predicate<CallState>(
          (state) => state.currentCall!.status == CallStatus.connecting,
        ),
      ],
      verify: (_) {
        verify(() => mockTencentService.acceptCall()).called(1);
      },
    );

    blocTest<CallBloc, CallState>(
      'does nothing when no active call',
      build: () => callBloc,
      act: (bloc) => bloc.add(const CallEvent.acceptCall()),
      expect: () => [],
    );
  });

  group('CallBloc - DeclineCall Event', () {
    blocTest<CallBloc, CallState>(
      'ends call and updates status to declined',
      build: () => callBloc,
      seed: () => CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.incoming,
          timestamp: DateTime.now(),
        ),
      ),
      act: (bloc) => bloc.add(const CallEvent.declineCall()),
      wait: const Duration(milliseconds: 600),
      expect: () => [
        predicate<CallState>(
          (state) => state.currentCall!.status == CallStatus.declined,
        ),
        predicate<CallState>((state) => state.currentCall == null),
      ],
      verify: (_) {
        verify(() => mockCallKitService.endCall('call123')).called(1);
        verify(() => mockTencentService.rejectCall()).called(1);
      },
    );

    blocTest<CallBloc, CallState>(
      'does nothing when no active call',
      build: () => callBloc,
      act: (bloc) => bloc.add(const CallEvent.declineCall()),
      expect: () => [],
    );
  });

  group('CallBloc - EndCall Event', () {
    blocTest<CallBloc, CallState>(
      'ends active call and clears state',
      build: () => callBloc,
      seed: () => CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.connected,
          timestamp: DateTime.now(),
        ),
        callDuration: 120,
      ),
      act: (bloc) => bloc.add(const CallEvent.endCall()),
      wait: const Duration(milliseconds: 1200),
      expect: () => [
        predicate<CallState>(
          (state) =>
              state.currentCall!.status == CallStatus.ended &&
              state.currentCall!.duration == 120,
        ),
        const CallState(),
      ],
      verify: (_) {
        verify(() => mockCallKitService.endCall('call123')).called(1);
        verify(() => mockTencentService.hangup()).called(1);
      },
    );

    blocTest<CallBloc, CallState>(
      'does nothing when no active call',
      build: () => callBloc,
      act: (bloc) => bloc.add(const CallEvent.endCall()),
      expect: () => [],
    );
  });

  group('CallBloc - Toggle Actions', () {
    blocTest<CallBloc, CallState>(
      'toggles mute state',
      build: () => callBloc,
      act: (bloc) {
        bloc.add(const CallEvent.toggleMute());
        bloc.add(const CallEvent.toggleMute());
      },
      expect: () => [
        predicate<CallState>((state) => state.isMuted == true),
        predicate<CallState>((state) => state.isMuted == false),
      ],
      verify: (_) {
        verify(() => mockTencentService.setMicMute(true)).called(1);
        verify(() => mockTencentService.setMicMute(false)).called(1);
      },
    );

    blocTest<CallBloc, CallState>(
      'toggles speaker state',
      build: () => callBloc,
      act: (bloc) {
        bloc.add(const CallEvent.toggleSpeaker());
        bloc.add(const CallEvent.toggleSpeaker());
      },
      expect: () => [
        predicate<CallState>((state) => state.isSpeakerOn == true),
        predicate<CallState>((state) => state.isSpeakerOn == false),
      ],
      verify: (_) {
        verify(() => mockTencentService.setSpeaker(true)).called(1);
        verify(() => mockTencentService.setSpeaker(false)).called(1);
      },
    );

    blocTest<CallBloc, CallState>(
      'toggles video state only for video calls',
      build: () => callBloc,
      seed: () => CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.video,
          status: CallStatus.connected,
          timestamp: DateTime.now(),
        ),
      ),
      act: (bloc) {
        bloc.add(const CallEvent.toggleVideo());
        bloc.add(const CallEvent.toggleVideo());
      },
      expect: () => [
        predicate<CallState>((state) => state.isVideoEnabled == true),
        predicate<CallState>((state) => state.isVideoEnabled == false),
      ],
      verify: (_) {
        verify(() => mockTencentService.setVideoMute(true)).called(1);
        verify(() => mockTencentService.setVideoMute(false)).called(1);
      },
    );

    blocTest<CallBloc, CallState>(
      'does not toggle video for audio calls',
      build: () => callBloc,
      seed: () => CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.connected,
          timestamp: DateTime.now(),
        ),
      ),
      act: (bloc) => bloc.add(const CallEvent.toggleVideo()),
      expect: () => [],
    );
  });

  group('CallBloc - UpdateCallStatus Event', () {
    blocTest<CallBloc, CallState>(
      'updates call status',
      build: () => callBloc,
      seed: () => CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.connecting,
          timestamp: DateTime.now(),
        ),
      ),
      act: (bloc) =>
          bloc.add(const CallEvent.updateCallStatus(CallStatus.connected)),
      expect: () => [
        predicate<CallState>(
          (state) => state.currentCall!.status == CallStatus.connected,
        ),
      ],
    );

    blocTest<CallBloc, CallState>(
      'does nothing when no active call',
      build: () => callBloc,
      act: (bloc) =>
          bloc.add(const CallEvent.updateCallStatus(CallStatus.connected)),
      expect: () => [],
    );
  });

  group('CallBloc - UpdateDuration Event', () {
    blocTest<CallBloc, CallState>(
      'updates call duration',
      build: () => callBloc,
      act: (bloc) {
        bloc.add(const CallEvent.updateDuration(30));
        bloc.add(const CallEvent.updateDuration(60));
      },
      expect: () => [
        predicate<CallState>((state) => state.callDuration == 30),
        predicate<CallState>((state) => state.callDuration == 60),
      ],
    );
  });

  group('CallBloc - HandleCallKitEvent', () {
    blocTest<CallBloc, CallState>(
      'handles CallKitEventAccepted',
      build: () => callBloc,
      seed: () => CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.incoming,
          timestamp: DateTime.now(),
        ),
      ),
      act: (bloc) => bloc.add(
        const CallEvent.handleCallKitEvent(CallKitEventAccepted(null)),
      ),
      expect: () => [
        predicate<CallState>(
          (state) => state.currentCall!.status == CallStatus.connecting,
        ),
      ],
      verify: (_) {
        verify(() => mockTencentService.acceptCall()).called(1);
      },
    );

    blocTest<CallBloc, CallState>(
      'handles CallKitEventDeclined',
      build: () => callBloc,
      seed: () => CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.incoming,
          timestamp: DateTime.now(),
        ),
      ),
      act: (bloc) => bloc.add(
        const CallEvent.handleCallKitEvent(CallKitEventDeclined(null)),
      ),
      wait: const Duration(milliseconds: 600),
      expect: () => [
        predicate<CallState>(
          (state) => state.currentCall!.status == CallStatus.declined,
        ),
        predicate<CallState>((state) => state.currentCall == null),
      ],
    );

    blocTest<CallBloc, CallState>(
      'handles CallKitEventEnded',
      build: () => callBloc,
      seed: () => CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.connected,
          timestamp: DateTime.now(),
        ),
      ),
      act: (bloc) =>
          bloc.add(const CallEvent.handleCallKitEvent(CallKitEventEnded(null))),
      wait: const Duration(milliseconds: 1200),
      expect: () => [
        predicate<CallState>(
          (state) => state.currentCall!.status == CallStatus.ended,
        ),
        const CallState(),
      ],
    );

    blocTest<CallBloc, CallState>(
      'handles CallKitEventTimeout',
      build: () => callBloc,
      seed: () => CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.incoming,
          timestamp: DateTime.now(),
        ),
      ),
      act: (bloc) => bloc.add(
        const CallEvent.handleCallKitEvent(CallKitEventTimeout(null)),
      ),
      wait: const Duration(milliseconds: 600),
      expect: () => [
        predicate<CallState>(
          (state) => state.currentCall!.status == CallStatus.missed,
        ),
        predicate<CallState>((state) => state.currentCall == null),
      ],
    );

    blocTest<CallBloc, CallState>(
      'handles CallKitEventMute',
      build: () => callBloc,
      act: (bloc) =>
          bloc.add(const CallEvent.handleCallKitEvent(CallKitEventMute(null))),
      expect: () => [predicate<CallState>((state) => state.isMuted == true)],
    );
  });

  group('CallBloc - State Helpers', () {
    test('hasActiveCall returns true for active statuses', () {
      final state1 = CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.connected,
          timestamp: DateTime.now(),
        ),
      );
      expect(state1.hasActiveCall, true);

      final state2 = CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.incoming,
          timestamp: DateTime.now(),
        ),
      );
      expect(state2.hasActiveCall, true);

      final state3 = CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.ended,
          timestamp: DateTime.now(),
        ),
      );
      expect(state3.hasActiveCall, false);
    });

    test('isInCall returns true only when connected', () {
      final state1 = CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.connected,
          timestamp: DateTime.now(),
        ),
      );
      expect(state1.isInCall, true);

      final state2 = CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.connecting,
          timestamp: DateTime.now(),
        ),
      );
      expect(state2.isInCall, false);
    });

    test('isIncoming returns true only for incoming calls', () {
      final state = CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.incoming,
          timestamp: DateTime.now(),
        ),
      );
      expect(state.isIncoming, true);
    });

    test('isOutgoing returns true only for outgoing calls', () {
      final state = CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.outgoing,
          timestamp: DateTime.now(),
        ),
      );
      expect(state.isOutgoing, true);
    });
  });

  group('CallBloc - Edge Cases', () {
    blocTest<CallBloc, CallState>(
      'handles rapid accept and end',
      build: () => callBloc,
      seed: () => CallState(
        currentCall: CallModel(
          callId: 'call123',
          callerId: 'user456',
          callerName: 'Jane Smith',
          callType: CallType.audio,
          status: CallStatus.incoming,
          timestamp: DateTime.now(),
        ),
      ),
      act: (bloc) {
        bloc.add(const CallEvent.acceptCall());
        bloc.add(const CallEvent.endCall());
      },
      wait: const Duration(milliseconds: 1200),
      expect: () => [
        predicate<CallState>(
          (state) => state.currentCall!.status == CallStatus.connecting,
        ),
        predicate<CallState>(
          (state) => state.currentCall!.status == CallStatus.ended,
        ),
        const CallState(),
      ],
      verify: (_) {
        verify(() => mockTencentService.acceptCall()).called(1);
        verify(() => mockTencentService.hangup()).called(1);
      },
    );

    blocTest<CallBloc, CallState>(
      'handles multiple toggle events quickly',
      build: () => callBloc,
      act: (bloc) {
        for (var i = 0; i < 10; i++) {
          bloc.add(const CallEvent.toggleMute());
        }
      },
      expect: () => List.generate(
        10,
        (i) => predicate<CallState>((state) => state.isMuted == (i % 2 == 0)),
      ),
      verify: (_) {
        verify(() => mockTencentService.setMicMute(any())).called(10);
      },
    );
  });
}

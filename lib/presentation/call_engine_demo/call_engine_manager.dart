import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';

/// Singleton manager for tencent_calls_engine
/// Handles call state, observers, and navigation for custom UI
class CallEngineManager {
  static final CallEngineManager _instance = CallEngineManager._internal();
  factory CallEngineManager() => _instance;
  CallEngineManager._internal();

  // Stream controllers for call events
  final _callStateController = StreamController<CallEngineState>.broadcast();
  Stream<CallEngineState> get callStateStream => _callStateController.stream;

  // Current state
  CallEngineState _currentState = CallEngineState.idle;
  CallEngineState get currentState => _currentState;

  // Call info
  String? _currentCallerId;
  String? get currentCallerId => _currentCallerId;
  
  List<String> _calleeIdList = [];
  List<String> get calleeIdList => _calleeIdList;
  
  TUICallMediaType _mediaType = TUICallMediaType.video;
  TUICallMediaType get mediaType => _mediaType;

  String? _currentRoomId;
  String? get currentRoomId => _currentRoomId;

  // Global navigator key for showing overlays
  GlobalKey<NavigatorState>? _navigatorKey;
  
  // Overlay entry for incoming call
  OverlayEntry? _incomingCallOverlay;

  // Video view IDs
  int? localViewId;
  int? remoteViewId;

  // Call duration timer
  Timer? _durationTimer;
  int _callDuration = 0;
  int get callDuration => _callDuration;

  // Control states
  bool _isMuted = false;
  bool get isMuted => _isMuted;

  // Float window state
  bool _isInFloatWindowMode = false;
  bool get isInFloatWindowMode => _isInFloatWindowMode;
  
  // Callback for when returning from float window - navigate to InCallDemoScreen
  VoidCallback? onReturnFromFloatWindow;

  bool _isSpeakerOn = true;
  bool get isSpeakerOn => _isSpeakerOn;

  bool _isCameraOn = true;
  bool get isCameraOn => _isCameraOn;

  bool _isFrontCamera = true;
  bool get isFrontCamera => _isFrontCamera;

  /// Initialize the manager with navigator key
  void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _setupObserver();
  }

  /// Setup TUICallEngine observer
  void _setupObserver() {
    TUICallEngine.instance.addObserver(TUICallObserver(
      onCallReceived: _onCallReceived,
      onCallBegin: _onCallBegin,
      onCallEnd: _onCallEnd,
      onCallCancelled: _onCallCancelled,
      onUserReject: _onUserReject,
      onUserNoResponse: _onUserNoResponse,
      onUserLineBusy: _onUserLineBusy,
      onUserJoin: _onUserJoin,
      onUserLeave: _onUserLeave,
      onUserVideoAvailable: _onUserVideoAvailable,
      onUserAudioAvailable: _onUserAudioAvailable,
      onError: _onError,
    ));
  }

  /// Make an outgoing call using TUICallEngine (custom UI, no built-in UIKit screens)
  /// This makes a REAL call that the receiver will see, but without showing UIKit's built-in UI
  Future<void> makeCall({
    required String userId,
    required TUICallMediaType mediaType,
    TUICallParams? params,
  }) async {
    _currentCallerId = userId;
    _calleeIdList = [userId];
    _mediaType = mediaType;
    _updateState(CallEngineState.outgoing);

    // Use TUICallEngine.instance.call() - this makes a REAL call without built-in UI
    // Unlike TUICallKit.instance.calls() which shows built-in screens
    final callParams = params ?? TUICallParams();
    
    debugPrint('📞 Making real call to $userId using TUICallEngine (custom UI)');

    try {
      final result = await TUICallEngine.instance.call(userId, mediaType, callParams);
      debugPrint('📞 Call initiated: code=${result.code}, message=${result.message}');
      
      if (result.code.isNotEmpty) {
        debugPrint('❌ Call failed: ${result.message}');
        _updateState(CallEngineState.error);
      }
      // If successful, the observer callbacks (onCallBegin, etc.) will handle state updates
    } catch (e) {
      debugPrint('❌ Call error: $e');
      _updateState(CallEngineState.error);
    }
  }

  /// Make a group call using TUICallKit
  Future<void> makeGroupCall({
    required List<String> userIdList,
    required TUICallMediaType mediaType,
    String? groupId,
  }) async {
    _calleeIdList = userIdList;
    _mediaType = mediaType;
    _updateState(CallEngineState.outgoing);

    try {
      await TUICallKit.instance.calls(userIdList, mediaType);
    } catch (e) {
      debugPrint('Group call error: $e');
      _updateState(CallEngineState.error);
    }
  }

  /// Accept incoming call
  Future<TUIResult> acceptCall() async {
    _dismissIncomingOverlay();
    _updateState(CallEngineState.connecting);
    return await TUICallEngine.instance.accept();
  }

  /// Reject incoming call
  Future<TUIResult> rejectCall() async {
    _dismissIncomingOverlay();
    _updateState(CallEngineState.idle);
    return await TUICallEngine.instance.reject();
  }

  /// Hang up current call
  Future<TUIResult> hangup() async {
    _stopDurationTimer();
    _updateState(CallEngineState.idle);
    return await TUICallEngine.instance.hangup();
  }

  /// Toggle mute
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    if (_isMuted) {
      await TUICallEngine.instance.closeMicrophone();
    } else {
      await TUICallEngine.instance.openMicrophone();
    }
    _notifyStateChange();
  }

  /// Toggle speaker
  Future<void> toggleSpeaker() async {
    _isSpeakerOn = !_isSpeakerOn;
    await TUICallEngine.instance.selectAudioPlaybackDevice(
      _isSpeakerOn ? TUIAudioPlaybackDevice.speakerphone : TUIAudioPlaybackDevice.earpiece,
    );
    _notifyStateChange();
  }

  /// Toggle camera
  Future<void> toggleCamera() async {
    _isCameraOn = !_isCameraOn;
    if (_isCameraOn) {
      await TUICallEngine.instance.openCamera(
        _isFrontCamera ? TUICamera.front : TUICamera.back,
        localViewId ?? 0,
      );
    } else {
      await TUICallEngine.instance.closeCamera();
    }
    _notifyStateChange();
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    _isFrontCamera = !_isFrontCamera;
    await TUICallEngine.instance.switchCamera(
      _isFrontCamera ? TUICamera.front : TUICamera.back,
    );
    _notifyStateChange();
  }

  /// Open local camera with view ID
  Future<void> openCamera(int viewId) async {
    localViewId = viewId;
    await TUICallEngine.instance.openCamera(
      _isFrontCamera ? TUICamera.front : TUICamera.back,
      viewId,
    );
  }

  /// Start remote view
  Future<void> startRemoteView(String userId, int viewId) async {
    remoteViewId = viewId;
    await TUICallEngine.instance.startRemoteView(
      userId,
      viewId,
    );
  }

  /// Enter float window mode
  void enterFloatWindowMode(VoidCallback? onReturn) {
    _isInFloatWindowMode = true;
    onReturnFromFloatWindow = onReturn;
    debugPrint('📱 CallEngineManager: Entered float window mode');
  }

  /// Exit float window mode and optionally trigger callback
  void exitFloatWindowMode({bool triggerCallback = true}) {
    debugPrint('📱 CallEngineManager: Exiting float window mode, triggerCallback=$triggerCallback');
    _isInFloatWindowMode = false;
    if (triggerCallback && onReturnFromFloatWindow != null) {
      onReturnFromFloatWindow!();
    }
    onReturnFromFloatWindow = null;
  }

  // Observer callbacks
  void _onCallReceived(
    String callerId,
    List<String> calleeIdList,
    String? groupId,
    TUICallMediaType callMediaType,
    String? userData,
  ) {
    _currentCallerId = callerId;
    _calleeIdList = calleeIdList;
    _mediaType = callMediaType;
    _updateState(CallEngineState.incoming);
    _showIncomingCallOverlay();
  }

  void _onCallBegin(
    TUIRoomId roomId,
    TUICallMediaType callMediaType,
    TUICallRole callRole,
  ) {
    _currentRoomId = roomId.intRoomId.toString();
    _updateState(CallEngineState.connected);
    _startDurationTimer();
  }

  void _onCallEnd(
    TUIRoomId roomId,
    TUICallMediaType callMediaType,
    TUICallRole callRole,
    double totalTime,
  ) {
    _stopDurationTimer();
    _callDuration = totalTime.toInt();
    _updateState(CallEngineState.ended);
    _resetCallInfo();
  }

  void _onCallCancelled(String callerId) {
    _dismissIncomingOverlay();
    _updateState(CallEngineState.cancelled);
    _resetCallInfo();
  }

  void _onUserReject(String userId) {
    _updateState(CallEngineState.rejected);
    _resetCallInfo();
  }

  void _onUserNoResponse(String userId) {
    _updateState(CallEngineState.noResponse);
    _resetCallInfo();
  }

  void _onUserLineBusy(String userId) {
    _updateState(CallEngineState.busy);
    _resetCallInfo();
  }

  void _onUserJoin(String userId) {
    _notifyStateChange();
  }

  void _onUserLeave(String userId) {
    _notifyStateChange();
  }

  void _onUserVideoAvailable(String userId, bool isVideoAvailable) {
    _notifyStateChange();
  }

  void _onUserAudioAvailable(String userId, bool isAudioAvailable) {
    _notifyStateChange();
  }

  void _onError(int code, String message) {
    debugPrint('CallEngine Error: $code - $message');
    
    // Ignore non-critical audio errors (common on simulator)
    // These errors don't mean the call failed, just audio hardware issues
    if (_isNonCriticalAudioError(code, message)) {
      debugPrint('⚠️ Ignoring non-critical audio error (likely simulator)');
      return; // Don't change state to error
    }
    
    _updateState(CallEngineState.error);
  }

  /// Check if error is a non-critical audio error that shouldn't end the call
  bool _isNonCriticalAudioError(int code, String message) {
    // Audio hardware errors on simulator
    if (message.contains('AudioUnit') || 
        message.contains('audio') ||
        message.contains('Audio')) {
      return true;
    }
    // Known non-critical error codes
    if (code == -1104 || code == -1) {
      return true;
    }
    return false;
  }

  // Show incoming call overlay
  void _showIncomingCallOverlay() {
    if (_navigatorKey?.currentState == null) return;

    final overlay = _navigatorKey!.currentState!.overlay;
    if (overlay == null) return;

    _incomingCallOverlay = OverlayEntry(
      builder: (context) => _IncomingCallOverlayWidget(
        callerId: _currentCallerId ?? 'Unknown',
        mediaType: _mediaType,
        onAccept: () {
          acceptCall();
          // Navigate to in-call screen
          _navigatorKey?.currentState?.pushNamed('/incall_demo');
        },
        onReject: rejectCall,
      ),
    );

    overlay.insert(_incomingCallOverlay!);
  }

  void _dismissIncomingOverlay() {
    _incomingCallOverlay?.remove();
    _incomingCallOverlay = null;
  }

  void _updateState(CallEngineState state) {
    _currentState = state;
    _callStateController.add(state);
  }

  void _notifyStateChange() {
    _callStateController.add(_currentState);
  }

  void _startDurationTimer() {
    _callDuration = 0;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDuration++;
      _notifyStateChange();
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void _resetCallInfo() {
    _isMuted = false;
    _isSpeakerOn = true;
    _isCameraOn = true;
    _isFrontCamera = true;
    localViewId = null;
    remoteViewId = null;
    Future.delayed(const Duration(seconds: 2), () {
      if (_currentState != CallEngineState.incoming &&
          _currentState != CallEngineState.outgoing &&
          _currentState != CallEngineState.connecting &&
          _currentState != CallEngineState.connected) {
        _updateState(CallEngineState.idle);
      }
    });
  }

  void dispose() {
    _stopDurationTimer();
    _dismissIncomingOverlay();
    _callStateController.close();
  }
}

/// Call states for custom UI
enum CallEngineState {
  idle,
  incoming,
  outgoing,
  connecting,
  connected,
  ended,
  cancelled,
  rejected,
  noResponse,
  busy,
  error,
}

/// Incoming call overlay widget
class _IncomingCallOverlayWidget extends StatelessWidget {
  final String callerId;
  final TUICallMediaType mediaType;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _IncomingCallOverlayWidget({
    required this.callerId,
    required this.mediaType,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade800,
                Colors.deepPurple.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      mediaType == TUICallMediaType.video
                          ? Icons.videocam
                          : Icons.phone,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Incoming ${mediaType == TUICallMediaType.video ? 'Video' : 'Voice'} Call',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          callerId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reject button
                  _buildActionButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    label: 'Decline',
                    onTap: onReject,
                  ),
                  // Accept button
                  _buildActionButton(
                    icon: mediaType == TUICallMediaType.video
                        ? Icons.videocam
                        : Icons.call,
                    color: Colors.green,
                    label: 'Accept',
                    onTap: onAccept,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}


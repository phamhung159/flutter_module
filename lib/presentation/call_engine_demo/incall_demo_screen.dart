import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/data/services/native_float_window_service.dart';
import 'package:flutter_module/presentation/call_engine_demo/call_engine_manager.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';

/// In-call screen with local/remote video, controls, and float window
class InCallDemoScreen extends StatefulWidget {
  final String remoteUserId;
  final TUICallMediaType mediaType;

  const InCallDemoScreen({
    super.key,
    required this.remoteUserId,
    this.mediaType = TUICallMediaType.video,
  });

  @override
  State<InCallDemoScreen> createState() => _InCallDemoScreenState();
}

class _InCallDemoScreenState extends State<InCallDemoScreen> {
  final _callManager = CallEngineManager();
  late StreamSubscription<CallEngineState> _stateSubscription;

  // UI state
  bool _isControlsVisible = true;
  bool _isLocalViewLarge = false; // Toggle local/remote view size

  // Call state
  int _duration = 0;
  bool _hasNavigatedAway = false; // Guard to prevent double navigation
  

  @override
  void initState() {
    super.initState();

    _stateSubscription = _callManager.callStateStream.listen(_onStateChanged);

    // Auto-hide controls after 5 seconds
    _startControlsTimer();
  }

  Timer? _controlsTimer;

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  void _onStateChanged(CallEngineState state) {
    setState(() {
      _duration = _callManager.callDuration;
    });

    if (state == CallEngineState.ended ||
        state == CallEngineState.cancelled ||
        state == CallEngineState.error) {
      _showCallEndedMessage();
    }
  }

  void _showCallEndedMessage() {
    // Guard to prevent multiple navigation attempts
    if (_hasNavigatedAway) {
      return;
    }
    _hasNavigatedAway = true;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Call ended'),
        backgroundColor: Colors.grey.shade800,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () async {
      if (mounted) {
        final navigator = Navigator.of(context);
        final canPopResult = navigator.canPop();
        
        if (canPopResult) {
          navigator.pop();
        } else {
          // No previous route - dismiss Flutter module
          const channel = MethodChannel('com.ntq.FlutterToNative');
          try {
            await channel.invokeMethod('dismissFlutterModule');
          } catch (e) {
            debugPrint('Error dismissing Flutter module: $e');
          }
        }
      }
    });
  }

  void _hangup() async {
    // Only call hangup - navigation is handled by _showCallEndedMessage()
    // when state changes to ended (avoids double navigation)
    await _callManager.hangup();
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
    if (_isControlsVisible) {
      _startControlsTimer();
    }
  }

  void _toggleViewSize() {
    setState(() {
      _isLocalViewLarge = !_isLocalViewLarge;
    });
  }

  void _toggleFloatWindow() async {
    debugPrint('🖼️ InCallDemoScreen._toggleFloatWindow - using NativeFloatWindowService');
    
    // Use native float window instead of Flutter overlay
    final floatWindowService = NativeFloatWindowService();
    final success = await floatWindowService.showFloatWindow(
      userId: widget.remoteUserId,
      duration: _duration,
      isVideo: widget.mediaType == TUICallMediaType.video,
    );
    
    if (success) {
      // Store navigation callback in CallEngineManager
      _callManager.enterFloatWindowMode(() {
        // This will be called when user taps on the float window to return
      });
      
      if (mounted) {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          // Normal flow: InCallDemo was pushed from Home
          // Pop back to Home Flutter (float window stays visible)
          // User will press Back on Home to go to native
          navigator.pop();
        } else {
          // Came from float window tap (Home was replaced with InCallDemo)
          // Dismiss Flutter to go back to native with float window
          const channel = MethodChannel('com.ntq.FlutterToNative');
          try {
            await channel.invokeMethod('dismissFlutterModule');
          } catch (e) {
            debugPrint('Error dismissing Flutter module: $e');
          }
        }
      }
    } else {
      // Fallback to Flutter overlay if native fails
      debugPrint('⚠️ Native float window failed, falling back to Flutter overlay');
      _callManager.enterFloatWindowMode(() {});
      if (mounted) {
        _showFloatOverlay();
        Navigator.of(context).pop();
      }
    }
  }
  
  void _showFloatOverlay() {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => _FloatCallOverlay(
        remoteUserId: widget.remoteUserId,
        duration: _duration,
        onTap: () {
          // Remove overlay and navigate back to InCallDemoScreen
          entry.remove();
          _callManager.exitFloatWindowMode(triggerCallback: false);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InCallDemoScreen(
                remoteUserId: widget.remoteUserId,
                mediaType: widget.mediaType,
              ),
            ),
          );
        },
        onClose: () {
          // End call and remove overlay
          entry.remove();
          _callManager.exitFloatWindowMode(triggerCallback: false);
          _callManager.hangup();
        },
      ),
    );
    
    overlay.insert(entry);
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    _controlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main video view (remote or local based on toggle)
            _buildMainVideoView(),

            // Small video view (PiP style)
            _buildPipVideoView(),

            // Top overlay (call info)
            if (_isControlsVisible) _buildTopOverlay(),

            // Bottom controls
            if (_isControlsVisible) _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainVideoView() {
    if (widget.mediaType != TUICallMediaType.video) {
      // Audio call - show avatar
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade700,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple.shade300,
                ),
                child: Center(
                  child: Text(
                    _getInitials(widget.remoteUserId),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.remoteUserId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Video call - show video placeholder (in production, use native video view)
    return Container(
      color: Colors.grey.shade900,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.shade400,
              ),
              child: Center(
                child: Text(
                  _getInitials(widget.remoteUserId),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.remoteUserId,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Video Call Active',
                    style: TextStyle(
                      color: Colors.green.shade100,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipVideoView() {
    if (widget.mediaType != TUICallMediaType.video) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      right: 16,
      child: GestureDetector(
        onTap: _toggleViewSize,
        child: Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white30, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Local video placeholder
              Container(
                color: Colors.grey.shade800,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.white.withOpacity(0.5),
                        size: 40,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Switch icon
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.swap_horiz,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Back button
            
            const SizedBox(width: 12),
            // Call info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.remoteUserId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Float window button
            IconButton(
              icon: const Icon(
                Icons.picture_in_picture_alt,
                color: Colors.white,
              ),
              onPressed: _toggleFloatWindow,
              tooltip: 'Float Window',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: 20,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 30,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Control buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute button
                _buildControlButton(
                  icon: _callManager.isMuted ? Icons.mic_off : Icons.mic,
                  label: 'Mute',
                  isActive: _callManager.isMuted,
                  onTap: () {
                    _callManager.toggleMute();
                    setState(() {});
                  },
                ),
                // Speaker button
                _buildControlButton(
                  icon: _callManager.isSpeakerOn
                      ? Icons.volume_up
                      : Icons.volume_down,
                  label: 'Speaker',
                  isActive: _callManager.isSpeakerOn,
                  onTap: () {
                    _callManager.toggleSpeaker();
                    setState(() {});
                  },
                ),
                // Camera button (only for video calls)
                if (widget.mediaType == TUICallMediaType.video)
                  _buildControlButton(
                    icon: _callManager.isCameraOn
                        ? Icons.videocam
                        : Icons.videocam_off,
                    label: 'Camera',
                    isActive: _callManager.isCameraOn,
                    onTap: () {
                      _callManager.toggleCamera();
                      setState(() {});
                    },
                  ),
                // Switch camera button (only for video calls)
                if (widget.mediaType == TUICallMediaType.video)
                  _buildControlButton(
                    icon: Icons.flip_camera_ios,
                    label: 'Flip',
                    isActive: false,
                    onTap: () {
                      _callManager.switchCamera();
                      setState(() {});
                    },
                  ),
              ],
            ),
            const SizedBox(height: 30),
            // End call button
            GestureDetector(
              onTap: _hangup,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'End Call',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
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
              color: isActive ? Colors.white : Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
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

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }
    return name.toUpperCase();
  }
}

/// Floating call overlay widget - shows a mini view of the ongoing call
class _FloatCallOverlay extends StatefulWidget {
  final String remoteUserId;
  final int duration;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _FloatCallOverlay({
    required this.remoteUserId,
    required this.duration,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<_FloatCallOverlay> createState() => _FloatCallOverlayState();
}

class _FloatCallOverlayState extends State<_FloatCallOverlay> {
  // Position of the overlay
  double _top = 100;
  double _left = 20;
  
  // Call duration tracking
  late int _duration;
  Timer? _durationTimer;
  final _callManager = CallEngineManager();

  @override
  void initState() {
    super.initState();
    _duration = widget.duration;
    // Update duration every second
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _duration = _callManager.callDuration;
        });
      }
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _top,
      left: _left,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _top += details.delta.dy;
            _left += details.delta.dx;
            // Keep within screen bounds
            _top = _top.clamp(50, MediaQuery.of(context).size.height - 150);
            _left = _left.clamp(0, MediaQuery.of(context).size.width - 140);
          });
        },
        onTap: widget.onTap,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 140,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade800,
                  Colors.deepPurple.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Main content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white24,
                            child: Text(
                              widget.remoteUserId.isNotEmpty 
                                  ? widget.remoteUserId[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.remoteUserId,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDuration(_duration),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.videocam,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Close button
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


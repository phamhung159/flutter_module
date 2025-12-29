import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_module/presentation/call_engine_demo/call_engine_manager.dart';
import 'package:flutter_module/presentation/call_engine_demo/incall_demo_screen.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';

/// Outgoing call screen using tencent_calls_engine
class OutgoingDemoScreen extends StatefulWidget {
  final String calleeId;
  final String? calleeName;
  final TUICallMediaType mediaType;

  const OutgoingDemoScreen({
    super.key,
    required this.calleeId,
    this.calleeName,
    this.mediaType = TUICallMediaType.video,
  });

  @override
  State<OutgoingDemoScreen> createState() => _OutgoingDemoScreenState();
}

class _OutgoingDemoScreenState extends State<OutgoingDemoScreen>
    with SingleTickerProviderStateMixin {
  final _callManager = CallEngineManager();
  late StreamSubscription<CallEngineState> _stateSubscription;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  CallEngineState _currentState = CallEngineState.outgoing;
  bool _hasNavigated = false; // Guard to prevent double navigation

  @override
  void initState() {
    super.initState();

    // Setup pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Listen to call state changes
    _stateSubscription = _callManager.callStateStream.listen(_onStateChanged);

    // Make the call
    _makeCall();
  }

  void _makeCall() async {
    await _callManager.makeCall(
      userId: widget.calleeId,
      mediaType: widget.mediaType,
    );
  }

  void _onStateChanged(CallEngineState state) {
    setState(() {
      _currentState = state;
    });

    // Navigate to in-call screen when connected
    if (state == CallEngineState.connected) {
      _navigateToInCall();
    }

    // Go back on call end/cancel/reject
    if (state == CallEngineState.ended ||
        state == CallEngineState.cancelled ||
        state == CallEngineState.rejected ||
        state == CallEngineState.noResponse ||
        state == CallEngineState.busy ||
        state == CallEngineState.error) {
      _showEndMessage(state);
    }
  }

  void _navigateToInCall() {
    // Guard to prevent double navigation (state change may fire multiple times)
    if (_hasNavigated) {
      return;
    }
    _hasNavigated = true;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => InCallDemoScreen(
          remoteUserId: widget.calleeId,
          mediaType: widget.mediaType,
        ),
      ),
    );
  }

  void _showEndMessage(CallEngineState state) {
    String message;
    switch (state) {
      case CallEngineState.rejected:
        message = 'Call was rejected';
        break;
      case CallEngineState.noResponse:
        message = 'No response';
        break;
      case CallEngineState.busy:
        message = 'User is busy';
        break;
      case CallEngineState.cancelled:
        message = 'Call cancelled';
        break;
      case CallEngineState.error:
        message = 'Call failed';
        break;
      default:
        message = 'Call ended';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_hasNavigated) {
        _hasNavigated = true;
        Navigator.of(context).pop();
      }
    });
  }

  void _hangup() async {
    await _callManager.hangup();
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade700,
              Colors.deepPurple.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _hangup,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.mediaType == TUICallMediaType.video
                                ? Icons.videocam
                                : Icons.phone,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.mediaType == TUICallMediaType.video
                                ? 'Video Call'
                                : 'Voice Call',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Status text
              Text(
                _getStatusText(),
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              // Animated avatar
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.deepPurple.shade300,
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(
                                widget.calleeName ?? widget.calleeId,
                              ),
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Callee name
              Text(
                widget.calleeName ?? widget.calleeId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.calleeId,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),

              const Spacer(),

              // Calling animation dots
              _buildCallingAnimation(),

              const Spacer(),

              // Cancel button
              GestureDetector(
                onTap: _hangup,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red,
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
              const SizedBox(height: 12),
              const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallingAnimation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.3, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 200)),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(value),
              ),
            );
          },
        );
      }),
    );
  }

  String _getStatusText() {
    switch (_currentState) {
      case CallEngineState.outgoing:
        return 'Calling...';
      case CallEngineState.connecting:
        return 'Connecting...';
      case CallEngineState.connected:
        return 'Connected';
      default:
        return 'Calling...';
    }
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

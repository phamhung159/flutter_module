import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_module/app/di/injection.dart';
import 'package:flutter_module/data/models/call_dto.dart';
import 'package:flutter_module/main.dart';
import 'package:flutter_module/presentation/call/bloc/call_bloc.dart';
import 'package:flutter_module/repositories/models/call_model.dart';

class OutgoingScreen extends StatefulWidget {
  final Map<String, dynamic>? params;
  
  const OutgoingScreen({super.key, this.params});

  @override
  State<OutgoingScreen> createState() => _OutgoingScreenState();
}

class _OutgoingScreenState extends State<OutgoingScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CallBloc>(
      create: (context) {
        final bloc = getIt<CallBloc>()..add(const CallEvent.initEvent());
        
        // Initiate outgoing call if params provided
        if (widget.params != null) {
          final calleeId = widget.params!['calleeId'] as String?;
          final calleeName = widget.params!['calleeName'] as String?;
          final calleeAvatar = widget.params!['calleeAvatar'] as String?;
          final isVideo = widget.params!['isVideo'] as bool? ?? false;
          
          if (calleeId != null && calleeName != null) {
            bloc.add(CallEvent.makeCall(
              calleeId: calleeId,
              calleeName: calleeName,
              calleeAvatar: calleeAvatar,
              callType: isVideo ? CallType.video : CallType.audio,
            ));
          }
        }
        
        return bloc;
      },
      child: const _OutgoingView(),
    );
  }
}

class _OutgoingView extends StatelessWidget {
  const _OutgoingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: BlocConsumer<CallBloc, CallState>(
        listener: (context, state) {
          // If call connects, navigate to incall screen
          if (state.isInCall) {
            // Stay on same screen but show call controls
          }
          
          // Navigate back when call ends
          if (state.currentCall?.status == CallStatus.ended ||
              state.currentCall?.status == CallStatus.declined) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            });
          }
        },
        builder: (context, state) {
          final call = state.currentCall;
          
          if (call == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                
                // Call Status
                Text(
                  _getStatusText(call.status),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Loading indicator for outgoing/connecting
                if (call.status == CallStatus.outgoing ||
                    call.status == CallStatus.connecting)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                
                // Callee Info
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[800],
                  child: Text(
                    _getInitials(call.callerName),
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  call.callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Call type indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      call.callType == CallType.video
                          ? Icons.videocam
                          : Icons.phone,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      call.callType == CallType.video ? 'Video Call' : 'Voice Call',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),
                
                // Call Duration (only show when connected)
                if (state.isInCall)
                  Text(
                    _formatDuration(state.callDuration),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                
                const Spacer(),
                
                // Call Controls (only show when connected)
                if (state.isInCall) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CallControlButton(
                        icon: state.isMuted ? Icons.mic_off : Icons.mic,
                        label: 'Mute',
                        isActive: state.isMuted,
                        onTap: () {
                          context.read<CallBloc>().add(
                            const CallEvent.toggleMute(),
                          );
                        },
                      ),
                      
                      _CallControlButton(
                        icon: state.isSpeakerOn
                            ? Icons.volume_up
                            : Icons.volume_down,
                        label: 'Speaker',
                        isActive: state.isSpeakerOn,
                        onTap: () {
                          context.read<CallBloc>().add(
                            const CallEvent.toggleSpeaker(),
                          );
                        },
                      ),
                      
                      if (call.callType == CallType.video)
                        _CallControlButton(
                          icon: state.isVideoEnabled
                              ? Icons.videocam
                              : Icons.videocam_off,
                          label: 'Video',
                          isActive: state.isVideoEnabled,
                          onTap: () {
                            context.read<CallBloc>().add(
                              const CallEvent.toggleVideo(),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
                
                // End call button
                Center(
                  child: _ActionButton(
                    icon: Icons.call_end,
                    label: 'End Call',
                    color: Colors.red,
                    onTap: () {
                      _dismissFlutterModule();
                      context.read<CallBloc>().add(
                        const CallEvent.endCall(),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _dismissFlutterModule() async {
    try {
      await sendChannel.invokeMethod('dismissFlutterModule');
    } catch (e) {
      debugPrint('Error dismissing Flutter module: $e');
    }
  }

  String _getStatusText(CallStatus status) {
    switch (status) {
      case CallStatus.outgoing:
        return 'Calling...';
      case CallStatus.connecting:
        return 'Connecting...';
      case CallStatus.connected:
        return 'Connected';
      case CallStatus.ended:
        return 'Call ended';
      case CallStatus.declined:
        return 'Call declined';
      default:
        return '';
    }
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF1a1a1a) : Colors.white,
              size: 28,
            ),
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
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


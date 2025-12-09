import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_module/app/di/injection.dart';
import 'package:flutter_module/data/models/call_dto.dart';
import 'package:flutter_module/presentation/call/bloc/call_bloc.dart';
import 'package:flutter_module/repositories/models/call_model.dart';

class InCallScreen extends StatefulWidget {
  final Map<String, dynamic>? params;
  
  const InCallScreen({super.key, this.params});

  @override
  State<InCallScreen> createState() => _InCallScreenState();
}

class _InCallScreenState extends State<InCallScreen> {
  static const MethodChannel _channel = MethodChannel('com.ntq.FlutterToNative');
  
  Future<void> _dismissFlutterModule() async {
    try {
      await _channel.invokeMethod('dismissFlutterModule');
    } catch (e) {
      debugPrint('Error dismissing Flutter module: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CallBloc>(
      create: (context) {
        final bloc = getIt<CallBloc>()..add(const CallEvent.initEvent());
        
        if (widget.params != null) {
          final callId = widget.params!['callId'] as String?;
          final callerId = widget.params!['callerId'] as String?;
          final callerName = widget.params!['callerName'] as String?;
          final callerAvatar = widget.params!['callerAvatar'] as String?;
          final isVideo = widget.params!['isVideo'] as bool? ?? false;
          
          if (callId != null && callerId != null && callerName != null) {
            bloc.add(CallEvent.receiveCall(
              callId: callId,
              callerId: callerId,
              callerName: callerName,
              callerAvatar: callerAvatar,
              callType: isVideo ? CallType.video : CallType.audio,
            ));
          }
        }
        
        return bloc;
      },
      child: _InCallView(onDismiss: _dismissFlutterModule),
    );
  }
}

class _InCallView extends StatelessWidget {
  final VoidCallback onDismiss;
  
  const _InCallView({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: BlocConsumer<CallBloc, CallState>(
        listener: (context, state) {
          if (state.currentCall?.status == CallStatus.ended ||
              state.currentCall?.status == CallStatus.declined) {
            Future.delayed(const Duration(milliseconds: 500), () {
              onDismiss();
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
                
                // Caller Info
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: call.callerAvatar != null
                      ? NetworkImage(call.callerAvatar!)
                      : null,
                  child: call.callerAvatar == null
                      ? Text(
                          _getInitials(call.callerName),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
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
                
                // Action Buttons
                if (state.isIncoming) ...[
                  // Incoming call buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: Icons.call_end,
                        label: 'Decline',
                        color: Colors.red,
                        onTap: () {
                          context.read<CallBloc>().add(
                            const CallEvent.declineCall(),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.call,
                        label: 'Accept',
                        color: Colors.green,
                        onTap: () {
                          context.read<CallBloc>().add(
                            const CallEvent.acceptCall(),
                          );
                        },
                      ),
                    ],
                  ),
                ] else ...[
                  // End call button
                  Center(
                    child: _ActionButton(
                      icon: Icons.call_end,
                      label: 'End Call',
                      color: Colors.red,
                      onTap: () {
                        context.read<CallBloc>().add(
                          const CallEvent.endCall(),
                        );
                      },
                    ),
                  ),
                ],
                
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getStatusText(CallStatus status) {
    switch (status) {
      case CallStatus.incoming:
        return 'Incoming call...';
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
      case CallStatus.missed:
        return 'Missed call';
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


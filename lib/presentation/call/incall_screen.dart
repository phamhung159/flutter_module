import 'package:flutter/material.dart';
import 'package:flutter_module/data/services/native_float_window_service.dart';
import 'package:flutter_module/main.dart';

class InCallScreen extends StatefulWidget {
  final Map<String, dynamic>? params;

  const InCallScreen({super.key, this.params});

  @override
  State<InCallScreen> createState() => _InCallScreenState();
}

class _InCallScreenState extends State<InCallScreen> {
  final _floatWindowService = NativeFloatWindowService();
  int _callDuration = 0;
  bool _isVideo = false;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _parseParams();
  }

  void _parseParams() {
    if (widget.params != null) {
      _userId = widget.params!['userId'] as String? ?? 
                widget.params!['callerId'] as String? ?? 
                'User';
      _callDuration = widget.params!['duration'] as int? ?? 0;
      _isVideo = widget.params!['isVideo'] as bool? ?? false;
      
      // Check if coming from float window
      final fromFloatWindow = widget.params!['fromFloatWindow'] as bool? ?? false;
      if (fromFloatWindow) {
        debugPrint('📱 Returned from float window with duration: $_callDuration');
      }
    }
  }

  Future<void> _dismissFlutterModule() async {
    try {
      await sendChannel.invokeMethod('dismissFlutterModule');
    } catch (e) {
      debugPrint('Error dismissing Flutter module: $e');
    }
  }

  /// Show float window and go back to native
  Future<void> _showFloatWindowAndDismiss() async {
    final success = await _floatWindowService.showFloatWindow(
      userId: _userId.isNotEmpty ? _userId : 'User',
      duration: _callDuration,
      isVideo: _isVideo,
    );
    
    if (success) {
      debugPrint('🖼️ Float window shown, dismissing Flutter module');
      await _dismissFlutterModule();
    } else {
      debugPrint('⚠️ Failed to show float window');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to show float window')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('In Call', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _dismissFlutterModule,
        ),
        actions: [
          // Float Window Button
          IconButton(
            icon: const Icon(Icons.picture_in_picture_alt, color: Colors.white),
            tooltip: 'Float Window',
            onPressed: _showFloatWindowAndDismiss,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // User Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _userId.isNotEmpty ? _userId[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // User Name
            Text(
              _userId.isNotEmpty ? _userId : 'Unknown User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Call Status
            Text(
              _isVideo ? '📹 Video Call' : '📞 Audio Call',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            
            const Spacer(),
            
            // Float Window Button (Large)
            _buildFloatWindowButton(),
            
            const SizedBox(height: 40),
            
            // End Call Button
            _buildEndCallButton(),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatWindowButton() {
    return GestureDetector(
      onTap: _showFloatWindowAndDismiss,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_in_picture_alt,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Float Window',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: () async {
        // Hide float window if visible
        await _floatWindowService.hideFloatWindow();
        // Dismiss Flutter module
        await _dismissFlutterModule();
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red,
              blurRadius: 15,
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
    );
  }
}


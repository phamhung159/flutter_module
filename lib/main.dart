import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/data/services/callkit_service.dart';
import 'package:flutter_module/data/services/native_float_window_service.dart';
import 'package:flutter_module/presentation/call_engine_demo/call_engine_manager.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';
import 'app/routes/routes.dart';
import 'app/di/injection.dart';
import 'presentation/call/incall_screen.dart';
import 'presentation/home/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final MethodChannel sendChannel = MethodChannel('com.ntq.FlutterToNative');
final MethodChannel receiveChannel = MethodChannel('com.ntq.NativeToFlutter');
final MethodChannel navigationChannel = MethodChannel('flutter_module/navigation');

@pragma('vm:entry-point')
void main() async {
  runApp(await _mainWidget('/'));
}

@pragma('vm:entry-point')
Future<void> incall() async {
  runApp(await _mainWidget('/incall'));
}

// commit code
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // initialRoute: '/detail', set initRoute để test
    );
  }
}

Future<Widget> _mainWidget(String initialRoute) async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator(() {});
  final callKitService = getIt<CallKitService>();
  await callKitService.initialize();
  
  // Initialize float window service
  final floatWindowService = NativeFloatWindowService();

  callKitService.eventStream.listen((event) {
    if (event is CallKitEventAccepted) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        navigatorKey.currentState?.pushNamed('/incall', arguments: event.data);
      }
    }
  });
  
  // Listen for float window events
  floatWindowService.onFloatWindowTapped.listen((event) async {
    debugPrint('📱 Float window tapped - hiding float window and navigating to InCallDemoScreen');
    
    // Hide float window first
    await floatWindowService.hideFloatWindow();
    
    // Use pushNamed to KEEP Home in stack (so we can pop back to Home when call ends)
    navigatorKey.currentState?.pushNamed('/incall_demo', arguments: {
      'userId': event.userId,
      'duration': event.duration,
      'isVideo': event.isVideo,
      'fromFloatWindow': true,
    });
  });
  
  floatWindowService.onFloatWindowClosed.listen((_) async {
    debugPrint('📱 Float window close button pressed - ending call');
    // End the call when close button is pressed on float window
    final callManager = CallEngineManager();
    await callManager.hangup();
  });
  
  // Listen to call state changes to auto-hide float window when call ends
  final callManager = CallEngineManager();
  callManager.callStateStream.listen((state) async {
    debugPrint('📱 Call state changed: $state');
    
    // Hide float window when call ends (any end state)
    if (state == CallEngineState.ended ||
        state == CallEngineState.cancelled ||
        state == CallEngineState.rejected ||
        state == CallEngineState.noResponse ||
        state == CallEngineState.busy ||
        state == CallEngineState.error) {
      debugPrint('📱 Call ended - hiding float window');
      await floatWindowService.hideFloatWindow();
    }
  });
  
  receiveChannel.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'resetData':
        // Use pushNamedAndRemoveUntil to always go to Home and clear all routes
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
      default:
        return 'Unknown method';
    }
  });
  
  // Handle navigation from native (when float window tapped)
  navigationChannel.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'navigateToInCallScreen':
        final args = call.arguments as Map<dynamic, dynamic>?;
        debugPrint('📱 Native requested navigation to InCallDemoScreen: $args');
        
        // Hide float window first
        await floatWindowService.hideFloatWindow();
        
        // Use pushNamed to KEEP Home in stack (so we can pop back to Home when call ends)
        navigatorKey.currentState?.pushNamed('/incall_demo', arguments: {
          'userId': args?['userId'] ?? '',
          'duration': args?['duration'] ?? 0,
          'isVideo': args?['isVideo'] ?? false,
          'fromFloatWindow': true,
        });
        return true;
      default:
        return null;
    }
  });
  
  return MaterialApp(
    navigatorKey: navigatorKey,
    onGenerateRoute: AppRoutes.onGenerateRoute,
    navigatorObservers: [TUICallKit.navigatorObserver],
    home: initialRoute == '/' ? const HomeScreen() : InCallScreen(),
  );
}

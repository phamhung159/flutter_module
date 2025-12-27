import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/data/services/callkit_service.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';
import 'app/routes/routes.dart';
import 'app/di/injection.dart';
import 'presentation/call/incall_screen.dart';
import 'presentation/home/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final MethodChannel sendChannel = MethodChannel('com.ntq.FlutterToNative');
final MethodChannel receiveChannel = MethodChannel('com.ntq.NativeToFlutter');

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

  callKitService.eventStream.listen((event) {
    if (event is CallKitEventAccepted) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        navigatorKey.currentState?.pushNamed('/incall', arguments: event.data);
      }
    }
  });
  receiveChannel.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'resetData':
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      default:
        return 'Unknown method';
    }
  });
  return MaterialApp(
    navigatorKey: navigatorKey,
    onGenerateRoute: AppRoutes.onGenerateRoute,
    navigatorObservers: [TUICallKit.navigatorObserver],
    home: initialRoute == '/' ? const HomeScreen() : InCallScreen(),
  );
}

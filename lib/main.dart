import 'package:flutter/material.dart';
import 'package:flutter_module/data/services/callkit_service.dart';
import 'app/routes/routes.dart';
import 'app/di/injection.dart';
import 'presentation/call/incall_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
void main() async {
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

  runApp(const MyApp());
}

@pragma('vm:entry-point')
void incall() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator(() {});
  runApp(MaterialApp(home: InCallScreen()));
}

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

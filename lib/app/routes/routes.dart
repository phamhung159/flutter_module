import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';
import '../../presentation/detail_screen.dart';
import '../../presentation/form_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/call/incall_screen.dart';
import '../../presentation/call/outgoing_screen.dart';
import '../../presentation/call_engine_demo/incall_demo_screen.dart';

class AppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? "/");

    Map<String, dynamic> params = {};

    if (settings.arguments != null) {
      if (settings.arguments is Map<String, dynamic>) {
        params = settings.arguments as Map<String, dynamic>;
      }
    } else if (uri.queryParameters.containsKey("data")) {
      try {
        params =
            jsonDecode(uri.queryParameters["data"]!) as Map<String, dynamic>;
      } catch (e) {
        debugPrint("❌ JSON decode error: $e");
      }
    }

    debugPrint("➡️ route=${uri.path}, params=$params");

    switch (uri.path) {
      case "/":
        return MaterialPageRoute(builder: (_) => HomeScreen(params: params));
      case "/detail":
        return MaterialPageRoute(builder: (_) => DetailScreen());
      case "/form":
        return MaterialPageRoute(builder: (_) => FormScreen());
      case "/incall":
        return MaterialPageRoute(builder: (_) => InCallScreen(params: params));
      case "/incall_demo":
        // Route for InCallDemoScreen - used when returning from float window
        final userId = params['userId'] as String? ?? '';
        final isVideo = params['isVideo'] as bool? ?? true;
        return MaterialPageRoute(
          builder: (_) => InCallDemoScreen(
            remoteUserId: userId,
            mediaType: isVideo ? TUICallMediaType.video : TUICallMediaType.audio,
          ),
        );
      case "/outgoing":
        return MaterialPageRoute(
          builder: (_) => OutgoingScreen(params: params),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Unknown route"))),
        );
    }
  }
}

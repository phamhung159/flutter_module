import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_module/app/di/injection.dart';
import 'package:flutter_module/main.dart';
import 'package:flutter_module/presentation/call_engine_demo/call_engine_manager.dart';
import 'package:flutter_module/presentation/call_engine_demo/outgoing_demo_screen.dart';
import 'package:flutter_module/presentation/home/bloc/home_bloc.dart';
import 'package:flutter_module/presentation/lib/debug/generate_test_user_sig.dart';
import 'package:flutter_module/presentation/lib/src/observer_functions.dart';
import 'package:flutter_module/presentation/lib/src/settings/settings_config.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

import 'widgets/user_list_widget.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? params;
  const HomeScreen({super.key, this.params});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _dismissFlutterModule() async {
    try {
      await sendChannel.invokeMethod('dismissFlutterModule');
    } catch (e) {
      debugPrint('Error dismissing Flutter module: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _dismissFlutterModule,
        ),
        actions: [
          // TUICallKit (built-in UI) demo
          IconButton(
            icon: const Icon(Icons.phone),
            tooltip: 'TUICallKit Demo',
            onPressed: () {
              _login();
            },
          ),
          // Custom UI with tencent_calls_engine demo
          IconButton(
            icon: const Icon(Icons.video_call),
            tooltip: 'Custom Call Demo',
            onPressed: () {
              _startCustomCallDemo();
            },
          ),
        ],
      ),
      body: BlocProvider<HomeBloc>(
        create: (context) =>
            getIt<HomeBloc>()..add(const HomeEvent.initEvent()),
        child: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            // Error handling if needed
          },
          child: const UsersListWidget(),
        ),
      ),
    );
  }

  _login() async {
    final _userId = '123';
    final result = await TUICallKit.instance.login(
      GenerateTestUserSig.sdkAppId,
      _userId,
      GenerateTestUserSig.genTestSig(_userId),
    );
    if (result.code.isEmpty) {
      SettingsConfig.showBlurBackground = true;
      TUICallKit.instance.enableVirtualBackground(
        SettingsConfig.showBlurBackground,
      );
      SettingsConfig.showIncomingBanner = true;
      TUICallKit.instance.enableIncomingBanner(
        SettingsConfig.showIncomingBanner,
      );
      SettingsConfig.enableFloatWindow = true;
      TUICallKit.instance.enableFloatWindow(SettingsConfig.enableFloatWindow);

      setObserverFunction(callsEnginePlugin: TUICallEngine.instance);
      SettingsConfig.userId = _userId;
      final imInfo = await TencentImSDKPlugin.v2TIMManager.getUsersInfo(
        userIDList: [_userId],
      );
      // Set default nickname and avatar
      SettingsConfig.nickname = imInfo.data?[0].nickName ?? "";
      SettingsConfig.avatar = imInfo.data?[0].faceUrl ?? "";

      _call();
    }
  }

  _call() {
    TUICallKit.instance.calls(
      ['456'],
      TUICallMediaType.video,
      _createTUICallParams(),
    );
  }

  TUICallParams _createTUICallParams() {
    TUICallParams params = TUICallParams();
    if (SettingsConfig.intRoomId != 0) {
      params.roomId = TUIRoomId.intRoomId(intRoomId: SettingsConfig.intRoomId);
    } else if (SettingsConfig.strRoomId.isNotEmpty) {
      params.roomId = TUIRoomId.strRoomId(strRoomId: SettingsConfig.strRoomId);
    }
    params.timeout = SettingsConfig.timeout;
    params.offlinePushInfo = SettingsConfig.offlinePushInfo;
    params.userData = SettingsConfig.extendInfo;
    return params;
  }

  /// Start custom call demo using tencent_calls_engine
  _startCustomCallDemo() async {
    final userId = '123';
    final calleeId = '456';

    // Login first
    final result = await TUICallKit.instance.login(
      GenerateTestUserSig.sdkAppId,
      userId,
      GenerateTestUserSig.genTestSig(userId),
    );

    if (result.code.isEmpty) {
      // Initialize CallEngineManager with navigator key
      final navigatorKey = GlobalKey<NavigatorState>();
      CallEngineManager().init(navigatorKey);

      // Setup observer
      setObserverFunction(callsEnginePlugin: TUICallEngine.instance);
      SettingsConfig.userId = userId;

      // Navigate to OutgoingDemoScreen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OutgoingDemoScreen(
              calleeId: calleeId,
              calleeName: 'User $calleeId',
              mediaType: TUICallMediaType.video,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${result.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

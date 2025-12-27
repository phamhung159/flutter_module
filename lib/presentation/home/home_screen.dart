import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_module/app/di/injection.dart';
import 'package:flutter_module/main.dart';
import 'package:flutter_module/presentation/home/bloc/home_bloc.dart';
import 'package:flutter_module/presentation/lib/debug/generate_test_user_sig.dart';
import 'package:flutter_module/presentation/lib/src/login_widget.dart';
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
          IconButton(
            icon: const Icon(Icons.phone),
            tooltip: 'Test Call',
            onPressed: () {
              // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginWidget()));
              _login();
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
}

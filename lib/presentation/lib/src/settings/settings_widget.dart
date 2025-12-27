import 'package:flutter/material.dart';
import 'package:flutter_module/presentation/lib/generate/app_localizations.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';
import 'package:tencent_calls_uikit/src/impl/call_state.dart';
import 'package:flutter_module/presentation/lib/src/settings/settings_config.dart';
import 'package:flutter_module/presentation/lib/src/settings/settings_detail_widget.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  Resolution _resolution = SettingsConfig.resolution;
  ResolutionMode _resolutionMode = SettingsConfig.resolutionMode;
  FillMode _fillMode = SettingsConfig.fillMode;
  Rotation _rotation = SettingsConfig.rotation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('settings'),
        leading: IconButton(
            onPressed: () => _goBack(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
        child: ListView(
          children: [
            _getBasicSettingsWidget(),
            _getCallParamsSettingsWidget(),
            _getVideoSettingsWidget()
          ],
        ),
      ),
    );
  }

  _getBasicSettingsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: Text(
            'settings',
            style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                color: Colors.black54),
          ),
        ),
        SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'avatar',
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                InkWell(
                    onTap: () => _goDetailSettings(SettingWidgetType.avatar),
                    child: Row(children: [
                      SizedBox(
                          width: 200,
                          child: Text(
                            (SettingsConfig.avatar.isEmpty)
                                ? 'not_set'
                                : SettingsConfig.avatar,
                            maxLines: 1,
                            style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                            textAlign: TextAlign.right,
                          )),
                      const SizedBox(width: 10),
                      const Text('>')
                    ]))
              ],
            )),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'nick_name',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextField(
                      autofocus: true,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: (SettingsConfig.nickname.isEmpty)
                            ? 'not_set'
                            : SettingsConfig.nickname,
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        SettingsConfig.nickname = value;
                        TUICallKit.instance
                            .setSelfInfo(SettingsConfig.nickname, SettingsConfig.avatar);
                      }))
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'silent_mode',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              Switch(
                  value: SettingsConfig.muteMode,
                  onChanged: (value) {
                    setState(() {
                      SettingsConfig.muteMode = value;
                      TUICallKit.instance.enableMuteMode(SettingsConfig.muteMode);
                    });
                  })
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'enable_floating',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              Switch(
                  value: SettingsConfig.enableFloatWindow,
                  onChanged: (value) {
                    setState(() {
                      SettingsConfig.enableFloatWindow = value;
                      TUICallKit.instance.enableFloatWindow(SettingsConfig.enableFloatWindow);
                    });
                  })
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'show_blur_background_button',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              Switch(
                  value: SettingsConfig.showBlurBackground,
                  onChanged: (value) {
                    setState(() {
                      SettingsConfig.showBlurBackground = value;
                      TUICallKit.instance
                          .enableVirtualBackground(SettingsConfig.showBlurBackground);
                    });
                  })
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'show_incoming_banner',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              Switch(
                  value: SettingsConfig.showIncomingBanner,
                  onChanged: (value) {
                    setState(() {
                      SettingsConfig.showIncomingBanner = value;
                      TUICallKit.instance.enableIncomingBanner(SettingsConfig.showIncomingBanner);
                    });
                  })
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  _getCallParamsSettingsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: Text(
            'call_custom_setiings',
            style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                color: Colors.black54),
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'digital_room',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextField(
                      autofocus: true,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: '${SettingsConfig.intRoomId}',
                        border: InputBorder.none,
                      ),
                      onChanged: ((value) => SettingsConfig.intRoomId = int.parse(value))))
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'string_room',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextField(
                      autofocus: true,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: SettingsConfig.strRoomId,
                        border: InputBorder.none,
                      ),
                      onChanged: ((value) => SettingsConfig.strRoomId = value)))
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'timeout',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextField(
                      autofocus: true,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: '${SettingsConfig.timeout}',
                        border: InputBorder.none,
                      ),
                      onChanged: ((value) => SettingsConfig.timeout = int.parse(value))))
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'extended_info',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              InkWell(
                  onTap: () => _goDetailSettings(SettingWidgetType.extendInfo),
                  child: Row(children: [
                    Text(
                      SettingsConfig.extendInfo.isEmpty
                          ? 'not_set'
                          : SettingsConfig.extendInfo,
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(width: 10),
                    const Text('>')
                  ]))
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'offline_push_info',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              InkWell(
                  onTap: () => _goDetailSettings(SettingWidgetType.offlinePush),
                  child: Row(children: [
                    Text(
                      SettingsConfig.offlinePushInfo == null
                          ? 'not_set'
                          : 'go_set',
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(width: 10),
                    const Text('>')
                  ]))
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  _getVideoSettingsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: Text(
            'video_settings',
            style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.normal,
                color: Colors.black54),
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'resolution',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              DropdownButton(
                value: _resolution,
                items: const [
                  DropdownMenuItem(value: Resolution.resolution_640_360, child: Text('640_360')),
                  DropdownMenuItem(value: Resolution.resolution_960_540, child: Text('960_540')),
                  DropdownMenuItem(value: Resolution.resolution_1280_720, child: Text('1280_720')),
                  DropdownMenuItem(value: Resolution.resolution_1920_1080, child: Text('1920_1080')),
                ],
                onChanged: (value) {
                  setState(() {
                    _resolution = value!;
                    SettingsConfig.resolution = _resolution;
                  });

                  VideoEncoderParams params = VideoEncoderParams(
                      resolution: SettingsConfig.resolution,
                      resolutionMode: SettingsConfig.resolutionMode);
                  TUICallEngine.instance.setVideoEncoderParams(params);
                },
                underline: Container(height: 0),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'resolution_mode',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              DropdownButton(
                value: _resolutionMode,
                items: [
                    DropdownMenuItem(value: ResolutionMode.landscape, child: Text('horizontal')),
                  DropdownMenuItem(value: ResolutionMode.portrait, child: Text('vertical')),
                ],
                onChanged: (value) {
                  setState(() {
                    _resolutionMode = value!;
                    SettingsConfig.resolutionMode = _resolutionMode;
                  });

                  VideoEncoderParams params = VideoEncoderParams(
                      resolution: SettingsConfig.resolution,
                      resolutionMode: SettingsConfig.resolutionMode);
                  TUICallEngine.instance.setVideoEncoderParams(params);
                },
                underline: Container(height: 0),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'fill_pattern',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              DropdownButton(
                value: _fillMode,
                items: [
                  DropdownMenuItem(value: FillMode.fill, child: Text('fill')),
                  DropdownMenuItem(value: FillMode.fit, child: Text('fit')),
                ],
                onChanged: (value) {
                  setState(() {
                    _fillMode = value!;
                    SettingsConfig.fillMode = _fillMode;
                  });
                  _setVideoRenderParams();
                },
                underline: Container(height: 0),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'rotation',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              DropdownButton(
                value: _rotation,
                items: const [
                  DropdownMenuItem(value: Rotation.rotation_0, child: Text('0')),
                  DropdownMenuItem(value: Rotation.rotation_90, child: Text('90')),
                  DropdownMenuItem(value: Rotation.rotation_180, child: Text('180')),
                  DropdownMenuItem(value: Rotation.rotation_270, child: Text('270')),
                ],
                onChanged: (value) {
                  setState(() {
                    _rotation = value!;
                    SettingsConfig.rotation = _rotation;
                  });
                  _setVideoRenderParams();
                },
                underline: Container(height: 0),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'beauty_level',
                style: const TextStyle( 
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextField(
                      autofocus: true,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: '${SettingsConfig.beautyLevel}',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        SettingsConfig.beautyLevel = double.parse(value);
                        TUICallEngine.instance.setBeautyLevel(SettingsConfig.beautyLevel);
                      }))
            ],
          ),
        ),
      ],
    );
  }

  _goBack() {
    Navigator.of(context).pop();
  }

  _goDetailSettings(SettingWidgetType widgetType) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return SettingsDetailWidget(widgetType: widgetType);
      },
    ));
  }

  _setVideoRenderParams() {
    final params =
        VideoRenderParams(fillMode: SettingsConfig.fillMode, rotation: SettingsConfig.rotation);
    TUICallEngine.instance.setVideoRenderParams(CallState.instance.selfUser.id, params);
  }
}

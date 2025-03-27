import 'package:flutter_test/flutter_test.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter_platform_interface.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVpnclientEngineFlutterPlatform
    with MockPlatformInterfaceMixin
    implements VpnclientEngineFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final VpnclientEngineFlutterPlatform initialPlatform = VpnclientEngineFlutterPlatform.instance;

  test('$MethodChannelVpnclientEngineFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVpnclientEngineFlutter>());
  });

  test('getPlatformVersion', () async {
    VpnclientEngineFlutter vpnclientEngineFlutterPlugin = VpnclientEngineFlutter();
    MockVpnclientEngineFlutterPlatform fakePlatform = MockVpnclientEngineFlutterPlatform();
    VpnclientEngineFlutterPlatform.instance = fakePlatform;

    expect(await vpnclientEngineFlutterPlugin.getPlatformVersion(), '42');
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelVpnclientEngineFlutter platform = MethodChannelVpnclientEngineFlutter();
  const MethodChannel channel = MethodChannel('vpnclient_engine_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

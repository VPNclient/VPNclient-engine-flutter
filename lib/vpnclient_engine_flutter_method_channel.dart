import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'vpnclient_engine_flutter_platform_interface.dart';

/// An implementation of [VpnclientEngineFlutterPlatform] that uses method channels.
class MethodChannelVpnclientEngineFlutter extends VpnclientEngineFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('vpnclient_engine_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  Future<void> startVPN(String configPath) =>
      methodChannel.invokeMethod('startVPN', {"config": configPath});

  Future<void> stopVPN() => methodChannel.invokeMethod('stopVPN');

  Future<String> getStatus() =>
      methodChannel.invokeMethod('status').then((value) => value.toString());
}

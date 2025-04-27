import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vpnclient_engine_flutter/platforms/android.dart';

import 'vpnclient_engine/engine.dart';

export 'vpnclient_engine/core.dart';
export 'vpnclient_engine/engine.dart';

abstract class VpnclientEngineFlutterPlatform {
  static VpnclientEngineFlutterPlatform? _instance;

  static VpnclientEngineFlutterPlatform get instance {
    if (_instance == null) {
      if (Platform.isAndroid) {
        _instance = AndroidVpnclientEngineFlutter();
      } else if (Platform.isIOS) {
        _instance = IosVpnclientEngineFlutter();
      } else {
        throw UnimplementedError('Platform not supported');
      }
    }
    return _instance!;
  }

  Future<String?> getPlatformVersion();

  Future<void> connect({
    required String url,
  });

  Future<void> disconnect();
}

class IosVpnclientEngineFlutter extends VpnclientEngineFlutterPlatform {
  static const MethodChannel _channel =
      MethodChannel('vpnclient_engine_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> connect({required String url}) async {
    await _channel.invokeMethod('connect', {'url': url});
  }

  @override
  Future<void> disconnect() async {
    await _channel.invokeMethod('disconnect');
  }
}
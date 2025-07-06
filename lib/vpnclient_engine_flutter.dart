import 'dart:async';
import 'dart:io' show Platform;

import 'package:vpnclient_engine_flutter/platforms/ios.dart';
import 'package:vpnclient_engine_flutter/platforms/android.dart';

import 'vpnclient_engine/engine.dart';
import 'vpnclient_engine/core.dart';

export 'vpnclient_engine/engine.dart';

// Simple logger for production code
void _log(String message) {
  // ignore: avoid_print
  print('VpnclientEngineFlutter: $message');
}

abstract class VpnclientEngineFlutterPlatform {
  static VpnclientEngineFlutterPlatform? _instance;

  static VpnclientEngineFlutterPlatform get instance {
    if (_instance == null) {
      if (Platform.isAndroid) {
        _instance = AndroidVpnclientEngineFlutter();
      } else if (Platform.isIOS) {
        _instance = IosVpnclientEngineFlutter();
      } else {
        _instance = VpnclientEngineFlutter();
        _log(
          'VPNclientEngineFlutter: Warning: Platform not yet supported, fallback to default implementation',
        );
        _log(
          'Please report this platform ${Platform.operatingSystem} on https://github.com/VPNclient/vpnclient_engine_flutter/issues',
        );
      }
    }
    return _instance!;
  }

  Future<String?> getPlatformVersion();

  Future<void> connect({required String url});

  Future<void> disconnect();

  void sendStatus(ConnectionStatus status) {
    _log("default: $status");
  }

  void sendError(ErrorCode errorCode, String errorMessage) {
    _log("default: $errorCode $errorMessage");
  }
}

class VpnclientEngineFlutter extends VpnclientEngineFlutterPlatform {
  @override
  Future<void> connect({required String url}) async {
    return Future.value();
  }

  @override
  Future<String?> getPlatformVersion() async {
    return "Platform not yet supported";
  }

  @override
  Future<void> disconnect() async {
    _log('VpnclientEngineFlutter: disconnect called');
    // TODO: implement disconnect
  }
}

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vpnclient_engine_flutter/platforms/ios.dart';
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
        _instance = VpnclientEngineFlutterPlatform();
        print(
            'VPNclientEngineFlutter: Warning: Platform not yet supported, fallback to default implementation');
        print('Please report this platform ${Platform.operatingSystem} on https://github.com/VPNclient/vpnclient_engine_flutter/issues');
        
      }
    }
    return _instance!;
  }

  Future<String?> getPlatformVersion();

  Future<void> connect({
    required String url,
  });

  Future<void> disconnect();

  void sendStatus(ConnectionStatus status) {
      print("default: $status");
  }

  void sendError(ErrorCode errorCode, String errorMessage) {
      print("default: $errorCode $errorMessage");
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
}

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine/core.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine/engine.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

class AndroidVpnclientEngineFlutter extends VpnclientEngineFlutterPlatform {
  static const MethodChannel _channel = MethodChannel('vpnclient_engine_flutter');
  final FlutterV2ray flutterV2ray = FlutterV2ray(
    onStatusChanged: (status) {
        switch (status) {
          case V2RayStatus.connected:
            _connectionStatusSubject.add(ConnectionStatus.connected);
            break;
          case V2RayStatus.connecting:
            _connectionStatusSubject.add(ConnectionStatus.connecting);
            break;
          case V2RayStatus.disconnected:
            _connectionStatusSubject.add(ConnectionStatus.disconnected);
            break;
          case V2RayStatus.error:
            _connectionStatusSubject.add(ConnectionStatus.error);
            break;
        }
    },
  );
  static final _connectionStatusSubject = StreamController<ConnectionStatus>.broadcast();


  static void registerWith() {
    VpnclientEngineFlutterPlatform.instance = AndroidVpnclientEngineFlutter();
  }

  @override
  Future<void> connect(String url) async {
      try {
        _connectionStatusSubject.add(ConnectionStatus.connecting);
        final parser = FlutterV2ray.parseFromURL(url);
        if (await flutterV2ray.requestPermission()) {
          await flutterV2ray.startV2Ray(
            remark: parser.remark,
            config: parser.getFullConfiguration(),
            blockedApps: null,
            bypassSubnets: null,
            proxyOnly: false,
          );
        } else {
             _connectionStatusSubject.add(ConnectionStatus.error);
            VPNclientEngine.emitError(ErrorCode.unknownError, 'Permission denied');
        }
      } catch (e) {
            _connectionStatusSubject.add(ConnectionStatus.error);
            VPNclientEngine.emitError(ErrorCode.unknownError, 'Error: $e');
      }
  }

  @override
  Future<void> disconnect() async {
    try {
      _connectionStatusSubject.add(ConnectionStatus.disconnected);
      await flutterV2ray.stopV2Ray();
    } catch (e) {
        VPNclientEngine.emitError(ErrorCode.unknownError, 'Error: $e');
    }
  }
    @override
  Future<bool> requestPermission() async {
      try{
          return await flutterV2ray.requestPermission();
      } catch (e){
          return false;
      }
  }
}
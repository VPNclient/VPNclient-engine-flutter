import 'dart:async';

import 'package:vpnclient_engine_flutter/vpnclient_engine/core.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine/engine.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

class AndroidVpnclientEngineFlutter extends VpnclientEngineFlutterPlatform {
  static const MethodChannel _channel = MethodChannel(
    'vpnclient_engine_flutter',
  );
  final FlutterV2ray _flutterV2ray = FlutterV2ray(
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

  static final _connectionStatusSubject =
      StreamController<ConnectionStatus>.broadcast();
  static final _statusStream =
      _connectionStatusSubject.stream.asBroadcastStream();

  static void registerWith() {
    VpnclientEngineFlutterPlatform.instance = AndroidVpnclientEngineFlutter();
  }

  @override
  Future<void> connect(String url, VpnCore core) async {
    try {
      if (url.startsWith('vless://') || url.startsWith('vmess://')) {
        _connectionStatusSubject.add(ConnectionStatus.connecting);
        await _startV2Ray(url);
      } else if (url.startsWith('wg://')) {
        _connectionStatusSubject.add(ConnectionStatus.connecting);
        await _startWireguard(url);
      } else if (url.startsWith('ovpn://')) {
        _connectionStatusSubject.add(ConnectionStatus.connecting);
        await _startOpenvpn(url);
      } else {
        VPNclientEngine.emitError(
          ErrorCode.unknownError,
          'Invalid URL protocol',
        );
        _connectionStatusSubject.add(ConnectionStatus.error);
      }
    } catch (e) {
      VPNclientEngine.emitError(ErrorCode.unknownError, 'Error: $e');
      _connectionStatusSubject.add(ConnectionStatus.error);
    }
  }

  Future<void> _startV2Ray(String url) async {
    final parser = FlutterV2ray.parseFromURL(url);
    if (await _flutterV2ray.requestPermission()) {
      await _flutterV2ray.startV2Ray(
        remark: parser.remark,
        config: parser.getFullConfiguration(),
        blockedApps: null,
        bypassSubnets: null,
        proxyOnly: false,
      );
    } else {
      VPNclientEngine.emitError(ErrorCode.unknownError, 'Permission denied');
      _connectionStatusSubject.add(ConnectionStatus.error);
    }
  }

  Future<void> _startWireguard(String url) async {
    final parser = FlutterV2ray.parseFromURL(url);
    if (await _flutterV2ray.requestPermission()) {
      await _flutterV2ray.startV2Ray(
        remark: parser.remark,
        config: parser.getFullConfiguration(),
        blockedApps: null,
        bypassSubnets: null,
        proxyOnly: false,
      );
    } else {
      VPNclientEngine.emitError(ErrorCode.unknownError, 'Permission denied');
      _connectionStatusSubject.add(ConnectionStatus.error);
    }
  }

  Future<void> _startOpenvpn(String url) async {
    VPNclientEngine.emitError(
      ErrorCode.unknownError,
      'OpenVPN not implemented yet',
    );
    _connectionStatusSubject.add(ConnectionStatus.error);
  }

  @override
  Future<void> disconnect() async {
    try {
      _connectionStatusSubject.add(ConnectionStatus.disconnected);
      if (await _flutterV2ray.isRunning()) {
        await _flutterV2ray.stopV2Ray();
      }
    } catch (e) {
      VPNclientEngine.emitError(ErrorCode.unknownError, 'Error: $e');
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      return await _flutterV2ray.requestPermission();
    } catch (e) {
      return false;
    }
  }
}

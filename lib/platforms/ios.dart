import 'dart:async';
import 'package:flutter/services.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine/platform_base.dart';

// Simple logger for production code
void _log(String message) {
  // ignore: avoid_print
  print('IosVpnclientEngineFlutter: $message');
}

class IosVpnclientEngineFlutter extends VpnclientEngineFlutterPlatform {
  static const MethodChannel _channel = MethodChannel('vpnclient_engine_flutter');

  @override
  Future<void> connect({required String url}) async {
    _log('connect called with url: $url');
    // TODO: implement iOS-specific connection
  }

  @override
  Future<void> disconnect() async {
    _log('disconnect called');
    try {
      await _channel.invokeMethod('disconnect');
    } catch (e) {
      _log('Error disconnecting: $e');
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    try {
      final String? version = await _channel.invokeMethod('getPlatformVersion');
      return version;
    } catch (e) {
      _log('Error getting platform version: $e');
      return 'iOS';
    }
  }

  /// Connect using LibXray engine
  Future<bool> connectLibXray({required String config}) async {
    try {
      final bool result = await _channel.invokeMethod('connect', {
        'engine': 'libxray',
        'config': config,
      });
      return result;
    } catch (e) {
      _log('Error connecting with LibXray: $e');
      return false;
    }
  }

  /// Connect using SingBox engine
  Future<bool> connectSingBox({required String config}) async {
    try {
      final bool result = await _channel.invokeMethod('connect', {
        'engine': 'singbox',
        'config': config,
      });
      return result;
    } catch (e) {
      _log('Error connecting with SingBox: $e');
      return false;
    }
  }

  /// Test Xray configuration
  Future<bool> testXrayConfig({required String config}) async {
    try {
      final bool result = await _channel.invokeMethod('testXrayConfig', {
        'config': config,
      });
      return result;
    } catch (e) {
      _log('Error testing Xray config: $e');
      return false;
    }
  }

  /// Ping server with Xray configuration
  Future<int> pingServer({required String config, required String url, int timeout = 10}) async {
    try {
      final int result = await _channel.invokeMethod('pingServer', {
        'config': config,
        'url': url,
        'timeout': timeout,
      });
      return result;
    } catch (e) {
      _log('Error pinging server: $e');
      return -1;
    }
  }

  /// Get Xray version
  Future<String> getXrayVersion() async {
    try {
      final String result = await _channel.invokeMethod('getXrayVersion');
      return result;
    } catch (e) {
      _log('Error getting Xray version: $e');
      return 'Unknown';
    }
  }

  /// Request VPN permissions
  Future<bool> requestPermissions() async {
    try {
      final bool result = await _channel.invokeMethod('requestPermissions');
      return result;
    } catch (e) {
      _log('Error requesting permissions: $e');
      return false;
    }
  }

  /// Check system permissions
  Future<bool> checkSystemPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkSystemPermission');
      return result;
    } catch (e) {
      _log('Error checking system permission: $e');
      return false;
    }
  }

  /// Get connection status
  Future<String> getConnectionStatus() async {
    try {
      final String result = await _channel.invokeMethod('getConnectionStatus');
      return result;
    } catch (e) {
      _log('Error getting connection status: $e');
      return 'disconnected';
    }
  }
}

import 'package:flutter/services.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine/platform_base.dart';

// Simple logger for production code
void _log(String message) {
  // ignore: avoid_print
  print('AndroidVpnclientEngineFlutter: $message');
}

class AndroidVpnclientEngineFlutter extends VpnclientEngineFlutterPlatform {
  static const MethodChannel _channel = MethodChannel('vpnclient_engine_flutter');

  @override
  Future<void> connect({required String url}) async {
    _log('connect called with URL: $url');
    try {
      await _channel.invokeMethod('connect', {'url': url});
    } catch (e) {
      _log('Connect error: $e');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    _log('disconnect called');
    try {
      await _channel.invokeMethod('disconnect');
    } catch (e) {
      _log('Disconnect error: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    try {
      final version = await _channel.invokeMethod<String>('getPlatformVersion');
      return version;
    } catch (e) {
      _log('Get platform version error: $e');
      return 'Android (error)';
    }
  }

  /// Connect with libXray using JSON configuration
  Future<bool> connectLibXray({required String config}) async {
    _log('connectLibXray called');
    try {
      await _channel.invokeMethod('connect', {'config': config});
      return true;
    } catch (e) {
      _log('LibXray connect error: $e');
      return false;
    }
  }

  /// Test Xray configuration
  Future<bool> testXrayConfig({required String config}) async {
    _log('testXrayConfig called');
    try {
      final result = await _channel.invokeMethod<bool>('testConfig', {'config': config});
      return result ?? false;
    } catch (e) {
      _log('Test config error: $e');
      return false;
    }
  }

  /// Ping server with configuration
  Future<int> pingServer({
    required String config,
    required String url,
    int timeout = 10,
  }) async {
    _log('pingServer called');
    try {
      final result = await _channel.invokeMethod<int>('ping', {
        'config': config,
        'url': url,
        'timeout': timeout,
      });
      return result ?? -1;
    } catch (e) {
      _log('Ping server error: $e');
      return -1;
    }
  }

  /// Get libXray version
  Future<String> getXrayVersion() async {
    _log('getXrayVersion called');
    try {
      final version = await _channel.invokeMethod<String>('getVersion');
      return version ?? 'Unknown';
    } catch (e) {
      _log('Get version error: $e');
      return 'Unknown';
    }
  }

  /// Get connection status
  Future<String> getConnectionStatus() async {
    _log('getConnectionStatus called');
    try {
      final status = await _channel.invokeMethod<String>('getConnectionStatus');
      return status ?? 'disconnected';
    } catch (e) {
      _log('Get connection status error: $e');
      return 'disconnected';
    }
  }

  /// Request VPN permissions
  Future<bool> requestPermissions() async {
    _log('requestPermissions called');
    try {
      final result = await _channel.invokeMethod<bool>('requestPermissions');
      return result ?? false;
    } catch (e) {
      _log('Request permissions error: $e');
      return false;
    }
  }
}

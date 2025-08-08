import 'dart:async';
import 'dart:io' show Platform;

import 'package:vpnclient_engine_flutter/platforms/ios.dart';
import 'package:vpnclient_engine_flutter/platforms/android.dart';

import 'vpnclient_engine/engine_types.dart';
import 'vpnclient_engine/engine_factory.dart';
import 'vpnclient_engine/legacy_adapter.dart';

export 'vpnclient_engine/engine_types.dart';
export 'vpnclient_engine/engine_factory.dart';
export 'vpnclient_engine/legacy_adapter.dart';

// Simple logger for production code
void _log(String message) {
  // ignore: avoid_print
  print('VpnclientEngineFlutter: $message');
}

/// Main plugin class for VPN client engine
class VpnclientEngineFlutter {
  static VpnclientEngineFlutter? _instance;
  static VpnClient? _vpnClient;

  /// Get singleton instance
  static VpnclientEngineFlutter get instance {
    _instance ??= VpnclientEngineFlutter._();
    return _instance!;
  }

  /// Get VPN client instance
  static VpnClient get client {
    _vpnClient ??= VpnClient();
    return _vpnClient!;
  }

  VpnclientEngineFlutter._();

  /// Initialize the plugin
  static Future<void> initialize() async {
    _log('Initializing VpnclientEngineFlutter plugin');
    // Plugin is ready to use
  }

  /// Get platform version
  static Future<String?> getPlatformVersion() async {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else {
      return 'Unknown';
    }
  }

  /// Get supported engines for current platform
  static List<String> getSupportedEngines() {
    return VpnEngineFactory.getSupportedEngineNames();
  }

  /// Check if engine is supported
  static bool isEngineSupported(EngineType type) {
    return VpnEngineFactory.isEngineSupported(type);
  }

  /// Connect using specified engine
  static Future<bool> connect(EngineType engine, String config) async {
    return await client.connect(engine, config);
  }

  /// Disconnect current connection
  static Future<void> disconnect() async {
    await client.disconnect();
  }

  /// Test configuration with specified engine
  static Future<bool> testConfig(EngineType engine, String config) async {
    return await client.testConfig(engine, config);
  }

  /// Ping server with specified engine
  static Future<int> ping(EngineType engine, String config, String url, {int timeout = 10}) async {
    return await client.ping(engine, config, url, timeout: timeout);
  }

  /// Get version of specified engine
  static Future<String> getVersion(EngineType engine) async {
    return await client.getVersion(engine);
  }

  /// Get current connection status
  static Future<ConnectionStatus> getConnectionStatus() async {
    return await client.getConnectionStatus();
  }

  /// Request permissions for specified engine
  static Future<bool> requestPermissions(EngineType engine) async {
    return await client.requestPermissions(engine);
  }

  /// Get current engine
  static VpnEngine? getCurrentEngine() {
    return client.currentEngine;
  }

  /// Get current engine type
  static EngineType? getCurrentEngineType() {
    return client.currentEngineType;
  }
}

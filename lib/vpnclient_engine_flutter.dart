import 'dart:async';
import 'dart:io' show Platform;

import 'package:vpnclient_engine_flutter/platforms/ios.dart';
import 'package:vpnclient_engine_flutter/platforms/android.dart';

import 'vpnclient_engine/engine_types.dart';
import 'vpnclient_engine/engine_factory.dart';
import 'vpnclient_engine/legacy_adapter.dart';
import 'vpnclient_engine/platform_base.dart';

export 'vpnclient_engine/engine_types.dart';
export 'vpnclient_engine/engine_factory.dart';
export 'vpnclient_engine/legacy_adapter.dart';
export 'vpnclient_engine/platform_base.dart';

// Simple logger for production code
void _log(String message) {
  // ignore: avoid_print
  print('VpnclientEngineFlutter: $message');
}

/// Callback function type for VPN status changes
typedef VpnStatusCallback = void Function(ConnectionStatus status);

/// Main plugin class for VPN client engine
class VpnclientEngineFlutter {
  static VpnclientEngineFlutter? _instance;
  static VpnClient? _vpnClient;
  
  /// Status change callback
  VpnStatusCallback? _onStatusChanged;
  
  /// Timer for status polling
  Timer? _statusTimer;
  
  /// Current connection status
  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;

  /// Constructor with optional status callback
  VpnclientEngineFlutter({VpnStatusCallback? onStatusChanged}) {
    _onStatusChanged = onStatusChanged;
  }

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
  Future<void> initialize() async {
    _log('Initializing VpnclientEngineFlutter plugin');
    
    // Start status polling if callback is provided
    if (_onStatusChanged != null) {
      _startStatusPolling();
    }
  }

  /// Start polling for status changes
  void _startStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final status = await getConnectionStatus();
      if (status != _currentStatus) {
        _currentStatus = status;
        _onStatusChanged?.call(status);
      }
    });
  }

  /// Stop status polling
  void _stopStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }

  /// Set status change callback
  void setStatusCallback(VpnStatusCallback callback) {
    _onStatusChanged = callback;
    if (_onStatusChanged != null && _statusTimer == null) {
      _startStatusPolling();
    } else if (_onStatusChanged == null) {
      _stopStatusPolling();
    }
  }

  /// Connect using specified engine
  Future<bool> connect(EngineType engine, String config) async {
    return await client.connect(engine, config);
  }

  /// Disconnect current connection
  Future<void> disconnect() async {
    await client.disconnect();
  }

  /// Test configuration with specified engine
  Future<bool> testConfig(EngineType engine, String config) async {
    return await client.testConfig(engine, config);
  }

  /// Ping server with specified engine
  Future<int> ping(EngineType engine, String config, String url, {int timeout = 10}) async {
    return await client.ping(engine, config, url, timeout: timeout);
  }

  /// Get version of specified engine
  Future<String> getVersion(EngineType engine) async {
    return await client.getVersion(engine);
  }

  /// Get current connection status
  Future<ConnectionStatus> getConnectionStatus() async {
    return await client.getConnectionStatus();
  }

  /// Request permissions for specified engine
  Future<bool> requestPermissions(EngineType engine) async {
    return await client.requestPermissions(engine);
  }

  /// Get current engine
  VpnEngine? getCurrentEngine() {
    return client.currentEngine;
  }

  /// Get current engine type
  EngineType? getCurrentEngineType() {
    return client.currentEngineType;
  }

  /// Dispose resources
  void dispose() {
    _stopStatusPolling();
    _onStatusChanged = null;
  }

  // Static methods for backward compatibility
  /// Initialize the plugin (static method)
  static Future<void> initialize() async {
    _log('Initializing VpnclientEngineFlutter plugin (static)');
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

  /// Connect using specified engine (static method)
  static Future<bool> connect(EngineType engine, String config) async {
    return await client.connect(engine, config);
  }

  /// Disconnect current connection (static method)
  static Future<void> disconnect() async {
    await client.disconnect();
  }

  /// Test configuration with specified engine (static method)
  static Future<bool> testConfig(EngineType engine, String config) async {
    return await client.testConfig(engine, config);
  }

  /// Ping server with specified engine (static method)
  static Future<int> ping(EngineType engine, String config, String url, {int timeout = 10}) async {
    return await client.ping(engine, config, url, timeout: timeout);
  }

  /// Get version of specified engine (static method)
  static Future<String> getVersion(EngineType engine) async {
    return await client.getVersion(engine);
  }

  /// Get current connection status (static method)
  static Future<ConnectionStatus> getConnectionStatus() async {
    return await client.getConnectionStatus();
  }

  /// Request permissions for specified engine (static method)
  static Future<bool> requestPermissions(EngineType engine) async {
    return await client.requestPermissions(engine);
  }

  /// Get current engine (static method)
  static VpnEngine? getCurrentEngine() {
    return client.currentEngine;
  }

  /// Get current engine type (static method)
  static EngineType? getCurrentEngineType() {
    return client.currentEngineType;
  }
}

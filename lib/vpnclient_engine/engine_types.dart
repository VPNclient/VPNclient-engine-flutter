/// Supported VPN engine types
enum EngineType {
  libxray,
  singbox,
  v2ray,
}

/// VPN connection status
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// VPN engine interface
abstract class VpnEngine {
  /// Engine name
  String get name;
  
  /// Engine type
  EngineType get type;
  
  /// Check if engine is supported on current platform
  bool get isSupported;
  
  /// Connect using this engine
  Future<bool> connect(String config);
  
  /// Disconnect current connection
  Future<void> disconnect();
  
  /// Test configuration
  Future<bool> testConfig(String config);
  
  /// Ping server with configuration
  Future<int> ping(String config, String url, {int timeout = 10});
  
  /// Get engine version
  Future<String> getVersion();
  
  /// Get connection status
  Future<ConnectionStatus> getConnectionStatus();
  
  /// Request permissions (if needed)
  Future<bool> requestPermissions();
}

/// VPN client that can switch between different engines
class VpnClient {
  VpnEngine? _currentEngine;
  EngineType? _currentEngineType;
  
  /// Get current engine
  VpnEngine? get currentEngine => _currentEngine;
  
  /// Get current engine type
  EngineType? get currentEngineType => _currentEngineType;
  
  /// Connect using specified engine
  Future<bool> connect(EngineType engineType, String config) async {
    try {
      _currentEngine = VpnEngineFactory.create(engineType);
      _currentEngineType = engineType;
      
      if (_currentEngine == null) {
        throw Exception('Engine $engineType is not supported');
      }
      
      if (!_currentEngine!.isSupported) {
        throw Exception('Engine $engineType is not supported on this platform');
      }
      
      return await _currentEngine!.connect(config);
    } catch (e) {
      print('Error connecting with $engineType: $e');
      return false;
    }
  }
  
  /// Disconnect current connection
  Future<void> disconnect() async {
    try {
      await _currentEngine?.disconnect();
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }
  
  /// Test configuration with specified engine
  Future<bool> testConfig(EngineType engineType, String config) async {
    try {
      final engine = VpnEngineFactory.create(engineType);
      if (engine == null || !engine.isSupported) {
        return false;
      }
      return await engine.testConfig(config);
    } catch (e) {
      print('Error testing config with $engineType: $e');
      return false;
    }
  }
  
  /// Ping server with specified engine
  Future<int> ping(EngineType engineType, String config, String url, {int timeout = 10}) async {
    try {
      final engine = VpnEngineFactory.create(engineType);
      if (engine == null || !engine.isSupported) {
        return -1;
      }
      return await engine.ping(config, url, timeout: timeout);
    } catch (e) {
      print('Error pinging with $engineType: $e');
      return -1;
    }
  }
  
  /// Get version of specified engine
  Future<String> getVersion(EngineType engineType) async {
    try {
      final engine = VpnEngineFactory.create(engineType);
      if (engine == null || !engine.isSupported) {
        return 'Not supported';
      }
      return await engine.getVersion();
    } catch (e) {
      print('Error getting version for $engineType: $e');
      return 'Unknown';
    }
  }
  
  /// Get current connection status
  Future<ConnectionStatus> getConnectionStatus() async {
    try {
      return await _currentEngine?.getConnectionStatus() ?? ConnectionStatus.disconnected;
    } catch (e) {
      print('Error getting connection status: $e');
      return ConnectionStatus.disconnected;
    }
  }
  
  /// Request permissions for specified engine
  Future<bool> requestPermissions(EngineType engineType) async {
    try {
      final engine = VpnEngineFactory.create(engineType);
      if (engine == null || !engine.isSupported) {
        return false;
      }
      return await engine.requestPermissions();
    } catch (e) {
      print('Error requesting permissions for $engineType: $e');
      return false;
    }
  }
} 
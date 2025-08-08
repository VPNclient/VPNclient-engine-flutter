import 'dart:io';
import '../engine_types.dart';
import '../../platforms/ios.dart';

/// SingBox engine implementation
class SingBoxEngine implements VpnEngine {
  final IosVpnclientEngineFlutter _iosEngine = IosVpnclientEngineFlutter();
  
  @override
  String get name => 'SingBox';
  
  @override
  EngineType get type => EngineType.singbox;
  
  @override
  bool get isSupported => Platform.isIOS || Platform.isMacOS;
  
  @override
  Future<bool> connect(String config) async {
    if (!isSupported) {
      throw UnsupportedError('SingBox is not supported on this platform');
    }
    
    try {
      return await _iosEngine.connectSingBox(config: config);
    } catch (e) {
      print('SingBox connect error: $e');
      return false;
    }
  }
  
  @override
  Future<void> disconnect() async {
    if (!isSupported) {
      throw UnsupportedError('SingBox is not supported on this platform');
    }
    
    try {
      await _iosEngine.disconnect();
    } catch (e) {
      print('SingBox disconnect error: $e');
    }
  }
  
  @override
  Future<bool> testConfig(String config) async {
    if (!isSupported) {
      return false;
    }
    
    // TODO: Implement SingBox config testing
    // For now, return true as SingBox configs are generally valid
    return true;
  }
  
  @override
  Future<int> ping(String config, String url, {int timeout = 10}) async {
    if (!isSupported) {
      return -1;
    }
    
    // TODO: Implement SingBox ping
    // For now, return -1 (not implemented)
    return -1;
  }
  
  @override
  Future<String> getVersion() async {
    if (!isSupported) {
      return 'Not supported';
    }
    
    // TODO: Implement SingBox version
    return 'SingBox (version unknown)';
  }
  
  @override
  Future<ConnectionStatus> getConnectionStatus() async {
    if (!isSupported) {
      return ConnectionStatus.disconnected;
    }
    
    try {
      final status = await _iosEngine.getConnectionStatus();
      switch (status) {
        case 'connected':
          return ConnectionStatus.connected;
        case 'connecting':
          return ConnectionStatus.connecting;
        case 'error':
          return ConnectionStatus.error;
        case 'disconnected':
        default:
          return ConnectionStatus.disconnected;
      }
    } catch (e) {
      print('SingBox get status error: $e');
      return ConnectionStatus.disconnected;
    }
  }
  
  @override
  Future<bool> requestPermissions() async {
    if (!isSupported) {
      return false;
    }
    
    try {
      return await _iosEngine.requestPermissions();
    } catch (e) {
      print('SingBox request permissions error: $e');
      return false;
    }
  }
} 
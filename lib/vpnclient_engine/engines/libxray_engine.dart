import 'dart:io';
import '../engine_types.dart';
import '../../platforms/ios.dart';

/// LibXray engine implementation
class LibXrayEngine implements VpnEngine {
  final IosVpnclientEngineFlutter _iosEngine = IosVpnclientEngineFlutter();
  
  @override
  String get name => 'LibXray';
  
  @override
  EngineType get type => EngineType.libxray;
  
  @override
  bool get isSupported => Platform.isIOS || Platform.isMacOS;
  
  @override
  Future<bool> connect(String config) async {
    if (!isSupported) {
      throw UnsupportedError('LibXray is not supported on this platform');
    }
    
    try {
      return await _iosEngine.connectLibXray(config: config);
    } catch (e) {
      print('LibXray connect error: $e');
      return false;
    }
  }
  
  @override
  Future<void> disconnect() async {
    if (!isSupported) {
      throw UnsupportedError('LibXray is not supported on this platform');
    }
    
    try {
      await _iosEngine.disconnect();
    } catch (e) {
      print('LibXray disconnect error: $e');
    }
  }
  
  @override
  Future<bool> testConfig(String config) async {
    if (!isSupported) {
      return false;
    }
    
    try {
      return await _iosEngine.testXrayConfig(config: config);
    } catch (e) {
      print('LibXray test config error: $e');
      return false;
    }
  }
  
  @override
  Future<int> ping(String config, String url, {int timeout = 10}) async {
    if (!isSupported) {
      return -1;
    }
    
    try {
      return await _iosEngine.pingServer(
        config: config,
        url: url,
        timeout: timeout,
      );
    } catch (e) {
      print('LibXray ping error: $e');
      return -1;
    }
  }
  
  @override
  Future<String> getVersion() async {
    if (!isSupported) {
      return 'Not supported';
    }
    
    try {
      return await _iosEngine.getXrayVersion();
    } catch (e) {
      print('LibXray get version error: $e');
      return 'Unknown';
    }
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
      print('LibXray get status error: $e');
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
      print('LibXray request permissions error: $e');
      return false;
    }
  }
} 
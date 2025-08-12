import 'dart:io';
import '../engine_types.dart';
import '../../platforms/ios.dart';
import '../../platforms/android.dart';

/// LibXray engine implementation
class LibXrayEngine implements VpnEngine {
  final IosVpnclientEngineFlutter _iosEngine = IosVpnclientEngineFlutter();
  final AndroidVpnclientEngineFlutter _androidEngine = AndroidVpnclientEngineFlutter();
  
  @override
  String get name => 'LibXray';
  
  @override
  EngineType get type => EngineType.libxray;
  
  @override
  bool get isSupported => Platform.isIOS || Platform.isMacOS || Platform.isAndroid;
  
  @override
  Future<bool> connect(String config) async {
    if (!isSupported) {
      throw UnsupportedError('LibXray is not supported on this platform');
    }
    
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        return await _iosEngine.connectLibXray(config: config);
      } else if (Platform.isAndroid) {
        // For Android, we'll use a simple implementation for now
        print('LibXray connect on Android: $config');
        return true; // Placeholder
      }
      return false;
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
      if (Platform.isIOS || Platform.isMacOS) {
        await _iosEngine.disconnect();
      } else if (Platform.isAndroid) {
        await _androidEngine.disconnect();
      }
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
      if (Platform.isIOS || Platform.isMacOS) {
        return await _iosEngine.testXrayConfig(config: config);
      } else if (Platform.isAndroid) {
        // For Android, we'll use a simple implementation for now
        print('LibXray test config on Android: $config');
        return true; // Placeholder
      }
      return false;
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
      if (Platform.isIOS || Platform.isMacOS) {
        return await _iosEngine.pingServer(
          config: config,
          url: url,
          timeout: timeout,
        );
      } else if (Platform.isAndroid) {
        // For Android, we'll use a simple implementation for now
        print('LibXray ping on Android: $config -> $url');
        return 100; // Placeholder latency
      }
      return -1;
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
      if (Platform.isIOS || Platform.isMacOS) {
        return await _iosEngine.getXrayVersion();
      } else if (Platform.isAndroid) {
        return 'Android LibXray v1.0'; // Placeholder
      }
      return 'Unknown';
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
      if (Platform.isIOS || Platform.isMacOS) {
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
      } else if (Platform.isAndroid) {
        // For Android, we'll use a simple implementation for now
        return ConnectionStatus.disconnected; // Placeholder
      }
      return ConnectionStatus.disconnected;
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
      if (Platform.isIOS || Platform.isMacOS) {
        return await _iosEngine.requestPermissions();
      } else if (Platform.isAndroid) {
        // For Android, we'll use a simple implementation for now
        print('LibXray request permissions on Android');
        return true; // Placeholder
      }
      return false;
    } catch (e) {
      print('LibXray request permissions error: $e');
      return false;
    }
  }
} 
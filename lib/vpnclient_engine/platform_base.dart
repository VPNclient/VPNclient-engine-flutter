import 'engine_types.dart';

/// Base class for platform implementations
abstract class VpnclientEngineFlutterPlatform {
  Future<String?> getPlatformVersion();
  Future<void> connect({required String url});
  Future<void> disconnect();
  
  void sendStatus(ConnectionStatus status) {
    print("default: $status");
  }
  
  void sendError(String errorCode, String errorMessage) {
    print("default: $errorCode $errorMessage");
  }
} 
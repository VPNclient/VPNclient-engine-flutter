import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';

// Simple logger for production code
void _log(String message) {
  // ignore: avoid_print
  print('AndroidVpnclientEngineFlutter: $message');
}

class AndroidVpnclientEngineFlutter extends VpnclientEngineFlutterPlatform {
  @override
  Future<void> connect({required String url}) async {
    _log('connect called');
    // TODO: implement Android-specific connection
  }

  @override
  Future<void> disconnect() async {
    _log('disconnect called');
    // TODO: implement Android-specific disconnection
  }

  @override
  Future<String?> getPlatformVersion() async {
    return 'Android';
  }
}

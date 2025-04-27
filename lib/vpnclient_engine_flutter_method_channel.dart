import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'vpnclient_engine_flutter_platform_interface.dart';

class VpnclientEngineFlutterMethodChannel
    extends VpnclientEngineFlutterPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('vpnclient_engine_flutter');

  @override
  Future<void> startVPN({required String configPath}) async {
    try {
      await methodChannel.invokeMethod('startVPN', {"config": configPath});
    } catch (e) {
      debugPrint('Error starting VPN: $e');
      rethrow;
    }
  }

  @override
  Future<void> stopVPN() async {
    try {
      await methodChannel.invokeMethod('stopVPN');
    } catch (e) {
      debugPrint('Error stopping VPN: $e');
      rethrow;
    }
  }
  @override
  Future<String> checkVPNStatus() async {
    final result = await methodChannel.invokeMethod('status');
    return result.toString();
  }
}

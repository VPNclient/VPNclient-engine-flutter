
import 'vpnclient_engine_flutter_platform_interface.dart';

class VpnclientEngineFlutter {
  Future<String?> getPlatformVersion() {
    return VpnclientEngineFlutterPlatform.instance.getPlatformVersion();
  }
}

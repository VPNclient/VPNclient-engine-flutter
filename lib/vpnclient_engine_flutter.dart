
import 'vpnclient_engine_flutter_platform_interface.dart';

export 'vpnclient_engine/engine.dart';

class VpnclientEngineFlutter {

  Future<String?> getPlatformVersion() {
    return VpnclientEngineFlutterPlatform.instance.getPlatformVersion();
  }
}

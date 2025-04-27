import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'vpnclient_engine_flutter_method_channel.dart';


abstract class VpnclientEngineFlutterPlatform extends PlatformInterface {
  VpnclientEngineFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static VpnclientEngineFlutterPlatform _instance =
      MethodChannelVpnclientEngineFlutter();

  static VpnclientEngineFlutterPlatform get instance => _instance;

  static set instance(VpnclientEngineFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool?> startVPN(String config) => throw UnimplementedError('startVPN() has not been implemented.');
  Future<bool?> stopVPN() => throw UnimplementedError('stopVPN() has not been implemented.');
  Future<bool?> checkVPNStatus() => throw UnimplementedError('checkVPNStatus() has not been implemented.');
  }

/*
  static dynamic _getPlatformImpl() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return AndroidNativeImpl();
    } else {
      return DefaultImpl();
    }
  }

  // В отдельном файле platforms/android.dart
  class AndroidNativeImpl {
    // Реализация для Android
  }

  // В отдельном файле platforms/default.dart
  class DefaultImpl {
    // Заглушка для других платформ
  }
*/

}

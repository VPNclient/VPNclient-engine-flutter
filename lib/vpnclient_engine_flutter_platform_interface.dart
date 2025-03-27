import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'vpnclient_engine_flutter_method_channel.dart';

abstract class VpnclientEngineFlutterPlatform extends PlatformInterface {
  /// Constructs a VpnclientEngineFlutterPlatform.
  VpnclientEngineFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static VpnclientEngineFlutterPlatform _instance = MethodChannelVpnclientEngineFlutter();

  /// The default instance of [VpnclientEngineFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelVpnclientEngineFlutter].
  static VpnclientEngineFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VpnclientEngineFlutterPlatform] when
  /// they register themselves.
  static set instance(VpnclientEngineFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

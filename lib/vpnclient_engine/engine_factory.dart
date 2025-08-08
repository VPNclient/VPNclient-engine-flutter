import 'dart:io';
import 'engine_types.dart';
import 'engines/libxray_engine.dart';
import 'engines/singbox_engine.dart';
import 'engines/v2ray_engine.dart';

/// Factory for creating VPN engines
class VpnEngineFactory {
  /// Create engine by type
  static VpnEngine? create(EngineType type) {
    switch (type) {
      case EngineType.libxray:
        return LibXrayEngine();
      case EngineType.singbox:
        return SingBoxEngine();
      case EngineType.v2ray:
        return V2RayEngine();
    }
  }
  
  /// Get all supported engines for current platform
  static List<VpnEngine> getSupportedEngines() {
    final engines = <VpnEngine>[];
    
    for (final type in EngineType.values) {
      final engine = create(type);
      if (engine != null && engine.isSupported) {
        engines.add(engine);
      }
    }
    
    return engines;
  }
  
  /// Get engine names for current platform
  static List<String> getSupportedEngineNames() {
    return getSupportedEngines().map((e) => e.name).toList();
  }
  
  /// Check if engine is supported on current platform
  static bool isEngineSupported(EngineType type) {
    final engine = create(type);
    return engine != null && engine.isSupported;
  }
} 
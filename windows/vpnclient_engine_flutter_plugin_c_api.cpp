#include "include/vpnclient_engine_flutter/vpnclient_engine_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "vpnclient_engine_flutter_plugin.h"

void VpnclientEngineFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  vpnclient_engine_flutter::VpnclientEngineFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

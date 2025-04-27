#include "vpnclient_engine_flutter_plugin.h"

#include <iostream>
#include <fstream>
// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

// Include sing-box related headers (replace with actual headers if different)
#include <string>


#pragma comment(lib, "ws2_32.lib")

namespace vpnclient_engine_flutter {

// static
void VpnclientEngineFlutterPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "vpnclient_engine_flutter",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<VpnclientEngineFlutterPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

VpnclientEngineFlutterPlugin::VpnclientEngineFlutterPlugin() {}


bool VpnclientEngineFlutterPlugin::startSingBox(std::string configPath) {
  std::cout << "Start SingBox with config: " << configPath << std::endl;

  // Check if the configuration file exists
  std::ifstream configFile(configPath);
  if (!configFile.good()) {
    std::cerr << "Error: Configuration file not found at " << configPath << std::endl;
    return false;
  }
  configFile.close();

  // Here you would typically use system() or CreateProcess()
  // to launch the sing-box executable with the specified configuration.
  // For this example, we'll just simulate launching it.
  
  std::string command = "sing-box run -c \"" + configPath + "\"";
  std::cout << "Executing command: " << command << std::endl;

  STARTUPINFOA startupInfo;
  PROCESS_INFORMATION processInfo;

  ZeroMemory(&startupInfo, sizeof(startupInfo));
  startupInfo.cb = sizeof(startupInfo);
  ZeroMemory(&processInfo, sizeof(processInfo));

  if (CreateProcessA(NULL, (LPSTR)command.c_str(), NULL, NULL, FALSE, 0, NULL, NULL, &startupInfo, &processInfo)) {
      CloseHandle(processInfo.hProcess);
      CloseHandle(processInfo.hThread);
      std::cout << "sing-box launched successfully." << std::endl;
      return true;
  } else {
      std::cerr << "Failed to start sing-box. Error code: " << GetLastError() << std::endl;
      return false;
  }

  return false; 
}

VpnclientEngineFlutterPlugin::~VpnclientEngineFlutterPlugin() {}

void VpnclientEngineFlutterPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else if (method_call.method_name().compare("startSingBox") == 0) {
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
        auto configPathIt = arguments->find(flutter::EncodableValue("configPath"));
        if (configPathIt != arguments->end()) {
            std::string configPath = std::get<std::string>(configPathIt->second);
            bool success = startSingBox(configPath);
            result->Success(flutter::EncodableValue(success));
            return;
        }
    }
  } else {
    result->NotImplemented();
  }
}

}  // namespace vpnclient_engine_flutter

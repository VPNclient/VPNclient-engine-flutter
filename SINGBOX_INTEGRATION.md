# Sing-box Integration Guide

This guide explains how to integrate sing-box with the VPN Client Engine Flutter plugin.

## 🔧 Integration Approaches

### 1. Go Mobile (gomobile) - Recommended for Android/iOS

This is the most reliable approach for mobile platforms.

#### Prerequisites:
```bash
# Install Go (if not already installed)
# Download from https://golang.org/dl/

# Install gomobile
go install golang.org/x/mobile/cmd/gomobile@latest
go install golang.org/x/mobile/cmd/gobind@latest

# Initialize gomobile
gomobile init
```

#### Steps:

1. **Create Go wrapper for sing-box:**
```go
// singbox_wrapper.go
package main

import (
    "C"
    "encoding/json"
    "fmt"
    "log"
    "os"
    "path/filepath"
    
    "github.com/sagernet/sing-box/option"
    "github.com/sagernet/sing-box/experimental/libbox"
)

//export StartSingBox
func StartSingBox(configPath *C.char) *C.char {
    configPathStr := C.GoString(configPath)
    
    // Read configuration file
    configBytes, err := os.ReadFile(configPathStr)
    if err != nil {
        return C.CString(fmt.Sprintf("error: %v", err))
    }
    
    // Parse configuration
    var config option.Options
    err = json.Unmarshal(configBytes, &config)
    if err != nil {
        return C.CString(fmt.Sprintf("error parsing config: %v", err))
    }
    
    // Create and start sing-box
    box, err := libbox.NewBox(config, nil, nil, nil, nil)
    if err != nil {
        return C.CString(fmt.Sprintf("error creating box: %v", err))
    }
    
    err = box.Start()
    if err != nil {
        return C.CString(fmt.Sprintf("error starting box: %v", err))
    }
    
    return C.CString("success")
}

//export StopSingBox
func StopSingBox() *C.char {
    // Implementation to stop sing-box
    return C.CString("stopped")
}

func main() {}
```

2. **Build for Android:**
```bash
gomobile bind -target=android -o=singbox.aar ./singbox_wrapper.go
```

3. **Build for iOS:**
```bash
gomobile bind -target=ios -o=singbox.framework ./singbox_wrapper.go
```

### 2. Network Extension (iOS) - Current Implementation

The iOS implementation already uses Network Extension with sing-box.

#### Requirements:
- Xcode with Network Extension capability
- sing-box Network Extension target
- Proper entitlements

#### Current Implementation:
```swift
// In VpnclientEngineFlutterPlugin.swift
private func startSingBox(config: String, result: @escaping FlutterResult) {
    NETunnelProviderManager.loadAllFromPreferences { managers, error in
        // ... implementation
    }
}
```

### 3. Process-based (Windows/Linux) - Current Implementation

The Windows implementation launches sing-box as a separate process.

#### Current Implementation:
```cpp
// In vpnclient_engine_flutter_plugin.cpp
bool VpnclientEngineFlutterPlugin::startSingBox(std::string configPath) {
    std::string command = "sing-box run -c \"" + configPath + "\"";
    // ... implementation
}
```

## 📱 Platform-Specific Setup

### Android

1. **Add VPN permissions to AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

2. **Add sing-box AAR to build.gradle:**
```gradle
dependencies {
    implementation files('libs/singbox.aar')
}
```

3. **Update Android plugin:**
```kotlin
// In VpnclientEngineFlutterPlugin.kt
private fun startSingBoxWithConfig(config: String, result: Result) {
    try {
        // Save config to file
        val configFile = File(context.cacheDir, "sing-box-config.json")
        FileOutputStream(configFile).use { fos ->
            fos.write(config.toByteArray())
        }
        
        // Call Go mobile bindings
        val result = Singbox.startSingBox(configFile.absolutePath)
        if (result.startsWith("success")) {
            isVpnRunning = true
            sendConnectionStatus("connected")
            result.success("Connected to VPN using sing-box")
        } else {
            result.error("SINGBOX_ERROR", result, null)
        }
    } catch (e: Exception) {
        result.error("SINGBOX_ERROR", "Failed to start sing-box", e.message)
    }
}
```

### iOS

1. **Enable Network Extension capability in Xcode**
2. **Add sing-box framework to project**
3. **Create Network Extension target**

### Windows

1. **Install sing-box executable**
2. **Add to PATH or specify full path**
3. **Run with administrator privileges**

## 🔄 Integration with Flutter Plugin

### Update Dart Interface

```dart
// In lib/vpnclient_engine_flutter.dart
abstract class VpnclientEngineFlutterPlatform {
  Future<void> connect({required String url, String? config});
  Future<void> disconnect();
  Future<String?> getPlatformVersion();
  Future<bool> requestPermissions();
  Future<String> getConnectionStatus();
}
```

### Update Platform Implementations

```dart
// In lib/platforms/android.dart
class AndroidVpnclientEngineFlutter extends VpnclientEngineFlutterPlatform {
  @override
  Future<void> connect({required String url, String? config}) async {
    // Call native Android implementation
  }
  
  @override
  Future<bool> requestPermissions() async {
    // Request VPN permissions
  }
}
```

## 🚀 Testing

### Test Configuration

```json
{
  "log": {
    "level": "info"
  },
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "interface_name": "tun0",
      "inet4_address": "172.19.0.1/30",
      "auto_route": true,
      "strict_route": true,
      "sniff": true
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ]
}
```

### Test in Flutter

```dart
// Test sing-box integration
await VPNclientEngine.connect(
  url: "sing-box://config",
  config: singBoxConfig
);
```

## 📋 Next Steps

1. **Implement Go mobile bindings**
2. **Add proper error handling**
3. **Implement VPN interface setup**
4. **Add configuration validation**
5. **Create comprehensive tests**
6. **Add documentation**

## 🔗 Resources

- [sing-box Documentation](https://sing-box.sagernet.org/)
- [Go Mobile Documentation](https://pkg.go.dev/golang.org/x/mobile)
- [Android VPN Service](https://developer.android.com/reference/android/net/VpnService)
- [iOS Network Extension](https://developer.apple.com/documentation/networkextension) 
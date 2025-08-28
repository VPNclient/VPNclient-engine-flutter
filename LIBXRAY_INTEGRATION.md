# LibXray Integration for Android

This document describes the libXray integration with vpnclient_engine_flutter for Android.

## Overview

The libXray integration provides native Xray-core functionality for Android through a Flutter plugin. This implementation uses gomobile to build the libXray Go library into an Android AAR file, which is then integrated into the Flutter plugin.

## Architecture

```
Flutter App
    ↓
VPN Client Engine Flutter Plugin
    ↓
Android Native Layer (Kotlin)
    ↓
LibXray AAR (Go + gomobile)
    ↓
Xray-core
```

## Components

### 1. LibXray AAR
- Built from the libXray Go library using gomobile
- Located at: `android/libs/libXray.aar`
- Provides Go functions accessible from Android/Kotlin

### 2. LibXrayVpnService
- Android VPN service that manages the VPN connection
- Integrates with libXray to start/stop Xray-core
- Handles socket protection and VPN interface management
- Located at: `android/src/main/kotlin/.../LibXrayVpnService.kt`

### 3. VpnclientEngineFlutterPlugin
- Main Flutter plugin class for Android
- Handles method calls from Dart and communicates with LibXrayVpnService
- Located at: `android/src/main/kotlin/.../VpnclientEngineFlutterPlugin.kt`

### 4. Android Platform Implementation
- Dart implementation that calls native Android methods
- Located at: `lib/platforms/android.dart`

### 5. LibXray Engine
- High-level Dart API for libXray functionality
- Located at: `lib/vpnclient_engine/engines/libxray_engine.dart`

## Features Implemented

### Core VPN Functionality
- ✅ Connect with Xray configuration
- ✅ Disconnect from VPN
- ✅ Get connection status
- ✅ VPN permission handling

### Additional Features
- ✅ Test Xray configuration
- ✅ Ping server with configuration
- ✅ Get libXray version
- ✅ Socket protection for Android VPN service

### Data Files
- ✅ GeoIP and GeoSite data files included in assets
- ✅ Automatic data directory setup

## Usage Example

```dart
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';

// Create libXray engine
final engine = EngineFactory.createEngine(EngineType.libxray);

// Request VPN permissions
final permissionsGranted = await engine.requestPermissions();
if (!permissionsGranted) {
  print('VPN permissions not granted');
  return;
}

// Test configuration
final configValid = await engine.testConfig(xrayConfigJson);
if (!configValid) {
  print('Invalid configuration');
  return;
}

// Connect to VPN
final connected = await engine.connect(xrayConfigJson);
if (connected) {
  print('Connected successfully');
} else {
  print('Connection failed');
}

// Check status
final status = await engine.getConnectionStatus();
print('Current status: $status');

// Disconnect
await engine.disconnect();
```

## Configuration Format

The libXray integration expects Xray configuration in JSON format. Example:

```json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 10808,
      "listen": "127.0.0.1",
      "protocol": "socks",
      "settings": {
        "udp": true
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "example.com",
            "port": 443,
            "users": [
              {
                "id": "your-uuid-here",
                "encryption": "none",
                "flow": "xtls-rprx-vision"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "serverName": "example.com",
          "allowInsecure": false
        }
      }
    }
  ]
}
```

## Android Permissions

The following permissions are required in your app's `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.BIND_VPN_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
```

## Build Requirements

### Prerequisites
- Go 1.21 or later
- gomobile tool
- Android SDK and NDK

### Building libXray AAR

1. Navigate to the libXray directory:
```bash
cd libXray
```

2. Install gomobile (if not already installed):
```bash
go install golang.org/x/mobile/cmd/gomobile@latest
export PATH=$PATH:$(go env GOPATH)/bin
gomobile init
```

3. Build the AAR:
```bash
gomobile bind -target android -androidapi 21 -o libXray.aar .
```

4. Copy to the Flutter plugin:
```bash
cp libXray.aar ../VPNclient-engine-flutter/android/libs/
```

## Files Structure

```
VPNclient-engine-flutter/
├── android/
│   ├── libs/
│   │   └── libXray.aar                    # Built libXray library
│   ├── src/main/
│   │   ├── AndroidManifest.xml            # Android manifest with permissions
│   │   ├── assets/
│   │   │   ├── geoip.dat                  # GeoIP data file
│   │   │   └── geosite.dat                # GeoSite data file
│   │   └── kotlin/.../
│   │       ├── LibXrayVpnService.kt       # VPN service implementation
│   │       └── VpnclientEngineFlutterPlugin.kt  # Main plugin class
│   └── build.gradle                       # Android build configuration
├── lib/
│   ├── platforms/
│   │   └── android.dart                   # Android platform implementation
│   └── vpnclient_engine/engines/
│       └── libxray_engine.dart            # LibXray engine implementation
└── example/
    └── lib/
        └── libxray_example.dart           # Usage example
```

## Troubleshooting

### Common Issues

1. **Build Errors**
   - Ensure Go version is compatible (1.21+)
   - Check that gomobile is properly installed and in PATH
   - Verify Android SDK and NDK are properly configured

2. **VPN Permission Issues**
   - Make sure your app requests VPN permissions properly
   - Check that `android.permission.BIND_VPN_SERVICE` is declared in manifest

3. **Connection Issues**
   - Verify Xray configuration is valid JSON
   - Check that geo data files are properly included in assets
   - Ensure the VPN service has proper foreground service permissions

4. **Service Issues**
   - Check that the LibXrayVpnService is properly declared in AndroidManifest.xml
   - Verify socket protection is working correctly

### Debugging

Enable debug logging by checking Android Studio logs for messages tagged with:
- `VpnclientEngineFlutterPlugin`
- `LibXrayVpnService`
- `AndroidVpnclientEngineFlutter`

## Future Improvements

- [ ] Implement real ping functionality using libXray
- [ ] Add traffic statistics monitoring
- [ ] Improve error handling and reporting
- [ ] Add configuration validation
- [ ] Implement connection status callbacks
- [ ] Add support for custom geo data files

## Dependencies

- libXray (Go library)
- Xray-core
- gomobile
- Android VPN API
- Flutter method channels

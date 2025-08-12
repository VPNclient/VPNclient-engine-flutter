# VPN Client Engine Flutter - Usage Examples

This document provides examples of how to use the `vpnclient_engine_flutter` library with the new instance-based API.

## Basic Usage

The library now supports both static and instance-based usage patterns. Here's how to use the new instance-based approach:

### Simple Initialization with Status Callback

```dart
class VpnState extends StatefulWidget {
  @override
  _VpnStateState createState() => _VpnStateState();
}

class _VpnStateState extends State<VpnState> {
  late VpnclientEngineFlutter _vpnEngine;
  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;

  @override
  void initState() {
    super.initState();
    _initializeVpnEngine();
  }

  void _initializeVpnEngine() {
    // Initialize VPN client engine with status callback
    _vpnEngine = VpnclientEngineFlutter(
      onStatusChanged: (status) {
        setState(() {
          _currentStatus = status;
        });
        print('VPN Status changed to: $status');
      },
    );
    
    // Initialize the engine
    _vpnEngine.initialize();
  }

  @override
  void dispose() {
    _vpnEngine.dispose();
    super.dispose();
  }

  // ... rest of your widget implementation
}
```

### Connecting to a Server

```dart
Future<void> _connectToServer() async {
  try {
    // Example configuration
    const config = '''
{
  "inbounds": [
    {
      "port": 1080,
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": true
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "vmess",
      "settings": {
        "vnext": [
          {
            "address": "your-server.com",
            "port": 443,
            "users": [
              {
                "id": "your-uuid-here",
                "alterId": 0
              }
            ]
          }
        ]
      }
    }
  ]
}
''';

    final success = await _vpnEngine.connect(EngineType.libxray, config);
    if (success) {
      print('Connection initiated successfully');
    } else {
      print('Failed to initiate connection');
    }
  } catch (e) {
    print('Error connecting: $e');
  }
}
```

### Disconnecting

```dart
Future<void> _disconnect() async {
  try {
    await _vpnEngine.disconnect();
    print('Disconnected successfully');
  } catch (e) {
    print('Error disconnecting: $e');
  }
}
```

### Testing Configuration

```dart
Future<void> _testConfiguration(String config) async {
  try {
    final isValid = await _vpnEngine.testConfig(EngineType.libxray, config);
    if (isValid) {
      print('Configuration is valid');
    } else {
      print('Configuration is invalid');
    }
  } catch (e) {
    print('Error testing configuration: $e');
  }
}
```

### Pinging a Server

```dart
Future<void> _pingServer(String config) async {
  try {
    final latency = await _vpnEngine.ping(
      EngineType.libxray, 
      config, 
      'https://www.google.com',
      timeout: 10,
    );
    
    if (latency >= 0) {
      print('Ping: ${latency}ms');
    } else {
      print('Ping failed');
    }
  } catch (e) {
    print('Error pinging: $e');
  }
}
```

### Getting Engine Information

```dart
void _getEngineInfo() {
  // Get current engine type
  final currentEngine = _vpnEngine.getCurrentEngineType();
  print('Current engine: ${currentEngine?.name ?? 'None'}');
  
  // Get supported engines
  final supportedEngines = VpnclientEngineFlutter.getSupportedEngines();
  print('Supported engines: $supportedEngines');
  
  // Check if specific engine is supported
  final isLibXraySupported = VpnclientEngineFlutter.isEngineSupported(EngineType.libxray);
  print('LibXray supported: $isLibXraySupported');
}
```

### Setting Status Callback After Initialization

```dart
void _setStatusCallback() {
  _vpnEngine.setStatusCallback((status) {
    print('Status changed to: $status');
    // Handle status change
  });
}
```

## Supported Engine Types

The library supports the following VPN engines:

- `EngineType.libxray` - LibXray engine
- `EngineType.singbox` - SingBox engine  
- `EngineType.v2ray` - V2Ray engine

## Connection Status

The library provides the following connection statuses:

- `ConnectionStatus.disconnected` - Not connected
- `ConnectionStatus.connecting` - Connecting in progress
- `ConnectionStatus.connected` - Successfully connected
- `ConnectionStatus.error` - Connection error

## Platform Support

- **iOS/macOS**: All engines supported
- **Android**: All engines supported
- **Other platforms**: Limited support

## Backward Compatibility

The library maintains backward compatibility with the static API. You can still use:

```dart
// Static methods (legacy)
await VpnclientEngineFlutter.initialize();
await VpnclientEngineFlutter.connect(EngineType.libxray, config);
await VpnclientEngineFlutter.disconnect();
```

## Complete Example

See the `example/lib/vpn_state_example.dart` file for a complete working example that demonstrates all the features of the new API.

## Error Handling

Always wrap VPN operations in try-catch blocks to handle potential errors:

```dart
try {
  await _vpnEngine.connect(EngineType.libxray, config);
} catch (e) {
  print('VPN operation failed: $e');
  // Handle error appropriately
}
```

## Resource Management

Remember to dispose of the VPN engine when you're done:

```dart
@override
void dispose() {
  _vpnEngine.dispose();
  super.dispose();
}
```

This ensures that any background timers or resources are properly cleaned up.

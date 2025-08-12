import 'package:flutter/material.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';

/// Example demonstrating the new VpnclientEngineFlutter usage pattern
class VpnStateExample extends StatefulWidget {
  const VpnStateExample({super.key});

  @override
  State<VpnStateExample> createState() => _VpnStateExampleState();
}

class _VpnStateExampleState extends State<VpnStateExample> {
  late VpnclientEngineFlutter _vpnEngine;
  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;
  String _statusText = 'Disconnected';
  bool _isConnecting = false;

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
          _statusText = _getStatusText(status);
          _isConnecting = status == ConnectionStatus.connecting;
        });
        
        // Log status changes
        print('VPN Status changed to: $status');
      },
    );
    
    // Initialize the engine
    _vpnEngine.initialize();
  }

  String _getStatusText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.error:
        return 'Error';
      case ConnectionStatus.disconnected:
      default:
        return 'Disconnected';
    }
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.error:
        return Colors.red;
      case ConnectionStatus.disconnected:
      default:
        return Colors.grey;
    }
  }

  Future<void> _connect() async {
    try {
      // Example configuration (you would use your actual config)
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
            "address": "example.com",
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection initiated')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _disconnect() async {
    try {
      await _vpnEngine.disconnect();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error disconnecting: $e')),
      );
    }
  }

  Future<void> _testConfig() async {
    try {
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
            "address": "example.com",
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

      final isValid = await _vpnEngine.testConfig(EngineType.libxray, config);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isValid ? 'Configuration is valid' : 'Configuration is invalid'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error testing config: $e')),
      );
    }
  }

  Future<void> _pingServer() async {
    try {
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
            "address": "example.com",
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

      final latency = await _vpnEngine.ping(EngineType.libxray, config, 'https://www.google.com');
      if (latency >= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ping: ${latency}ms')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ping failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error pinging: $e')),
      );
    }
  }

  @override
  void dispose() {
    _vpnEngine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VPN State Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getStatusColor(_currentStatus),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _statusText,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Engine: ${_vpnEngine.getCurrentEngineType()?.name ?? 'None'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Control Buttons
            ElevatedButton.icon(
              onPressed: _currentStatus == ConnectionStatus.connected || _isConnecting
                  ? null
                  : _connect,
              icon: const Icon(Icons.power_settings_new),
              label: const Text('Connect'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _currentStatus == ConnectionStatus.connected
                  ? _disconnect
                  : null,
              icon: const Icon(Icons.stop),
              label: const Text('Disconnect'),
            ),
            const SizedBox(height: 24),

            // Utility Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _testConfig,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Test Config'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pingServer,
                    icon: const Icon(Icons.speed),
                    label: const Text('Ping'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Engine Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supported Engines',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...VpnclientEngineFlutter.getSupportedEngines().map(
                      (engine) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(engine),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Usage Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usage Example',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '''
VpnState() {
  VpnclientEngineFlutter(
    onStatusChanged: (status) {
      // Handle status changes here
      print('VPN Status: \$status');
    }
  ).initialize();
}
''',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

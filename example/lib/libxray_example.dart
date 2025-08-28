import 'package:flutter/material.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';

class LibXrayExample extends StatefulWidget {
  const LibXrayExample({Key? key}) : super(key: key);

  @override
  State<LibXrayExample> createState() => _LibXrayExampleState();
}

class _LibXrayExampleState extends State<LibXrayExample> {
  bool _isConnected = false;
  bool _isConnecting = false;
  String _status = 'Disconnected';
  String _version = 'Unknown';

  // Sample Xray configuration (VLESS with TLS)
  final String _sampleConfig = '''
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
''';

  @override
  void initState() {
    super.initState();
    _initializeLibXray();
  }

  Future<void> _initializeLibXray() async {
    try {
      // Get LibXray version
      final engine = EngineFactory.createEngine(EngineType.libxray);
      final version = await engine.getVersion();
      
      setState(() {
        _version = version;
      });
    } catch (e) {
      debugPrint('Error initializing LibXray: \$e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final engine = EngineFactory.createEngine(EngineType.libxray);
      final granted = await engine.requestPermissions();
      
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('VPN permissions not granted'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('VPN permissions granted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error requesting permissions: \$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testConfig() async {
    try {
      final engine = EngineFactory.createEngine(EngineType.libxray);
      final isValid = await engine.testConfig(_sampleConfig);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isValid ? 'Configuration is valid' : 'Configuration is invalid'),
          backgroundColor: isValid ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error testing config: \$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pingServer() async {
    try {
      final engine = EngineFactory.createEngine(EngineType.libxray);
      final latency = await engine.ping(_sampleConfig, 'https://www.google.com');
      
      if (latency > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ping successful: \${latency}ms'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ping failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error pinging server: \$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _connect() async {
    setState(() {
      _isConnecting = true;
      _status = 'Connecting...';
    });

    try {
      final engine = EngineFactory.createEngine(EngineType.libxray);
      final success = await engine.connect(_sampleConfig);
      
      setState(() {
        _isConnected = success;
        _isConnecting = false;
        _status = success ? 'Connected' : 'Connection failed';
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connected successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isConnecting = false;
        _status = 'Connection error';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: \$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disconnect() async {
    try {
      final engine = EngineFactory.createEngine(EngineType.libxray);
      await engine.disconnect();
      
      setState(() {
        _isConnected = false;
        _status = 'Disconnected';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disconnected successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Disconnect error: \$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LibXray Integration'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LibXray Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Version: \$_version'),
                    Text('Status: \$_status'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.wifi : Icons.wifi_off,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isConnected ? 'Connected' : 'Disconnected',
                          style: TextStyle(
                            color: _isConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestPermissions,
              child: const Text('Request VPN Permissions'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testConfig,
              child: const Text('Test Configuration'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pingServer,
              child: const Text('Ping Server'),
            ),
            const SizedBox(height: 16),
            if (_isConnecting)
              const Center(child: CircularProgressIndicator())
            else if (_isConnected)
              ElevatedButton(
                onPressed: _disconnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Disconnect'),
              )
            else
              ElevatedButton(
                onPressed: _connect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Connect'),
              ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuration Preview',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _sampleConfig,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

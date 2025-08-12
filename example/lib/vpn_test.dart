import 'package:flutter/material.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';

/// Simple test page for new VPN architecture
class VpnTestPage extends StatefulWidget {
  const VpnTestPage({super.key});

  @override
  State<VpnTestPage> createState() => _VpnTestPageState();
}

class _VpnTestPageState extends State<VpnTestPage> {
  String _platformVersion = 'Unknown';
  List<String> _supportedEngines = [];
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get platform version
      final version = await VpnclientEngineFlutter.getPlatformVersion();
      setState(() {
        _platformVersion = version ?? 'Unknown';
      });

      // Get supported engines
      final engines = VpnclientEngineFlutter.getSupportedEngines();
      setState(() {
        _supportedEngines = engines;
      });

      // Check engine support
      for (final engineType in EngineType.values) {
        final isSupported = VpnclientEngineFlutter.isEngineSupported(engineType);
        print('${engineType.name}: ${isSupported ? 'Supported' : 'Not supported'}');
      }

    } catch (e) {
      print('Error initializing: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testEngine(EngineType engineType) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get engine version
      final version = await VpnclientEngineFlutter.getVersion(engineType);
      
      // Request permissions
      final permissions = await VpnclientEngineFlutter.requestPermissions(engineType);
      
      // Test connection status
      final status = await VpnclientEngineFlutter.getConnectionStatus();
      
      setState(() {
        _connectionStatus = status;
      });

      _showSnackBar('$engineType: Version=$version, Permissions=$permissions, Status=$status');
      
    } catch (e) {
      _showSnackBar('Error testing $engineType: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VPN Architecture Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Info',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Platform: $_platformVersion'),
                    Text('Supported Engines: ${_supportedEngines.join(', ')}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Engine Tests
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Engine Tests',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    // LibXray Test
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _testEngine(EngineType.libxray),
                        icon: const Icon(Icons.rocket_launch),
                        label: const Text('Test LibXray'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // SingBox Test
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _testEngine(EngineType.singbox),
                        icon: const Icon(Icons.settings),
                        label: const Text('Test SingBox'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // V2Ray Test
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _testEngine(EngineType.v2ray),
                        icon: const Icon(Icons.cloud),
                        label: const Text('Test V2Ray'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Connection Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Status: $_connectionStatus'),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 
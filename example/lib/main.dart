import 'package:flutter/material.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine/engine.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VPN Client Engine Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const VPNClientDemo(),
    );
  }
}

class VPNClientDemo extends StatefulWidget {
  const VPNClientDemo({super.key});

  @override
  VPNClientDemoState createState() => VPNClientDemoState();
}

class VPNClientDemoState extends State<VPNClientDemo> {
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  String _currentServer = 'Not Connected';
  List<Server> _servers = [];
  List<String> _loadedSubscriptions = [];
  SessionStatistics _sessionStatistics = SessionStatistics(
    dataInBytes: 0,
    dataOutBytes: 0,
  );
  bool _isLoading = false;

  final TextEditingController _subscriptionUrlController = TextEditingController();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initializeEngine();
  }

  void _initializeEngine() {
    VPNclientEngine.initialize();
    VPNclientEngine.onConnectionStatusChanged.listen(_updateConnectionStatus);
    VPNclientEngine.onPingResult.listen(_updatePingResult);
    VPNclientEngine.onDataUsageUpdated.listen(_updateSessionStatistics);
  }

  void _updateConnectionStatus(ConnectionStatus status) {
    setState(() {
      _connectionStatus = status;
    });
  }

  void _updatePingResult(PingResult result) {
    // Update server latency in the list
    setState(() {
      if (result.serverIndex < _servers.length) {
        // Create a new Server instance with updated latency
        _servers[result.serverIndex] = Server(
          address: _servers[result.serverIndex].address,
          latency: result.latencyInMs,
          location: _servers[result.serverIndex].location,
          isPreferred: _servers[result.serverIndex].isPreferred,
        );
      }
    });
  }

  void _updateSessionStatistics(SessionStatistics stats) {
    setState(() {
      _sessionStatistics = stats;
    });
  }

  Future<void> _loadSubscription() async {
    if (_subscriptionUrlController.text.isEmpty) {
      _showSnackBar('Please enter a subscription URL');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await VPNclientEngine.loadSubscriptions(
        subscriptionLinks: [_subscriptionUrlController.text],
      );
      
      setState(() {
        _loadedSubscriptions.add(_subscriptionUrlController.text);
        _subscriptionUrlController.clear();
      });
      
      await _refreshServers();
      _showSnackBar('Subscription loaded successfully');
    } catch (e) {
      _showSnackBar('Failed to load subscription: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshServers() async {
    setState(() {
      _servers = VPNclientEngine.getServerList();
    });
  }

  Future<void> _connectToServer(int serverIndex) async {
    if (_loadedSubscriptions.isEmpty) {
      _showSnackBar('Please load a subscription first');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await VPNclientEngine.connect(subscriptionIndex: 0, serverIndex: serverIndex);
      setState(() {
        _currentServer = _servers[serverIndex].address;
      });
      _showSnackBar('Connecting to ${_servers[serverIndex].address}');
    } catch (e) {
      _showSnackBar('Failed to connect: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _disconnect() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await VPNclientEngine.disconnect();
      setState(() {
        _currentServer = 'Not Connected';
      });
      _showSnackBar('Disconnected');
    } catch (e) {
      _showSnackBar('Failed to disconnect: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _pingServer(int serverIndex) {
    VPNclientEngine.pingServer(subscriptionIndex: 0, index: serverIndex);
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
        title: const Text('VPN Client Engine'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: PageView(
        controller: _pageController,
        children: [
          _buildHomePage(),
          _buildServersPage(),
          _buildSettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) => _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Servers'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Connection Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStatusColor(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentServer,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Connection Controls
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _connectionStatus == ConnectionStatus.connected 
                    ? null 
                    : _isLoading 
                      ? null 
                      : () => _connectToServer(0),
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text('Connect'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _connectionStatus == ConnectionStatus.connected 
                    ? _disconnect 
                    : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Disconnect'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Statistics Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Statistics',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow('Duration', _formatDuration(_sessionStatistics.sessionDuration)),
                  _buildStatRow('Data In', _formatBytes(_sessionStatistics.dataInBytes)),
                  _buildStatRow('Data Out', _formatBytes(_sessionStatistics.dataOutBytes)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Subscription Management
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscription Management',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _subscriptionUrlController,
                    decoration: const InputDecoration(
                      hintText: 'Enter subscription URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loadSubscription,
                      child: _isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Load Subscription'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServersPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Servers',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton.icon(
                onPressed: _refreshServers,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_servers.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No servers available',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Load a subscription to see available servers',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _servers.length,
                itemBuilder: (context, index) {
                  final server = _servers[index];
                  final isConnected = _currentServer == server.address;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        isConnected ? Icons.check_circle : Icons.cloud,
                        color: isConnected ? Colors.green : null,
                      ),
                      title: Text(server.address),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (server.location != null)
                            Text('Location: ${server.location}'),
                          if (server.latency != null)
                            Text('Latency: ${server.latency}ms'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _pingServer(index),
                            icon: const Icon(Icons.speed),
                            tooltip: 'Ping Server',
                          ),
                          IconButton(
                            onPressed: isConnected 
                              ? null 
                              : () => _connectToServer(index),
                            icon: Icon(
                              isConnected ? Icons.check : Icons.power_settings_new,
                            ),
                            tooltip: isConnected ? 'Connected' : 'Connect',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.auto_awesome),
                  title: const Text('Auto Connect'),
                  subtitle: const Text('Automatically connect on app launch'),
                  trailing: Switch(
                    value: false, // TODO: Implement state management
                    onChanged: (value) {
                      VPNclientEngine.setAutoConnect(enable: value);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Kill Switch'),
                  subtitle: const Text('Block internet when VPN disconnects'),
                  trailing: Switch(
                    value: false, // TODO: Implement state management
                    onChanged: (value) {
                      VPNclientEngine.setKillSwitch(enable: value);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.route),
                  title: const Text('Routing Rules'),
                  subtitle: const Text('Configure app and domain routing'),
                  onTap: () => _showRoutingRulesDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_connectionStatus) {
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

  String _getStatusText() {
    switch (_connectionStatus) {
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

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _showRoutingRulesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Routing Rules'),
        content: const Text('Routing rules configuration will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

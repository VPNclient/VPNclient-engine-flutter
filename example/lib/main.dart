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
      theme: ThemeData(primarySwatch: Colors.blue),
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
  String _pingResult = 'Not Pinging';
  List<RoutingRule> _routingRules = [];
  List<Server> _servers = [];
  SessionStatistics _sessionStatistics = SessionStatistics(
    dataInBytes: 0,
    dataOutBytes: 0,
  );

  final TextEditingController _subscriptionUrlController =
      TextEditingController();
  final List<String> _loadedSubscriptions = [];

  @override
  void initState() {
    super.initState();
    VPNclientEngine.initialize();
    VPNclientEngine.onConnectionStatusChanged.listen(_updateConnectionStatus);
    VPNclientEngine.onPingResult.listen(_updatePingResult);
    VPNclientEngine.onRoutingRulesApplied.listen(_updateRoutingRules);
    VPNclientEngine.onDataUsageUpdated.listen(_updateSessionStatistics);
  }

  void _updateConnectionStatus(ConnectionStatus status) {
    setState(() {
      _connectionStatus = status;
    });
  }

  void _updatePingResult(PingResult result) {
    setState(() {
      _pingResult =
          'Ping: sub=${result.subscriptionIndex}, server=${result.serverIndex}, latency=${result.latencyInMs} ms';
    });
  }

  void _updateRoutingRules(List<RoutingRule> rules) {
    setState(() {
      _routingRules = rules;
    });
  }

  void _updateSessionStatistics(SessionStatistics stats) {
    setState(() {
      _sessionStatistics = stats;
    });
  }

  void _connectToServer() async {
    await VPNclientEngine.connect(subscriptionIndex: 0, serverIndex: 0);
    setState(() {
      _currentServer = 'Connecting...';
    });
  }

  void _disconnectFromServer() async {
    await VPNclientEngine.disconnect();
    setState(() {
      _currentServer = 'Not Connected';
    });
  }

  void _pingServer() {
    VPNclientEngine.pingServer(subscriptionIndex: 0, index: 0);
    setState(() {
      _pingResult = 'Pinging...';
    });
  }

  void _loadServers() {
    _servers = VPNclientEngine.getServerList();
    setState(() {});
  }

  void _applyRoutingRules() {
    List<RoutingRule> rules = [
      RoutingRule(appName: "YouTube", action: "proxy"),
      RoutingRule(appName: "google.com", action: "direct"),
      RoutingRule(domain: "ads.com", action: "block"),
    ];
    VPNclientEngine.setRoutingRules(rules: rules);
  }

  void _loadSubscription() async {
    if (_subscriptionUrlController.text.isEmpty) return;

    setState(() {
      _loadedSubscriptions.add(_subscriptionUrlController.text);
    });
    await VPNclientEngine.loadSubscriptions(
      subscriptionLinks: [_subscriptionUrlController.text],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VPN Client Engine Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Connection Status: $_connectionStatus'),
            Text('Current Server: $_currentServer'),
            Text(_pingResult),
            ElevatedButton(
              onPressed: _connectToServer,
              child: const Text('Connect'),
            ),
            ElevatedButton(
              onPressed: _disconnectFromServer,
              child: const Text('Disconnect'),
            ),
            const SizedBox(height: 20),
            Text('Session Statistics'),
            Text('Session Duration: ${_sessionStatistics.sessionDuration}'),
            Text('Data In: ${_sessionStatistics.dataInBytes} bytes'),
            Text('Data Out: ${_sessionStatistics.dataOutBytes} bytes'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pingServer,
              child: const Text('Ping Server'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadServers,
              child: const Text('Load Servers'),
            ),
            const SizedBox(height: 10),
            Text('Loaded Servers:'),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _servers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_servers[index].address),
                  subtitle: Text(
                    'Latency: ${_servers[index].latency ?? 'N/A'}, Location: ${_servers[index].location ?? 'N/A'}',
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _applyRoutingRules,
              child: const Text('Apply Routing Rules'),
            ),
            const SizedBox(height: 10),
            Text('Routing Rules Applied:'),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _routingRules.length,
              itemBuilder: (context, index) {
                final rule = _routingRules[index];
                return ListTile(
                  title: Text('Rule ${index + 1}'),
                  subtitle: Text(
                    'App Name: ${rule.appName ?? 'N/A'}, Domain: ${rule.domain ?? 'N/A'}, Action: ${rule.action}',
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text('Load Subscription'),
            TextField(
              controller: _subscriptionUrlController,
              decoration: const InputDecoration(
                hintText: 'Enter subscription URL',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadSubscription,
              child: const Text('Load Subscription'),
            ),
            const SizedBox(height: 10),
            Text('Loaded Subscriptions:'),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _loadedSubscriptions.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(_loadedSubscriptions[index]));
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                VPNclientEngine.setAutoConnect(enable: true);
              },
              child: const Text('Enable auto connect'),
            ),
            ElevatedButton(
              onPressed: () {
                VPNclientEngine.setAutoConnect(enable: false);
              },
              child: const Text('Disable auto connect'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                VPNclientEngine.setKillSwitch(enable: true);
              },
              child: const Text('Enable kill switch'),
            ),
            ElevatedButton(
              onPressed: () {
                VPNclientEngine.setKillSwitch(enable: false);
              },
              child: const Text('Disable kill switch'),
            ),
          ],
        ),
      ),
    );
  }
}

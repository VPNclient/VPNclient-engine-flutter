import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';


enum ConnectionStatus { connecting, connected, disconnected, error }

class SessionStatistics {
  final Duration sessionDuration;
  final int dataInBytes;
  final int dataOutBytes;

  SessionStatistics({
    required this.sessionDuration,
    required this.dataInBytes,
    required this.dataOutBytes,
  });
}

class RoutingRule {
  final String? appName;
  final String? domain;
  final String action; // proxy, direct, block

  RoutingRule({this.appName, this.domain, required this.action});
}

class PingResult {
  final int latencyInMs;
  PingResult(this.latencyInMs);
}

class VPNclientEngine {
  static List<List<String>> _subscriptionServers = [];

  static String setTitle(int x) {
    switch (x) {
      case 1:
        return 'Super HIT';
      case 2:
        return 'VPNClient';
    }
    return 'Hello from backend!';
  }


  static final StreamController<ConnectionStatus> _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();
  static final StreamController<PingResult> _pingResultController =
      StreamController<PingResult>.broadcast();

  static List<String> _subscriptions = [];


  static void initialize() {
    print('VPNclient Engine initialized');
  }

  static void ClearSubscriptions() {
    _subscriptions.clear();
    print('All subscriptions cleared');
  }

  static void addSubscription({required String subscriptionURL}) {
    _subscriptions.add(subscriptionURL);
    print('Subscription added: $subscriptionURL');
  }

  static void addSubscriptions({required List<String> subscriptionURLs}) {
    _subscriptions.addAll(subscriptionURLs);
    print('Subscriptions added: ${subscriptionURLs.join(", ")}');
  }

  static Future<void> updateSubscription({required int subscriptionIndex}) async {
    if (subscriptionIndex < 0 || subscriptionIndex >= _subscriptions.length) {
      print('Invalid subscription index');
      return;
    }

    final url = _subscriptions[subscriptionIndex];
    print('Fetching subscription data from: $url');

    try {
      //Сейчас при поднятом VPN обновление подписки пойдет через туннель. Позже необходимо реализовать разные механизмы обновления (только через туннель/только напрямую/комбинированный)
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        print('Failed to fetch subscription: HTTP ${response.statusCode}');
        return;
      }

      final content = response.body.trim();

      List<String> servers = [];

      if (content.startsWith('[')) {
        // JSON format
        final jsonList = jsonDecode(content) as List<dynamic>;
        for (var server in jsonList) {
          servers.add(server.toString());
        }
        print('Parsed JSON subscription: ${servers.length} servers loaded');
      } else {
        // NEWLINE format
        servers = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
        print('Parsed NEWLINE subscription: ${servers.length} servers loaded');
      }

      // Ensure the servers list matches the subscriptions list size
      while (_subscriptionServers.length <= subscriptionIndex) {
        _subscriptionServers.add([]);
      }

      // Save fetched servers to specific subscription index
      _subscriptionServers[subscriptionIndex] = servers;

      print('Subscription #$subscriptionIndex servers updated successfully');
    } catch (e) {
      print('Error updating subscription: $e');
    }
  }

  static Stream<ConnectionStatus> get onConnectionStatusChanged => _connectionStatusController.stream;
  static Stream<PingResult> get onPingResult => _pingResultController.stream;

  static Future<void> connect({required int subscriptionIndex, required int serverIndex}) async {
    print('Connecting to subscription $subscriptionIndex, server $serverIndex...');
    _connectionStatusController.add(ConnectionStatus.connecting);
    await Future.delayed(Duration(seconds: 5));
    _connectionStatusController.add(ConnectionStatus.connected);
    print('Successfully connected');
  }

  static Future<void> disconnect() async {
    _connectionStatusController.add(ConnectionStatus.disconnected);
    print('Disconnected successfully');
  }

  static void setRoutingRules({required List<RoutingRule> rules}) {
    for (var rule in rules) {
      if (rule.appName != null) {
        print('Routing rule for app ${rule.appName}: ${rule.action}');
      } else if (rule.domain != null) {
        print('Routing rule for domain ${rule.domain}: ${rule.action}');
      }
    }
  }

  static void pingServer({required int subscriptionIndex, required int index}) async {
    if (subscriptionIndex < 0 || subscriptionIndex >= _subscriptionServers.length) {
      print('Invalid subscription index');
      return;
    }

    if (index < 0 || index >= _subscriptionServers[subscriptionIndex].length) {
      print('Invalid server index');
      return;
    }

    final serverAddress = _subscriptionServers[subscriptionIndex][index];
    print('Pinging server: $serverAddress');

    try {
      final ping = Ping(serverAddress, count: 3);
      final pingData = await ping.stream.firstWhere((data) => data.response != null);

      if (pingData.response != null) {
        final latency = pingData.response!.time!.inMilliseconds;
        final result = PingResult(latency);
        _pingResultController.add(result);
        print('Ping result: ${result.latencyInMs} ms');
      } else {
        print('Ping failed: No response');
        _pingResultController.add(PingResult(-1)); // Indicate error with -1
      }
    } catch (e) {
      print('Ping error: $e');
      _pingResultController.add(PingResult(-1));
    }
  }
}

void main() async {
  // Initialize the Engine
  VPNclientEngine.initialize();

  // Clear subscriptions
  VPNclientEngine.ClearSubscriptions();

  // Add subscription
  VPNclientEngine.addSubscription(subscriptionURL: "https://pastebin.com/raw/ZCYiJ98W");
  //VPNclientEngine.addSubscriptions(subscriptionURLs: ["https://pastebin.com/raw/ZCYiJ98W"]);

  // Update subscription
  await VPNclientEngine.updateSubscription(subscriptionIndex: 0);

  // Listen for connection status changes
  VPNclientEngine.onConnectionStatusChanged.listen((status) {
    print("Connection status: $status");
  });

  //Connect to server 1
  await VPNclientEngine.connect(subscriptionIndex: 0, serverIndex: 1);

  // Set routing rules
  VPNclientEngine.setRoutingRules(
    rules: [
      RoutingRule(appName: "YouTube", action: "proxy"),
      RoutingRule(appName: "google.com", action: "direct"),
      RoutingRule(domain: "ads.com", action: "block"),
    ],
  );

  // Ping a server
  VPNclientEngine.pingServer(subscriptionIndex: 0, index: 1);

  VPNclientEngine.onPingResult.listen((result) {
    print("Ping result: ${result.latencyInMs} ms");
  });

  await Future.delayed(Duration(seconds: 10));

  //Disconnect
  await VPNclientEngine.disconnect();
}
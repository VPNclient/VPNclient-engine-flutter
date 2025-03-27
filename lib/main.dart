import 'dart:async';
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
    print('Updating subscription at index $subscriptionIndex');
    await Future.delayed(Duration(seconds: 3));
    print('Subscription updated successfully');
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
    print('Pinging server at subscription $subscriptionIndex, server index $index...');
    await Future.delayed(Duration(seconds: 1));
    final result = PingResult(123);
    _pingResultController.add(result);
    print('Ping result: ${result.latencyInMs} ms');
  }
}

void main() async {
  // Initialize the Engine
  VPNclientEngine.initialize();

  // Clear subscriptions
  VPNclientEngine.ClearSubscriptions();

  // Add subscription
  VPNclientEngine.addSubscription(subscriptionURL: ["https://pastebin.com/raw/ZCYiJ98W"]);

  // Update subscription
  await VPNclientEngine.updateSubscription(subscriptionIndex: 0);

  // Listen for connection status changes
  VPNclientEngine.onConnectionStatusChanged.listen((status) {
    print("Connection status: $status");
  });

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

  await VPNclientEngine.disconnect();
}
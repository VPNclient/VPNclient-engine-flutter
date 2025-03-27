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

  static Future<void> connect() async {
    print('Команда на подключение отправлена');
    await Future.delayed(Duration(seconds: 5));
    print('Успешное подключение');
  }

  static Future<void> disconnect() async {
    print('Успешное отключение');
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
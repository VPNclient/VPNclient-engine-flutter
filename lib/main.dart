import 'dart:async';
import 'vpnclient_engine.dart';



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
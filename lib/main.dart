import 'dart:async';
import 'dart:developer';

import 'package:vpnclient_engine_flutter/client/engine.dart';

void main() async {
  VPNclientEngine.initialize();
  VPNclientEngine.clearSubscriptions();
  VPNclientEngine.addSubscription(
    subscriptionURL: "https://pastebin.com/raw/ZCYiJ98W",
  );
  await VPNclientEngine.updateSubscription(subscriptionIndex: 0);

  VPNclientEngine.onConnectionStatusChanged.listen((status) {
    log("Connection status: $status");
  });

  await VPNclientEngine.connect(subscriptionIndex: 0, serverIndex: 1);

  VPNclientEngine.setRoutingRules(
    rules: [
      RoutingRule(appName: "YouTube", action: "proxy"),
      RoutingRule(appName: "google.com", action: "direct"),
      RoutingRule(domain: "ads.com", action: "block"),
    ],
  );

  VPNclientEngine.pingServer(subscriptionIndex: 0, index: 1);

  VPNclientEngine.onPingResult.listen((result) {
    log("Ping result: ${result.latencyInMs} ms");
  });

  await Future.delayed(Duration(seconds: 10));

  await VPNclientEngine.disconnect();
}

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dart_ping/dart_ping.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter_platform_interface.dart';

///
import 'package:flutter_v2ray/flutter_v2ray.dart';

///

final FlutterV2ray flutterV2ray = FlutterV2ray(
  onStatusChanged: (status) {
    // do something
  },
);

///

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


      ///
      // You must initialize V2Ray before using it.
      print('Initializing...');
      await flutterV2ray.initializeV2Ray();

      // v2ray share link like vmess://, vless://, ...
      String link =
          //"vless://c61daf3e-83ff-424f-a4ff-5bfcb46f0b30@5.35.98.91:8443?encryption=none&flow=&security=reality&sni=yandex.ru&fp=chrome&pbk=rLCmXWNVoRBiknloDUsbNS5ONjiI70v-BWQpWq0HCQ0&sid=108108108108#%F0%9F%87%B7%F0%9F%87%BA+%F0%9F%99%8F+Russia+%231";
          "vless://c61daf3e-83ff-424f-a4ff-5bfcb46f0b30@45.77.190.146:8443?encryption=none&flow=&security=reality&sni=www.gstatic.com&fp=chrome&pbk=rLCmXWNVoRBiknloDUsbNS5ONjiI70v-BWQpWq0HCQ0&sid=108108108108#%F0%9F%87%BA%F0%9F%87%B8+%F0%9F%99%8F+USA+%231";
      V2RayURL parser = FlutterV2ray.parseFromURL(link);

      // Get Server Delay
      //print(
      //  '${flutterV2ray.getServerDelay(config: parser.getFullConfiguration())}ms',
      //  name: 'ServerDelay',
      //);

      // Permission is not required if you using proxy only
      print('Premissions...');
      if (await flutterV2ray.requestPermission()) {
        print('Starting...');
        flutterV2ray.startV2Ray(
          remark: parser.remark,
          // The use of parser.getFullConfiguration() is not mandatory,
          // and you can enter the desired V2Ray configuration in JSON format
          config: parser.getFullConfiguration(),
          blockedApps: null,
          bypassSubnets: null,
          proxyOnly: false,
        );
        print('Started');
      }

      // Disconnect
      ///flutterV2ray.stopV2Ray();

      ///

      //TODO:move to right place


    
    
    
    print(await VpnclientEngineFlutterPlatform.instance.getPlatformVersion());

    print('Connecting to subscription $subscriptionIndex, server $serverIndex...');
    _connectionStatusController.add(ConnectionStatus.connecting);

    print(await VpnclientEngineFlutterPlatform.instance.getPlatformVersion());

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
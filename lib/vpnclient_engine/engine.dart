import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dart_ping/dart_ping.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine/server_connection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';


enum ConnectionStatus {
  connecting,
  connected,
  disconnected,
  error,
}

enum ErrorCode {
  invalidCredentials,
  serverUnavailable,
  subscriptionExpired,
  unknownError,
}

enum ProxyType {
  socks5,
  http,
}

enum Action {
  block,
  allow,
  routeThroughVPN,
  direct,
  proxy,
}

class Server {
  final String address;
  final int? latency;
  final String? location;
  final bool? isPreferred;

  Server({
    required this.address,
    this.latency,
    this.location,
    this.isPreferred,
  });
}

class SubscriptionDetails {
  final DateTime? expiryDate;
  final int? dataLimit;
  final int? usedData;

  SubscriptionDetails({
    this.expiryDate,
    this.dataLimit,
    this.usedData,
  });
}

class SessionStatistics {
  final Duration? sessionDuration;
  final int dataInBytes;
  final int dataOutBytes;

  SessionStatistics({
    this.sessionDuration,
    required this.dataInBytes,
    required this.dataOutBytes,
  });
}

class ErrorDetails {
  final ErrorCode errorCode;
  final String errorMessage;

  ErrorDetails({required this.errorCode, required this.errorMessage});
}

class ProxyConfig {
  final ProxyType type;
  final String address;
  final int port;
  final String? credentials;

  ProxyConfig({
    required this.type,
    required this.address,
    required this.port,
    this.credentials,
  });
}

class PingResult {
  final int subscriptionIndex;
  final int serverIndex;
  final int latencyInMs;

  PingResult({
    required this.subscriptionIndex,
    required this.serverIndex,
    required this.latencyInMs,
  });
}

class RoutingRule {
  final String? appName;
  final String? domain;
  final String action; // proxy, direct, block

  RoutingRule({this.appName, this.domain, required this.action});

}




final FlutterV2ray flutterV2ray = FlutterV2ray(
    onStatusChanged: (status) {
      print("status changed: $status");
    },

  );
class VPNclientEngine {
  static List<List<String>> _subscriptionServers = [];
  static Map<int, ServerConnection> _connections = {};
  static List<String> _subscriptions = [];



  static final _connectionStatusSubject = BehaviorSubject<ConnectionStatus>();
  static Stream<ConnectionStatus> get onConnectionStatusChanged => _connectionStatusSubject.stream;

  static final _errorSubject = BehaviorSubject<ErrorDetails>();
  static Stream<ErrorDetails> get onError => _errorSubject.stream;

  static final _serverSwitchedSubject = BehaviorSubject<String>();
  static Stream<String> get onServerSwitched => _serverSwitchedSubject.stream;

  static final _pingResultSubject = BehaviorSubject<PingResult>();
  static Stream<PingResult> get onPingResult => _pingResultSubject.stream;

  static final _subscriptionLoadedSubject = BehaviorSubject<SubscriptionDetails>();
  static Stream<SubscriptionDetails> get onSubscriptionLoaded => _subscriptionLoadedSubject.stream;

  static final _dataUsageUpdatedSubject = BehaviorSubject<SessionStatistics>();
  static Stream<SessionStatistics> get onDataUsageUpdated => _dataUsageUpdatedSubject.stream;

  static final _routingRulesAppliedSubject = BehaviorSubject<List<RoutingRule>>();
  static Stream<List<RoutingRule>> get onRoutingRulesApplied => _routingRulesAppliedSubject.stream;

  static final _killSwitchTriggeredSubject = BehaviorSubject<void>();
  static Stream<void> get onKillSwitchTriggered => _killSwitchTriggeredSubject.stream;


  static void _emitError(ErrorCode code, String message) {
    _errorSubject.add(ErrorDetails(errorCode: code, errorMessage: message));
  }


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
      _subscriptionLoadedSubject.add(SubscriptionDetails());

      print('Subscription #$subscriptionIndex servers updated successfully');
    } catch (e) {
      print('Error updating subscription: $e');
      _emitError(ErrorCode.unknownError, 'Error updating subscription: $e');
    }
  }

  static Future<void> connect({required int subscriptionIndex, required int serverIndex}) async {
    print('Connecting to subscription $subscriptionIndex, server $serverIndex...');

    if (subscriptionIndex < 0 || subscriptionIndex >= _subscriptionServers.length) {
      _emitError(ErrorCode.unknownError, 'Invalid subscription index');
      return;
    }

    if (serverIndex < 0 || serverIndex >= _subscriptionServers[subscriptionIndex].length) {
      _emitError(ErrorCode.unknownError, 'Invalid server index');
      return;
    }

    _connectionStatusSubject.add(ConnectionStatus.connecting);
    VpnclientEngineFlutterPlatform.instance.connect(subscriptionIndex: subscriptionIndex, serverIndex: serverIndex).then((_) {
      _connectionStatusSubject.add(ConnectionStatus.connected);
    }).catchError((error) {
      _connectionStatusSubject.add(ConnectionStatus.error);
      _emitError(ErrorCode.unknownError, 'Error on connect: $error');
    });

    //Get server info
    String link = _subscriptionServers[subscriptionIndex][serverIndex];
    V2RayURL parser = FlutterV2ray.parseFromURL(link);
    _serverSwitchedSubject.add(parser.remark ?? "null");

    print('Connecting to server: $link');
  }

  static Future<void> disconnect() async {
    print('Disconnecting...');

    if(_connections.isEmpty){
      print('Noting to disconnect.');
      _connectionStatusSubject.add(ConnectionStatus.disconnected);
      return;
    }
    
    VpnclientEngineFlutterPlatform.instance.disconnect().then((_) {
      _connectionStatusSubject.add(ConnectionStatus.disconnected);
    }).catchError((error) {
      _connectionStatusSubject.add(ConnectionStatus.error);
      _emitError(ErrorCode.unknownError, 'Error on disconnect: $error');
    });
/*
    try {
        
        await flutterV2ray.stopV2Ray();
        _connections.clear();
        _connectionStatusSubject.add(ConnectionStatus.disconnected);

    } catch (e) {
        _connectionStatusSubject.add(ConnectionStatus.error);
        _emitError(ErrorCode.unknownError, 'Error disconnecting: $e');
        print('Error disconnecting: $e');
    }*/
    
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
        final result = PingResult(subscriptionIndex: subscriptionIndex, serverIndex: index, latencyInMs: latency);
        _pingResultSubject.add(result);
        print('Ping result: sub=${result.subscriptionIndex}, server=${result.serverIndex}, latency=${result.latencyInMs} ms');
      } else {
        print('Ping failed: No response');
        _pingResultSubject.add(PingResult(subscriptionIndex: subscriptionIndex, serverIndex: index, latencyInMs: -1)); // Indicate error with -1
      }
    } catch (e) {
      print('Ping error: $e');
      _pingResultSubject.add(PingResult(subscriptionIndex: subscriptionIndex, serverIndex: index, latencyInMs: -1));
    }
  }

  static String getConnectionStatus() {
    //  enum ConnectionStatus { connecting, connected, disconnected, error }
    return 'disconnected';
  }

  static List<Server> getServerList() {
    //TODO:
    //Fetches the list of available VPN servers.
    return [
      Server(address: 'server1.com', latency: 50, location: 'USA', isPreferred: true),
      Server(address: 'server2.com', latency: 100, location: 'UK', isPreferred: false),
      Server(address: 'server3.com', latency: 75, location: 'Canada', isPreferred: false),
    ];
  }

  static Future<void> loadSubscriptions({required List<String> subscriptionLinks}) async {
    print('loadSubscriptions: ${subscriptionLinks.join(", ")}');
    _subscriptions.addAll(subscriptionLinks);
    for (var element in subscriptionLinks) {
      addSubscription(subscriptionURL: element);
      await updateSubscription(subscriptionIndex: _subscriptions.length-1);
    }
    print('Subscriptions added: ${subscriptionLinks.join(", ")}');
  }

  static SessionStatistics getSessionStatistics() {
    //TODO:
    return SessionStatistics(
      sessionDuration: Duration(minutes: 30),
      dataInBytes: 1024 * 1024 * 100, // 100MB
      dataOutBytes: 1024 * 1024 * 50, // 50MB
    );
  }

  static void setAutoConnect({required bool enable}) {
    print('setAutoConnect: $enable');
  }

  static void setKillSwitch({required bool enable}) {
    print('setKillSwitch: $enable');
  }

}
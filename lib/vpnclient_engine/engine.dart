import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dart_ping/dart_ping.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine/core.dart';

// Re-export core types for convenience
export 'package:vpnclient_engine_flutter/vpnclient_engine/core.dart';

// Simple logger for production code
void _log(String message) {
  // In production, this could be replaced with a proper logging framework
  // For now, we'll keep print for development but mark it as intentional
  // ignore: avoid_print
  print('VPNClientEngine: $message');
}

class VPNclientEngine {
  static final List<List<String>> _subscriptionServers = [];
  static final List<String> _subscriptions = [];

  static final _connectionStatusSubject = BehaviorSubject<ConnectionStatus>();
  static Stream<ConnectionStatus> get onConnectionStatusChanged =>
      _connectionStatusSubject.stream;

  static final _errorSubject = BehaviorSubject<ErrorDetails>();
  static Stream<ErrorDetails> get onError => _errorSubject.stream;

  static final _serverSwitchedSubject = BehaviorSubject<String>();
  static Stream<String> get onServerSwitched => _serverSwitchedSubject.stream;

  static final _pingResultSubject = BehaviorSubject<PingResult>();
  static Stream<PingResult> get onPingResult => _pingResultSubject.stream;

  static final _subscriptionLoadedSubject =
      BehaviorSubject<SubscriptionDetails>();
  static Stream<SubscriptionDetails> get onSubscriptionLoaded =>
      _subscriptionLoadedSubject.stream;

  static final _dataUsageUpdatedSubject = BehaviorSubject<SessionStatistics>();
  static Stream<SessionStatistics> get onDataUsageUpdated =>
      _dataUsageUpdatedSubject.stream;

  static final _routingRulesAppliedSubject =
      BehaviorSubject<List<RoutingRule>>();
  static Stream<List<RoutingRule>> get onRoutingRulesApplied =>
      _routingRulesAppliedSubject.stream;

  static final _killSwitchTriggeredSubject = BehaviorSubject<void>();
  static Stream<void> get onKillSwitchTriggered =>
      _killSwitchTriggeredSubject.stream;

  static VpnCore _vpnCore = V2RayCore();

  static void _emitError(ErrorCode code, String message) {
    _errorSubject.add(ErrorDetails(errorCode: code, errorMessage: message));
  }

  static void initialize() {
    _log('VPNclient Engine initialized');
    // Default core is V2Ray
    _vpnCore = V2RayCore();
  }

  static void clearSubscriptions() {
    _subscriptions.clear();
    _log('All subscriptions cleared');
  }

  static void addSubscription({required String subscriptionURL}) {
    _subscriptions.add(subscriptionURL);
    _log('Subscription added: $subscriptionURL');
  }

  static void addSubscriptions({required List<String> subscriptionURLs}) {
    _subscriptions.addAll(subscriptionURLs);
    _log('Subscriptions added: ${subscriptionURLs.join(", ")}');
  }

  static Future<void> updateSubscription({
    required int subscriptionIndex,
  }) async {
    if (subscriptionIndex < 0 || subscriptionIndex >= _subscriptions.length) {
      _log('Invalid subscription index');
      return;
    }

    final url = _subscriptions[subscriptionIndex];
    _log('Fetching subscription data from: $url');

    try {
      //Сейчас при поднятом VPN обновление подписки пойдет через туннель. Позже необходимо реализовать разные механизмы обновления (только через туннель/только напрямую/комбинированный)
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        _log('Failed to fetch subscription: HTTP ${response.statusCode}');
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
        _log('Parsed JSON subscription: ${servers.length} servers loaded');
      } else {
        // NEWLINE format
        servers =
            content
                .split('\n')
                .where((line) => line.trim().isNotEmpty)
                .toList();
        _log('Parsed NEWLINE subscription: ${servers.length} servers loaded');
      }

      // Ensure the servers list matches the subscriptions list size
      while (_subscriptionServers.length <= subscriptionIndex) {
        _subscriptionServers.add([]);
      }

      // Save fetched servers to specific subscription index
      _subscriptionServers[subscriptionIndex] = servers;
      _subscriptionLoadedSubject.add(SubscriptionDetails());

      _log('Subscription #$subscriptionIndex servers updated successfully');
    } catch (e) {
      _log('Error updating subscription: $e');
      _emitError(ErrorCode.unknownError, 'Error updating subscription: $e');
    }
  }

  static Future<void> connect({
    required int subscriptionIndex,
    required int serverIndex,
    ProxyConfig? proxyConfig,
  }) async {
    final url = _subscriptionServers[subscriptionIndex][serverIndex];

    if (url.startsWith('vless://') ||
        url.startsWith('vmess://') ||
        url.startsWith('v2ray://')) {
      _vpnCore = V2RayCore();
    } else if (url.startsWith('wg://')) {
      _vpnCore = WireGuardCore();
    } else if (url.startsWith('openvpn://') || url.endsWith('.ovpn')) {
      _vpnCore = OpenVPNCore();
    } else {
      _emitError(ErrorCode.unknownError, 'Unsupported URL format');
      return;
    }
    if (serverIndex < 0 ||
        serverIndex >= _subscriptionServers[subscriptionIndex].length) {
      _emitError(ErrorCode.unknownError, 'Invalid server index');
      return;
    }

    await _vpnCore.connect(
      subscriptionIndex: subscriptionIndex,
      serverIndex: serverIndex,
    );
  }

  static Future<void> disconnect() async {
    await _vpnCore.disconnect();
  }

  static void setRoutingRules({required List<RoutingRule> rules}) {
    for (var rule in rules) {
      if (rule.appName != null) {
        _log('Routing rule for app ${rule.appName}: ${rule.action}');
      } else if (rule.domain != null) {
        _log('Routing rule for domain ${rule.domain}: ${rule.action}');
      }
    }
  }

  static void pingServer({
    required int subscriptionIndex,
    required int index,
  }) async {
    if (subscriptionIndex < 0 ||
        subscriptionIndex >= _subscriptionServers.length) {
      _log('Invalid subscription index');
      return;
    }
    if (index < 0 || index >= _subscriptionServers[subscriptionIndex].length) {
      _log('Invalid server index');
      return;
    }
    final serverAddress = _subscriptionServers[subscriptionIndex][index];
    _log('Pinging server: $serverAddress');

    try {
      final ping = Ping(serverAddress, count: 3);
      final pingData = await ping.stream.firstWhere(
        (data) => data.response != null,
      );
      if (pingData.response != null) {
        final latency = pingData.response!.time!.inMilliseconds;
        final result = PingResult(
          subscriptionIndex: subscriptionIndex,
          serverIndex: index,
          latencyInMs: latency,
        );
        _pingResultSubject.add(result);
        _log(
          'Ping result: sub=${result.subscriptionIndex}, server=${result.serverIndex}, latency=${result.latencyInMs} ms',
        );
      } else {
        _log('Ping failed: No response');
        _pingResultSubject.add(
          PingResult(
            subscriptionIndex: subscriptionIndex,
            serverIndex: index,
            latencyInMs: -1,
          ),
        ); // Indicate error with -1
      }
    } catch (e) {
      _log('Ping error: $e');
      _pingResultSubject.add(
        PingResult(
          subscriptionIndex: subscriptionIndex,
          serverIndex: index,
          latencyInMs: -1,
        ),
      );
    }
  }

  static String getConnectionStatus() {
    //  enum ConnectionStatus { connecting, connected, disconnected, error }
    return 'disconnected';
  }

  static List<Server> getServerList() {
    List<Server> servers = [];
    
    _log('getServerList: processing ${_subscriptionServers.length} subscriptions');
    
    // Convert subscription servers to Server objects
    for (int subIndex = 0; subIndex < _subscriptionServers.length; subIndex++) {
      _log('getServerList: subscription $subIndex has ${_subscriptionServers[subIndex].length} servers');
      
      for (int serverIndex = 0; serverIndex < _subscriptionServers[subIndex].length; serverIndex++) {
        final serverUrl = _subscriptionServers[subIndex][serverIndex];
        _log('getServerList: processing server $serverIndex: $serverUrl');
        
        // Extract server information from URL
        String address = serverUrl;
        String? location;
        
        // Try to extract location from URL if possible
        if (serverUrl.contains('@')) {
          final parts = serverUrl.split('@');
          if (parts.length > 1) {
            final hostPart = parts[1].split(':')[0];
            address = hostPart;
            _log('getServerList: extracted host: $address');
            
            // Simple location detection based on common patterns
            if (hostPart.contains('.us') || hostPart.contains('usa')) {
              location = 'USA';
            } else if (hostPart.contains('.uk') || hostPart.contains('gb')) {
              location = 'UK';
            } else if (hostPart.contains('.ca')) {
              location = 'Canada';
            } else if (hostPart.contains('.de')) {
              location = 'Germany';
            } else if (hostPart.contains('.nl')) {
              location = 'Netherlands';
            } else if (hostPart.contains('.jp')) {
              location = 'Japan';
            } else if (hostPart.contains('.sg')) {
              location = 'Singapore';
            } else {
              location = 'Unknown';
            }
          }
        } else {
          // If no @ symbol, try to extract domain from the URL
          if (serverUrl.contains('://')) {
            final uri = Uri.parse(serverUrl);
            address = uri.host;
            _log('getServerList: extracted host from URI: $address');
          }
        }
        
        final server = Server(
          address: address,
          latency: null, // Will be updated by ping
          location: location,
          isPreferred: false,
        );
        
        servers.add(server);
        _log('getServerList: added server: ${server.address} (${server.location})');
      }
    }
    
    _log('getServerList: returning ${servers.length} servers from subscriptions');
    return servers;
  }

  static Future<void> loadSubscriptions({
    required List<String> subscriptionLinks,
  }) async {
    _log('loadSubscriptions: ${subscriptionLinks.join(", ")}');
    _subscriptions.addAll(subscriptionLinks);
    for (var element in subscriptionLinks) {
      addSubscription(subscriptionURL: element);
      await updateSubscription(
        subscriptionIndex: _subscriptions.indexOf(element),
      );
    }
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
    _log('setAutoConnect: $enable');
  }

  static void setKillSwitch({required bool enable}) {
    _log('setKillSwitch: $enable');
  }
}

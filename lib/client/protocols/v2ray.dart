import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:vpnclient_engine_flutter/client/core.dart';

class V2RayCore implements VpnCore {
  final FlutterV2ray _flutterV2ray = FlutterV2ray(
    onStatusChanged: (status) {
      // do something
    },
  );
  List<List<String>> _subscriptionServers = [];
  List<String> _subscriptions = [];

  final _connectionStatusSubject = BehaviorSubject<ConnectionStatus>();
  Stream<ConnectionStatus> get onConnectionStatusChanged =>
      _connectionStatusSubject.stream;

  final _errorSubject = BehaviorSubject<ErrorDetails>();
  Stream<ErrorDetails> get onError => _errorSubject.stream;

  final _serverSwitchedSubject = BehaviorSubject<String>();
  Stream<String> get onServerSwitched => _serverSwitchedSubject.stream;

  final _pingResultSubject = BehaviorSubject<PingResult>();
  Stream<PingResult> get onPingResult => _pingResultSubject.stream;

  final _subscriptionLoadedSubject = BehaviorSubject<SubscriptionDetails>();
  Stream<SubscriptionDetails> get onSubscriptionLoaded =>
      _subscriptionLoadedSubject.stream;

  final _dataUsageUpdatedSubject = BehaviorSubject<SessionStatistics>();
  Stream<SessionStatistics> get onDataUsageUpdated =>
      _dataUsageUpdatedSubject.stream;

  final _routingRulesAppliedSubject = BehaviorSubject<List<RoutingRule>>();
  Stream<List<RoutingRule>> get onRoutingRulesApplied =>
      _routingRulesAppliedSubject.stream;

  final _killSwitchTriggeredSubject = BehaviorSubject<void>();
  Stream<void> get onKillSwitchTriggered => _killSwitchTriggeredSubject.stream;

  void _emitError(ErrorCode code, String message) {
    _errorSubject.add(ErrorDetails(errorCode: code, errorMessage: message));
  }

  void initialize() {
    log('V2RayCore initialized');
  }

  void clearSubscriptions() {
    _subscriptions.clear();
    log('All subscriptions cleared');
  }

  void addSubscription({required String subscriptionURL}) {
    _subscriptions.add(subscriptionURL);
    log('Subscription added: $subscriptionURL');
  }

  void addSubscriptions({required List<String> subscriptionURLs}) {
    _subscriptions.addAll(subscriptionURLs);
    log('Subscriptions added: ${subscriptionURLs.join(", ")}');
  }

  Future<void> updateSubscription({required int subscriptionIndex}) async {
    if (subscriptionIndex < 0 || subscriptionIndex >= _subscriptions.length) {
      log('Invalid subscription index');
      return;
    }

    final url = _subscriptions[subscriptionIndex];
    log('Fetching subscription data from: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        log('Failed to fetch subscription: HTTP ${response.statusCode}');
        return;
      }

      final content = response.body.trim();

      List<String> servers = [];

      if (content.startsWith('[')) {
        final jsonList = jsonDecode(content) as List<dynamic>;
        for (var server in jsonList) {
          servers.add(server.toString());
        }
        log('Parsed JSON subscription: ${servers.length} servers loaded');
      } else {
        servers =
            content
                .split('\n')
                .where((line) => line.trim().isNotEmpty)
                .toList();
        log('Parsed NEWLINE subscription: ${servers.length} servers loaded');
      }

      while (_subscriptionServers.length <= subscriptionIndex) {
        _subscriptionServers.add([]);
      }

      _subscriptionServers[subscriptionIndex] = servers;
      _subscriptionLoadedSubject.add(SubscriptionDetails());

      log('Subscription #$subscriptionIndex servers updated successfully');
    } catch (e) {
      log('Error updating subscription: $e');
      _emitError(ErrorCode.unknownError, 'Error updating subscription: $e');
    }
  }

  @override
  Future<void> connect({
    required int subscriptionIndex,
    required int serverIndex,
  }) async {
    try {
      if (subscriptionIndex < 0 ||
          subscriptionIndex >= _subscriptionServers.length) {
        log('Invalid subscription index');
        return;
      }
      if (serverIndex < 0 ||
          serverIndex >= _subscriptionServers[subscriptionIndex].length) {
        log('Invalid server index');
        return;
      }

      await _flutterV2ray.initializeV2Ray();

      final serverAddress =
          _subscriptionServers[subscriptionIndex][serverIndex];
      V2RayURL parser = FlutterV2ray.parseFromURL(serverAddress);

      _connectionStatusSubject.add(ConnectionStatus.connecting);
      if (await _flutterV2ray.requestPermission()) {
        _flutterV2ray.startV2Ray(
          remark: parser.remark,
          config: parser.getFullConfiguration(),
          blockedApps: null,
          bypassSubnets: null,
          proxyOnly: false,
        );
      }
      _serverSwitchedSubject.add(serverAddress);
      _connectionStatusSubject.add(ConnectionStatus.connected);
      log('Successfully connected');
    } catch (e) {
      _emitError(ErrorCode.unknownError, 'Error connecting: $e');
      _connectionStatusSubject.add(ConnectionStatus.error);
    }
  }

  @override
  Future<void> disconnect() async {
    _flutterV2ray.stopV2Ray();
    _connectionStatusSubject.add(ConnectionStatus.disconnected);
    log('Disconnected successfully');
  }

  @override
  void setRoutingRules({required List<RoutingRule> rules}) {
    for (var rule in rules) {
      if (rule.appName != null) {
        log('Routing rule for app ${rule.appName}: ${rule.action}');
      } else if (rule.domain != null) {
        log('Routing rule for domain ${rule.domain}: ${rule.action}');
      }
    }
  }

  @override
  void pingServer({required int subscriptionIndex, required int index}) async {
    if (subscriptionIndex < 0 ||
        subscriptionIndex >= _subscriptionServers.length) {
      log('Invalid subscription index');
      _emitError(ErrorCode.unknownError, 'Invalid subscription index');
      return;
    }
    if (index < 0 || index >= _subscriptionServers[subscriptionIndex].length) {
      log('Invalid server index');
      _emitError(ErrorCode.unknownError, 'Invalid server index');
      return;
    }
    final serverAddress = _subscriptionServers[subscriptionIndex][index];
    log('Pinging server: $serverAddress');
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
        log(
          'Ping result: sub=${result.subscriptionIndex}, server=${result.serverIndex}, latency=${result.latencyInMs} ms',
        );
      } else {
        log('Ping failed: No response');
        _pingResultSubject.add(
          PingResult(
            subscriptionIndex: subscriptionIndex,
            serverIndex: index,
            latencyInMs: -1,
          ),
        );
        _emitError(ErrorCode.serverUnavailable, 'Ping failed: No response');
      }
    } catch (e) {
      log('Ping error: $e');
      _pingResultSubject.add(
        PingResult(
          subscriptionIndex: subscriptionIndex,
          serverIndex: index,
          latencyInMs: -1,
        ),
      );
      _emitError(ErrorCode.unknownError, 'Ping error: $e');
    }
  }

  @override
  String getConnectionStatus() {
    return 'disconnected';
  }

  @override
  List<Server> getServerList() {
    return [
      Server(
        address: 'server1.com',
        latency: 50,
        location: 'USA',
        isPreferred: true,
      ),
      Server(
        address: 'server2.com',
        latency: 100,
        location: 'UK',
        isPreferred: false,
      ),
      Server(
        address: 'server3.com',
        latency: 75,
        location: 'Canada',
        isPreferred: false,
      ),
    ];
  }

  @override
  Future<void> loadSubscriptions({
    required List<String> subscriptionLinks,
  }) async {
    log('loadSubscriptions: ${subscriptionLinks.join(", ")}');
    _subscriptions.addAll(subscriptionLinks);
    log('Subscriptions added: ${subscriptionLinks.join(", ")}');
    for (var index = 0; index < subscriptionLinks.length; index++) {
      await updateSubscription(subscriptionIndex: index);
    }
  }

  @override
  SessionStatistics getSessionStatistics() {
    return SessionStatistics(
      sessionDuration: Duration(minutes: 30),
      dataInBytes: 1024 * 1024 * 100,
      dataOutBytes: 1024 * 1024 * 50,
    );
  }

  @override
  void setAutoConnect({required bool enable}) {
    log('setAutoConnect: $enable');
  }

  @override
  void setKillSwitch({required bool enable}) {
    log('setKillSwitch: $enable');
  }
}

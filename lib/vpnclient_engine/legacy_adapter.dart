import 'dart:async';
import 'engine_types.dart';
import 'engine_factory.dart';

/// Legacy adapter to maintain compatibility with existing code
class VPNclientEngine {
  static final StreamController<ConnectionStatus> _connectionStatusController = 
      StreamController<ConnectionStatus>.broadcast();
  static final StreamController<PingResult> _pingResultController = 
      StreamController<PingResult>.broadcast();
  static final StreamController<SessionStatistics> _dataUsageController = 
      StreamController<SessionStatistics>.broadcast();

  /// Stream for connection status changes
  static Stream<ConnectionStatus> get onConnectionStatusChanged => 
      _connectionStatusController.stream;

  /// Stream for ping results
  static Stream<PingResult> get onPingResult => 
      _pingResultController.stream;

  /// Stream for data usage updates
  static Stream<SessionStatistics> get onDataUsageUpdated => 
      _dataUsageController.stream;

  /// Initialize the engine
  static Future<void> initialize() async {
    // Engine is ready
  }

  /// Load subscriptions (legacy method)
  static Future<void> loadSubscriptions({required List<String> subscriptionLinks}) async {
    // TODO: Implement subscription loading
    print('Loading subscriptions: $subscriptionLinks');
  }

  /// Get server list (legacy method)
  static List<Server> getServerList() {
    // TODO: Implement server list
    return [];
  }

  /// Connect to server (legacy method)
  static Future<void> connect({required int subscriptionIndex, required int serverIndex}) async {
    // TODO: Implement connection
    print('Connecting to server $serverIndex from subscription $subscriptionIndex');
  }

  /// Disconnect (legacy method)
  static Future<void> disconnect() async {
    // TODO: Implement disconnection
    print('Disconnecting');
  }

  /// Ping server (legacy method)
  static void pingServer({required int subscriptionIndex, required int index}) {
    // TODO: Implement ping
    print('Pinging server $index from subscription $subscriptionIndex');
  }

  /// Set auto connect (legacy method)
  static void setAutoConnect({required bool enable}) {
    // TODO: Implement auto connect
    print('Auto connect: $enable');
  }

  /// Set kill switch (legacy method)
  static void setKillSwitch({required bool enable}) {
    // TODO: Implement kill switch
    print('Kill switch: $enable');
  }

  /// Update connection status
  static void _updateConnectionStatus(ConnectionStatus status) {
    _connectionStatusController.add(status);
  }

  /// Update ping result
  static void _updatePingResult(PingResult result) {
    _pingResultController.add(result);
  }

  /// Update session statistics
  static void _updateSessionStatistics(SessionStatistics stats) {
    _dataUsageController.add(stats);
  }
}

/// Legacy data models
class Server {
  final String address;
  final int? latency;
  final String? location;
  final bool isPreferred;

  Server({
    required this.address,
    this.latency,
    this.location,
    this.isPreferred = false,
  });
}

class PingResult {
  final int serverIndex;
  final int latencyInMs;

  PingResult({
    required this.serverIndex,
    required this.latencyInMs,
  });
}

class SessionStatistics {
  final int dataInBytes;
  final int dataOutBytes;
  final Duration? sessionDuration;

  SessionStatistics({
    required this.dataInBytes,
    required this.dataOutBytes,
    this.sessionDuration,
  });
} 
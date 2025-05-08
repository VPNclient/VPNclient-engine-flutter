import 'dart:async';

enum ConnectionStatus { connecting, connected, disconnected, error }

enum ErrorCode {
  invalidCredentials,
  serverUnavailable,
  subscriptionExpired,
  unknownError,
}

enum ProxyType { socks5, http }

enum Action { block, allow, routeThroughVPN, direct, proxy }

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

  SubscriptionDetails({this.expiryDate, this.dataLimit, this.usedData});
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

abstract class VpnCore {
  Future<void> connect({
    required int subscriptionIndex,
    required int serverIndex,
  });
  Future<void> disconnect();
  String getConnectionStatus();
  void setRoutingRules({required List<RoutingRule> rules});
  SessionStatistics getSessionStatistics();
  Future<void> loadSubscriptions({required List<String> subscriptionLinks});
  void pingServer({required int subscriptionIndex, required int index});
  List<Server> getServerList();
  void setAutoConnect({required bool enable});
  void setKillSwitch({required bool enable});
}

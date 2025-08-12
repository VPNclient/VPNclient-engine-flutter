import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

  // Static storage for loaded subscriptions and servers
  static final List<Subscription> _loadedSubscriptions = [];
  static final List<Server> _serverList = [];

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
    try {
      _loadedSubscriptions.clear();
      _serverList.clear();
      
      for (String link in subscriptionLinks) {
        final subscription = await _fetchAndParseSubscription(link);
        _loadedSubscriptions.add(subscription);
        _serverList.addAll(subscription.servers);
      }
      
      print('Loaded ${_loadedSubscriptions.length} subscriptions with ${_serverList.length} total servers');
    } catch (e) {
      print('Error loading subscriptions: $e');
      rethrow;
    }
  }

  /// Get server list (legacy method)
  static List<Server> getServerList() {
    return List.from(_serverList);
  }

  /// Connect to server (legacy method)
  static Future<void> connect({required int subscriptionIndex, required int serverIndex}) async {
    try {
      if (subscriptionIndex >= _loadedSubscriptions.length) {
        throw Exception('Invalid subscription index: $subscriptionIndex');
      }
      
      final subscription = _loadedSubscriptions[subscriptionIndex];
      if (serverIndex >= subscription.servers.length) {
        throw Exception('Invalid server index: $serverIndex');
      }
      
      final server = subscription.servers[serverIndex];
      final config = server.config;
      
      // Use the first available engine (libxray)
      final engine = VpnEngineFactory.create(EngineType.libxray);
      if (engine == null || !engine.isSupported) {
        throw Exception('LibXray engine is not supported on this platform');
      }
      
      final success = await engine.connect(config);
      if (success) {
        _updateConnectionStatus(ConnectionStatus.connected);
      } else {
        _updateConnectionStatus(ConnectionStatus.error);
        throw Exception('Failed to connect to server');
      }
    } catch (e) {
      _updateConnectionStatus(ConnectionStatus.error);
      print('Error connecting to server: $e');
      rethrow;
    }
  }

  /// Disconnect (legacy method)
  static Future<void> disconnect() async {
    try {
      final engine = VpnEngineFactory.create(EngineType.libxray);
      if (engine != null) {
        await engine.disconnect();
      }
      _updateConnectionStatus(ConnectionStatus.disconnected);
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  /// Ping server (legacy method)
  static void pingServer({required int subscriptionIndex, required int index}) async {
    try {
      if (subscriptionIndex >= _loadedSubscriptions.length) {
        return;
      }
      
      final subscription = _loadedSubscriptions[subscriptionIndex];
      if (index >= subscription.servers.length) {
        return;
      }
      
      final server = subscription.servers[index];
      final engine = VpnEngineFactory.create(EngineType.libxray);
      
      if (engine != null && engine.isSupported) {
        final latency = await engine.ping(server.config, 'https://www.google.com', timeout: 5);
        _updatePingResult(PingResult(serverIndex: index, latencyInMs: latency));
      }
    } catch (e) {
      print('Error pinging server: $e');
    }
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

  /// Fetch and parse subscription from URL
  static Future<Subscription> _fetchAndParseSubscription(String url) async {
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch subscription: HTTP ${response.statusCode}');
      }
      
      final content = await response.transform(utf8.decoder).join();
      
      // Check if content is base64 encoded
      if (_isBase64Encoded(content)) {
        return _parseBase64Subscription(content, url);
      } else {
        return _parseSubscription(content, url);
      }
    } catch (e) {
      print('Error fetching subscription from $url: $e');
      rethrow;
    }
  }

  /// Check if content is base64 encoded
  static bool _isBase64Encoded(String content) {
    // Simple heuristic: if content contains only base64 characters and is longer than 100 chars
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
    return content.length > 100 && base64Pattern.hasMatch(content.trim());
  }

  /// Parse base64 encoded subscription content
  static Subscription _parseBase64Subscription(String base64Content, String sourceUrl) {
    try {
      final decodedBytes = base64Decode(base64Content);
      final decodedContent = utf8.decode(decodedBytes);
      return _parseSubscription(decodedContent, sourceUrl);
    } catch (e) {
      print('Error decoding base64 subscription: $e');
      return Subscription(
        sourceUrl: sourceUrl,
        servers: [],
        loadedAt: DateTime.now(),
      );
    }
  }

  /// Parse subscription content
  static Subscription _parseSubscription(String content, String sourceUrl) {
    final servers = <Server>[];
    final lines = content.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      try {
        final server = _parseServerLine(line, i);
        if (server != null) {
          servers.add(server);
        }
      } catch (e) {
        print('Error parsing line $i: $e');
      }
    }
    
    return Subscription(
      sourceUrl: sourceUrl,
      servers: servers,
      loadedAt: DateTime.now(),
    );
  }

  /// Parse individual server line
  static Server? _parseServerLine(String line, int index) {
    // Handle base64 encoded VLESS URLs
    if (line.startsWith('vless://')) {
      return _parseVlessUrl(line, index);
    }
    
    // Handle other protocols if needed
    print('Unsupported protocol in line: ${line.substring(0, line.indexOf('://'))}');
    return null;
  }

  /// Parse VLESS URL
  static Server? _parseVlessUrl(String url, int index) {
    try {
      // Extract the base64 part after vless://
      final base64Part = url.substring(8);
      final atIndex = base64Part.indexOf('@');
      if (atIndex == -1) return null;
      
      final id = base64Part.substring(0, atIndex);
      final remaining = base64Part.substring(atIndex + 1);
      
      // Parse the remaining part (address:port?params)
      final colonIndex = remaining.indexOf(':');
      if (colonIndex == -1) return null;
      
      final address = remaining.substring(0, colonIndex);
      final portAndParams = remaining.substring(colonIndex + 1);
      
      final questionIndex = portAndParams.indexOf('?');
      final port = questionIndex != -1 
          ? int.parse(portAndParams.substring(0, questionIndex))
          : int.parse(portAndParams);
      
      // Extract location from the URL if available
      String? location;
      if (url.contains('#')) {
        final hashIndex = url.indexOf('#');
        location = Uri.decodeComponent(url.substring(hashIndex + 1));
      }
      
      return Server(
        address: address,
        latency: null,
        location: location,
        isPreferred: false,
        config: url, // Store the full config
      );
    } catch (e) {
      print('Error parsing VLESS URL: $e');
      return null;
    }
  }
}

/// Subscription model
class Subscription {
  final String sourceUrl;
  final List<Server> servers;
  final DateTime loadedAt;

  Subscription({
    required this.sourceUrl,
    required this.servers,
    required this.loadedAt,
  });
}

/// Legacy data models
class Server {
  final String address;
  final int? latency;
  final String? location;
  final bool isPreferred;
  final String config; // Store the full configuration

  Server({
    required this.address,
    this.latency,
    this.location,
    this.isPreferred = false,
    required this.config,
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
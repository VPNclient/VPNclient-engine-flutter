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
  await VPNclientEngine.connect();
  await VPNclientEngine.disconnect();
}
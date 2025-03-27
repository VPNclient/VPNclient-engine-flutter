import 'dart:async';

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
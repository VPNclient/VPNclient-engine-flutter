// Simple logger for production code
void _log(String message) {
  // ignore: avoid_print
  print('VPNClientMain: $message');
}

void main() {
  _log('VPN Client Engine Flutter Plugin initialized');
  _log('This is a Flutter plugin for VPN functionality');
}

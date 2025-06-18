Pod::Spec.new do |s|
  s.name             = 'vpnclient_engine_flutter'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for VPN client engine.'
  s.homepage         = 'https://example.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :path => '.' }
  # s.dependency 'PacketTunnelProvider' # Removed because pod not found
  s.ios.deployment_target = '11.0'
  s.dependency 'Flutter'
  s.source_files = 'Classes/**/*'
end 
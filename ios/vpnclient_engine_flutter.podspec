Pod::Spec.new do |s|
  s.name             = 'vpnclient_engine_flutter'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for VPN client engine.'
  s.homepage         = 'https://example.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :path => '.' }
  # s.dependency 'PacketTunnelProvider' # Removed because pod not found
  s.ios.deployment_target = '15.0'
  s.dependency 'Flutter'
  s.source_files = 'Classes/**/*'
  
  # Add LibXray framework
  s.vendored_frameworks = 'Frameworks/LibXray.xcframework'
  
  # Add resources
  s.resource_bundles = {
    'vpnclient_engine_flutter' => ['Resources/**/*']
  }
  
  # Add framework search paths
  s.pod_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/../.symlinks/plugins/vpnclient_engine_flutter/ios/Frameworks',
    'OTHER_LDFLAGS' => '$(inherited) -framework LibXray'
  }
end 
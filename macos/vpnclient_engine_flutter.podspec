#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint vpnclient_engine_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'vpnclient_engine_flutter'
  s.version          = '0.0.1'
  s.summary          = 'VPNclient Engine Flutter plugin project.'
  s.description      = <<-DESC
VPNclient Engine Flutter plugin project.
                       DESC
  s.homepage         = 'http://vpnclient.click'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'admin@nativemind.net' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'vpnclient_engine_flutter_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'
  s.dependency 'VPNclientEngineIOS', :path => '../VPNcleint-engine-ios'
  
  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end

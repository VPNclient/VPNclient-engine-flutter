import Foundation
import NetworkExtension
import Flutter
import FlutterV2ray
/// Plugin class to handle VPN connections in the Flutter app.
import Flutter
import UIKit
import NetworkExtension
import flutter_v2ray_plugin
public class VpnclientEngineFlutterPlugin: NSObject, FlutterPlugin {
    private var tunnelProvider: NETunnelProviderManager?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "vpnclient_engine_flutter", binaryMessenger: registrar.messenger())
        let instance = VpnclientEngineFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.channel = channel
    }
    private var channel: FlutterMethodChannel?
    private let v2rayPlugin = FlutterV2rayPlugin.sharedInstance()
    private var isVpnRunning = false
    private var currentConfig: V2RayURL?

    private var tunnelManager: NETunnelProviderManager?
    private var isVpnRunning: Bool = false
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "connect":
            guard let arguments = call.arguments as? [String: Any] else {
                result(FlutterError(code: "ARGUMENT_ERROR", message: "Invalid arguments", details: nil))
                return
            }
            self.connect(arguments: arguments, result: result)
        case "disconnect":
            self.disconnect(result: result)
        case "requestPermissions":
            self.requestPermissions(result: result)
        case "getConnectionStatus":
            self.getConnectionStatus(result: result)
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "checkSystemPermission":
            self.checkSystemPermission(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func connect(arguments: [String: Any], result: @escaping FlutterResult) {
        guard let link = arguments["link"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid config", details: nil))
              return
          }
        if link.starts(with: "vless://") || link.starts(with: "vmess://") {
            var parsedConfig: V2RayURL
            do {
                parsedConfig = try FlutterV2ray.parseFromURL(link)
            } catch {
                sendError(errorCode: "PARSE_ERROR", errorMessage: "Failed to parse config: \(error)")
                result(FlutterError(code: "PARSE_ERROR", message: "Failed to parse config: \(error)", details: nil))
                return
            }
            
            currentConfig = parsedConfig
            startV2Ray(config: parsedConfig, result: result)
        } else if link.starts(with: "wg://") {
            var parsedConfig: V2RayURL
            do {
                parsedConfig = try FlutterV2ray.parseFromURL(link)
            } catch {
                sendError(errorCode: "PARSE_ERROR", errorMessage: "Failed to parse config: \(error)")
                result(FlutterError(code: "PARSE_ERROR", message: "Failed to parse config: \(error)", details: nil))
                return
            }
            
            currentConfig = parsedConfig
            startV2Ray(config: parsedConfig, result: result)
        } else {
            sendError(errorCode: "UNKNOWN_PROTOCOL", errorMessage: "Unknown protocol")
            result(FlutterError(code: "UNKNOWN_PROTOCOL", message: "Unknown protocol", details: nil))
        }
    }

    private func startV2Ray(config: V2RayURL, result: @escaping FlutterResult) {
        let fullConfig = config.getFullConfiguration()
        if fullConfig.isEmpty {
            sendError(errorCode: "CONFIG_ERROR", errorMessage: "Invalid V2Ray config")
            result(FlutterError(code: "CONFIG_ERROR", message: "Invalid V2Ray config", details: nil))
            return
        }
        v2rayPlugin.startV2Ray(remark: config.remark, config: fullConfig, blockedApps: nil, bypassSubnets: nil, proxyOnly: false) { err in
            if let err = err {
                DispatchQueue.main.async {
                    self.sendError(errorCode: "VPN_ERROR", errorMessage: err)
                    result(FlutterError(code: "VPN_START_FAILED", message: "Failed to start VPN: \(err)", details: nil))
                }
            } else {
                DispatchQueue.main.async {
                    self.sendConnectionStatus(status: "connected")
                    self.isVpnRunning = true
                    result(nil)
                }
            }
        }
    }    
    
    private func sendError(errorCode: String, errorMessage: String) {
        channel?.invokeMethod("onError", arguments: ["errorCode": errorCode, "errorMessage": errorMessage])
    }
    
    private func disconnect(result: @escaping FlutterResult) {
        v2rayPlugin.stopV2Ray { err in
            self.currentConfig = nil
            if let err = err {
                DispatchQueue.main.async {
                    self.sendError(errorCode: "VPN_ERROR", errorMessage: err)
                    result(FlutterError(code: "VPN_STOP_FAILED", message: "Failed to stop VPN: \(err)", details: nil))
                }
            } else if self.isVpnRunning {
                DispatchQueue.main.async {
                    self.sendConnectionStatus(status: "disconnected")
                    self.isVpnRunning = false
                    result(nil)
                }
            }
        }
    }
    
    private func requestPermissions(result: @escaping FlutterResult) {
        
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            
            if let error = error {
                result(FlutterError(code: "PERMISSION_ERROR", message: "Failed to load VPN configurations: \(error.localizedDescription)", details: nil))
                return
            }
            
            var manager: NETunnelProviderManager
            if let managers = managers, let firstManager = managers.first {
                manager = firstManager
            } else {
                manager = NETunnelProviderManager()
                
                manager.localizedDescription = "VPNClientEngine"
                
                let protocolConfiguration = NETunnelProviderProtocol()
                protocolConfiguration.providerBundleIdentifier = "click.vpnclient.engine"
                manager.protocolConfiguration = protocolConfiguration
            }
            
            manager.isEnabled = true
            
            manager.saveToPreferences { error in
                if let error = error {
                    result(FlutterError(code: "PERMISSION_ERROR", message: "Failed to save VPN configuration: \(error.localizedDescription)", details: nil))
                    return
                }
                
                manager.loadFromPreferences { error in
                    if let error = error {
                        result(FlutterError(code: "PERMISSION_ERROR", message: "Failed to load VPN preferences: \(error.localizedDescription)", details: nil))
                        return
                    }
                    
                    result(true)
                }
            }
        }
    }
    
    private func sendConnectionStatus(status: String) {
        channel?.invokeMethod("onConnectionStatusChanged", arguments: status)
    }
    
    private func checkSystemPermission(result: @escaping FlutterResult) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            
            if let error = error {
                result(FlutterError(code: "PERMISSION_ERROR", message: "Failed to load VPN configurations: \(error.localizedDescription)", details: nil))
                return
            }
            
            if managers?.isEmpty == false {
                if let firstManager = managers?.first {
                    if firstManager.isEnabled == true {
                        result(true)
                    } else {
                        result(false)
                    }
                }
            } else {
                result(false)
            }
        }
    }
    
    private func getConnectionStatus(result: @escaping FlutterResult) {
        if isVpnRunning == true {
            result("connected")
        } else {
            result("disconnected")
        }
    }
}


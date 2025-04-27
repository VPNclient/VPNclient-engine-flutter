import Flutter
import UIKit
import NetworkExtension
import flutter_v2ray_plugin

enum VpnError: Error {
    case missingConfig
    case startFailed(String)
    case stopFailed(String)
}

/// Plugin class to handle VPN connections in the Flutter app.
public class VpnclientEngineFlutterPlugin: NSObject, FlutterPlugin {
    private var tunnelProvider: NETunnelProviderManager?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "vpnclient_engine_flutter", binaryMessenger: registrar.messenger())
        let instance = VpnclientEngineFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.channel = channel
    }
    
    private var channel: FlutterMethodChannel?
    
    private var v2rayPlugin = FlutterV2rayPlugin.sharedInstance()
    
    private var tunnelManager: NETunnelProviderManager?
    
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
        
        let parsedConfig = FlutterV2ray.parseFromURL(link)
        
        let config: String = parsedConfig.getFullConfiguration()
        
        if config.isEmpty {
            result(FlutterError(code: "CONFIG_ERROR", message: "Invalid V2Ray config", details: nil))
        }
        
        v2rayPlugin.startV2Ray(
            remark: parsedConfig.remark,
            config: config,
            blockedApps: nil,
            bypassSubnets: nil,
            proxyOnly: false
        ) { err in
            if let err = err {
                DispatchQueue.main.async {
                    self.sendError(errorCode: "VPN_START_FAILED", errorMessage: err)
                    result(FlutterError(code: "VPN_START_FAILED", message: "Failed to start VPN: \(err)", details: nil))
                }
            } else {
                DispatchQueue.main.async {
                    self.sendConnectionStatus(status: "connected")
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
            if let err = err {
                DispatchQueue.main.async {
                    self.sendError(errorCode: "VPN_STOP_FAILED", errorMessage: err)
                    result(FlutterError(code: "VPN_STOP_FAILED", message: "Failed to stop VPN: \(err)", details: nil))
                }
            } else {
                DispatchQueue.main.async {
                    self.sendConnectionStatus(status: "disconnected")
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
        if v2rayPlugin.isRunning() == true {
            result("connected")
        } else {
            result("disconnected")
        }
    }
}


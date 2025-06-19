import Foundation
import NetworkExtension
import Flutter
import UIKit

/// Plugin class to handle VPN connections in the Flutter app.
public class VpnclientEngineFlutterPlugin: NSObject, FlutterPlugin {
    private var tunnelProvider: NETunnelProviderManager?
    private var channel: FlutterMethodChannel?
    private var isVpnRunning: Bool = false
    private var tunnelManager: NETunnelProviderManager?
    private var currentEngine: String? = nil
    private var currentConfig: String? = nil

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "vpnclient_engine_flutter", binaryMessenger: registrar.messenger())
        let instance = VpnclientEngineFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.channel = channel
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "connect":
            guard let arguments = call.arguments as? [String: Any],
                  let engine = arguments["engine"] as? String,
                  let config = arguments["config"] as? String else {
                result(FlutterError(code: "ARGUMENT_ERROR", message: "Invalid arguments", details: nil))
                return
            }
            self.connect(engine: engine, config: config, result: result)
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

    private func connect(engine: String, config: String, result: @escaping FlutterResult) {
        self.currentEngine = engine
        self.currentConfig = config
        switch engine {
        case "singbox":
            startSingBox(config: config, result: result)
        case "libxray":
            // TODO: Реализовать запуск libxray через NETunnelProviderManager или другой механизм
            result(FlutterError(code: "NOT_IMPLEMENTED", message: "libxray support is not implemented yet", details: nil))
        default:
            result(FlutterError(code: "UNKNOWN_ENGINE", message: "Unknown engine: \(engine)", details: nil))
        }
    }

    private func startSingBox(config: String, result: @escaping FlutterResult) {
        // Пример запуска через NETunnelProviderManager
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                result(FlutterError(code: "LOAD_ERROR", message: "Failed to load VPN configurations: \(error.localizedDescription)", details: nil))
                return
            }
            let manager: NETunnelProviderManager
            if let managers = managers, let firstManager = managers.first {
                manager = firstManager
            } else {
                manager = NETunnelProviderManager()
                manager.localizedDescription = "VPNClientEngine (sing-box)"
                let protocolConfiguration = NETunnelProviderProtocol()
                protocolConfiguration.providerBundleIdentifier = "click.vpnclient.engine.singbox"
                manager.protocolConfiguration = protocolConfiguration
            }
            manager.isEnabled = true
            // Передаем конфиг в providerConfiguration
            if let proto = manager.protocolConfiguration as? NETunnelProviderProtocol {
                proto.providerConfiguration = ["config": config]
            }
            manager.saveToPreferences { error in
                if let error = error {
                    result(FlutterError(code: "SAVE_ERROR", message: "Failed to save VPN configuration: \(error.localizedDescription)", details: nil))
                    return
                }
                manager.loadFromPreferences { error in
                    if let error = error {
                        result(FlutterError(code: "LOAD_PREF_ERROR", message: "Failed to load VPN preferences: \(error.localizedDescription)", details: nil))
                        return
                    }
                    do {
                        try manager.connection.startVPNTunnel()
                        self.isVpnRunning = true
                        self.sendConnectionStatus(status: "connected")
                        result(true)
                    } catch let startError {
                        self.sendError(errorCode: "START_ERROR", errorMessage: "Failed to start VPN: \(startError)")
                        result(FlutterError(code: "START_ERROR", message: "Failed to start VPN: \(startError)", details: nil))
                    }
                }
            }
        }
    }

    private func sendError(errorCode: String, errorMessage: String) {
        channel?.invokeMethod("onError", arguments: ["errorCode": errorCode, "errorMessage": errorMessage])
    }

    private func disconnect(result: @escaping FlutterResult) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                result(FlutterError(code: "LOAD_ERROR", message: "Failed to load VPN configurations: \(error.localizedDescription)", details: nil))
                return
            }
            guard let managers = managers, let manager = managers.first else {
                result(FlutterError(code: "NO_MANAGER", message: "No VPN configuration found", details: nil))
                return
            }
            manager.connection.stopVPNTunnel()
            self.isVpnRunning = false
            self.sendConnectionStatus(status: "disconnected")
            result(true)
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


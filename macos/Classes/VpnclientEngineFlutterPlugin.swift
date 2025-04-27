import Cocoa
import FlutterMacOS
import NetworkExtension
import os.log

/// Plugin for managing VPN connections on macOS.
public class VpnclientEngineFlutterPlugin: NSObject, FlutterPlugin {
    private var vpnManager: NEVPNManager?
    private var vpnConnection: NEVPNConnection?
    
    private let logger = OSLog(subsystem: "click.vpnclient.engine.flutter", category: "VPNPlugin")

    /// Registers the plugin with the Flutter engine.
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "vpnclient_engine_flutter", binaryMessenger: registrar.messenger)
        let instance = VpnclientEngineFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        // Load VPN Configuration
        instance.loadVPNConfiguration { (success, error) in
            if success {
                os_log(.info, log: instance.logger, "VPN configuration loaded successfully")
            } else if let error = error {
                os_log(.error, log: instance.logger, "Failed to load VPN configuration: %@", error.localizedDescription)
            }
        }
    }
    
    /// Handles method calls from Flutter.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        os_log(.debug, log: logger, "Method call received: %@", call.method)

        switch call.method {
        case "startVPN":
            guard let config = call.arguments as? String else {
                return result(FlutterError(code: "INVALID_ARGUMENTS", message: "Config is missing", details: nil))
            }
           self.startVPN(config: config, result: result)
        case "stopVPN":
            stopVPN(result: result)
        case "checkVPNStatus":
            checkVPNStatus { (status) in
                            result(status)
                        }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func loadVPNConfiguration(completion: @escaping (Bool, Error?) -> Void) {
            NEVPNManager.loadAllFromPreferences { [weak self] (managers, error) in
                guard let self = self else { return }
                if let error = error {
                    os_log(.error, log: self.logger, "Error loading VPN preferences: %@", error.localizedDescription)
                    completion(false, error)
                    return
                }

                if let managers = managers, !managers.isEmpty {
                    self.vpnManager = managers[0]
                    os_log(.info, log: self.logger, "Existing VPN configuration loaded.")
                } else {
                    self.vpnManager = NEVPNManager.shared()
                    self.vpnManager?.localizedDescription = "SingBoxVPN"
                    self.vpnManager?.isEnabled = true
                    
                    let protocolConfiguration = NEVPNProtocolIKEv2()
                    protocolConfiguration.serverAddress = ""
                    self.vpnManager?.protocolConfiguration = protocolConfiguration
                    
                    os_log(.info, log: self.logger, "New VPN configuration created.")
                    
                    self.vpnManager?.saveToPreferences(completionHandler: { error in
                                    if let error = error {
                                        os_log(.error, log: self.logger, "Error saving VPN preferences: %@", error.localizedDescription)
                                        completion(false, error)
                                    } else {
                                        os_log(.info, log: self.logger, "VPN preferences saved.")
                                        completion(true, nil)
                                    }
                                })
                }
            }
        }

    private func startVPN(config: String, result: @escaping FlutterResult) {
        guard let vpnManager = self.vpnManager else {
            result(FlutterError(code: "VPN_MANAGER_NOT_LOADED", message: "VPN manager is not loaded", details: nil))
            return
        }
        do {
                    try vpnManager.connection.startVPNTunnel(options: ["config": config])
                    result(true)

                } catch {
                    os_log(.error, log: logger, "Failed to start VPN: %@", error.localizedDescription)
                    result(FlutterError(code: "VPN_START_FAILED", message: "Failed to start VPN", details: error.localizedDescription))
                }
    }

    private func stopVPN(result: @escaping FlutterResult) {
        vpnManager?.connection.stopVPNTunnel()
        result(true)
    }

    private func checkVPNStatus(completion: @escaping (String) -> Void) {
        if let status = vpnManager?.connection.status {
            completion(status.rawValue.description)
        }else{
           completion("disconnected")
        }
    }
    }
    
    private func stopVPN(result: @escaping FlutterResult) {
        // TODO: Implement stopVPN logic
    }
    
    private func checkVPNStatus(result: @escaping FlutterResult) {
        // TODO: Implement checkVPNStatus logic
    }
}

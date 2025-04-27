import Flutter
import UIKit
import NetworkExtension
import singbox

/// Plugin class to handle VPN connections in the Flutter app.
public class VpnclientEngineFlutterPlugin: NSObject, FlutterPlugin {
    private var tunnelProvider: NETunnelProviderManager?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "vpnclient_engine_flutter", binaryMessenger: registrar.messenger())
        let instance = VpnclientEngineFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startVPN":
            guard let args = call.arguments as? [String: Any],
                  let config = args["config"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid config", details: nil))
                return
            }
            startVPN(withConfig: config, result: result)
        case "stopVPN":
            stopVPN(result: result)
        case "checkVPNStatus":
            checkVPNStatus(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    /// Starts the VPN connection.
    private func startVPN(withConfig config: String, result: @escaping FlutterResult) {
        do {
            let singboxConfig = try SingboxConfig(json: config)
            let builder = SingboxBuilder(config: singboxConfig)
            
            try builder.build()
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try builder.start()
                    
                    DispatchQueue.main.async {
                        result(nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "VPN_START_FAILED", message: "Failed to start VPN: \(error.localizedDescription)", details: nil))
                    }
                }
            }
        } catch {
            result(FlutterError(code: "CONFIG_ERROR", message: "Invalid Singbox config: \(error.localizedDescription)", details: nil))
        }
    }

    /// Stops the VPN connection.
    private func stopVPN(result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try Singbox.shared.stop()
                DispatchQueue.main.async {
                    result(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "VPN_STOP_FAILED", message: "Failed to stop VPN: \(error.localizedDescription)", details: nil))
                }
            }
        }
    }
    
    /// Checks the current status of the VPN connection.
    private func checkVPNStatus(result: @escaping FlutterResult) {
        if Singbox.shared.isRunning {
            result(true)
        } else {
            result(false)
        }
    }
}

private extension SingboxConfig {
    convenience init(json: String) throws {
        guard let data = json.data(using: .utf8) else {
            throw NSError(domain: "SingboxConfig", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON string to data"])
        }
        self.init()
        
        try self.fromJSONData(data: data)
    }
}



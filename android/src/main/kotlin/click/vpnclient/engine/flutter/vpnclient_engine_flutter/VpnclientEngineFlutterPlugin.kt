package click.vpnclient.engine.flutter.vpnclient_engine_flutter

import android.content.Context
import click.vpnclient.engine.VPNManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * VpnclientEngineFlutterPlugin
 * This class handles the communication between Flutter and native Android code
 * for managing VPN connections.
 */
class VpnclientEngineFlutterPlugin: FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    private lateinit var channel : MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vpnclient_engine_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startVPN" -> startVPN(call, result)
            "stopVPN" -> stopVPN(result)
            "status" -> getStatus(result)
            "getPlatformVersion" -> getPlatformVersion(result)
            else -> result.notImplemented()
        }
    }

    /**
     * Start the VPN connection using the provided configuration.
     * @param call MethodCall containing the configuration.
     * @param result Result to send the success or error back to Flutter.
     */
    private fun startVPN(call: MethodCall, result: Result) {
        val config = call.argument<String>("config") ?: return result.error("NO_CONFIG", "Missing config", null)
        val success = VPNManager.startVPN(context, config)
        result.success(success)
    }

    /**
     * Stop the VPN connection.
     * @param result Result to send the success back to Flutter.
     */
    private fun stopVPN(result: Result) {
        VPNManager.stopVPN()
        result.success(true)
    }
    private fun getStatus(result: Result) {
         result.success(VPNManager.status())
    }
    private fun getPlatformVersion(result: Result) {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

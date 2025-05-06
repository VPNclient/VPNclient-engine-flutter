package click.vpnclient.engine.flutter.vpnclient_engine_flutter

import android.content.Context
import android.util.Log
import go.Seq
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
class VpnclientEngineFlutterPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // / The MethodChannel that will handle the communication between Flutter and native Android
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val TAG = "VpnclientEngineFlutterPlugin"

    private var singboxCore: SingBoxCore? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vpnclient_engine_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result,
    ) {
        when (call.method) {
            "startVPN" -> startVPN(call, result)
            "stopVPN" -> stopVPN(call, result)
            "status" -> getStatus(call, result)
            "getPlatformVersion" -> getPlatformVersion(result)
            else -> result.notImplemented()
        }
    }

    /**
     * Initialize sing-box.
     * @param config config for sing-box
     */
    private fun initSingbox(config: String) {
        try {
            singboxCore = SingBoxCore(config)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize sing-box", e)
        }
    }

    /**
     * Start the VPN connection using the provided configuration.
     * @param call MethodCall containing the configuration.
     * @param result Result to send the success or error back to Flutter.
     */
    private fun startVPN(
        call: MethodCall,
        result: Result,
    ) {
        val config = call.argument<String>("config") ?: return result.error("NO_CONFIG", "Missing config", null)
        try {
            initSingbox(config)
            singboxCore?.start()
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start sing-box", e)
            result.error("START_ERROR", "Failed to start sing-box", e.message)
        }
    }

    /**
     * Stop the VPN connection.
     * @param result Result to send the success back to Flutter.
     */
    private fun stopVPN(
        call: MethodCall,
        result: Result,
    ) {
        try {
            singboxCore?.stop()
            singboxCore = null // Release sing-box instance after stopping
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stop sing-box", e)
            result.error("STOP_ERROR", "Failed to stop sing-box", e.message)
        }
    }

    private fun getStatus(
        call: MethodCall,
        result: Result,
    ) {
        try {
            val status = singboxCore?.getStatus() ?: "stopped"
            result.success(status)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get sing-box status", e)
            result.error(
                "STATUS_ERROR",
                "Failed to get sing-box status",
                e.message,
            )
        }
    }

    private fun getPlatformVersion(result: Result) {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

class SingBoxCore(
    config: String,
) {
    private val TAG = "SingBoxCore"

    init {
        try {
            // Initialize the Go runtime
            Seq.setContext(null)
            // Load the sing-box configuration from the provided string
            Singbox.setConfig(config)
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing SingBox: ${e.message}")
            throw e
        }
    }

    /**
     * Start the SingBox core.
     * @throws Exception if there is an error starting SingBox.
     */
    fun start() {
        try {
            // Start the SingBox core
            val err: String? = Singbox.start()
            if (err != null && err.isNotEmpty()) {
                throw Exception("Error starting SingBox: $err")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error starting SingBox: ${e.message}")
            throw e
        }
    }

    /**
     * Stop the SingBox core.
     * @throws Exception if there is an error stopping SingBox.
     */
    fun stop() {
        try {
            // Stop the SingBox core
            Singbox.stop()
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping SingBox: ${e.message}")
            throw e
        }
    }

    fun getStatus(): String = Singbox.getStatus()
}

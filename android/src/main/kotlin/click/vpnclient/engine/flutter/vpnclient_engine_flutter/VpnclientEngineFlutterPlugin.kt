package click.vpnclient.engine.flutter.vpnclient_engine_flutter

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Intent
import android.app.Activity
import android.net.VpnService
import android.os.ParcelFileDescriptor
import java.io.File
import java.io.FileOutputStream

/**
 * VpnclientEngineFlutterPlugin
 * This class handles the communication between Flutter and native Android code
 * for managing VPN connections using sing-box.
 */
class VpnclientEngineFlutterPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will handle the communication between Flutter and native Android
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val TAG = "VpnclientEngineFlutterPlugin"
    
    // VPN service related
    private var vpnInterface: ParcelFileDescriptor? = null
    private var isVpnRunning: Boolean = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vpnclient_engine_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        Log.d(TAG, "VpnclientEngineFlutterPlugin attached to engine")
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result,
    ) {
        when (call.method) {
            "getPlatformVersion" -> getPlatformVersion(result)
            "connect" -> connect(call, result)
            "disconnect" -> disconnect(result)
            "requestPermissions" -> requestPermissions(result)
            "getConnectionStatus" -> getConnectionStatus(result)
            else -> {
                Log.w(TAG, "Method ${call.method} not implemented")
                result.notImplemented()
            }
        }
    }

    /**
     * Request VPN permissions
     */
    private fun requestPermissions(result: Result) {
        try {
            val intent = VpnService.prepare(context)
            if (intent != null) {
                // Need to request VPN permissions
                Log.d(TAG, "VPN permissions need to be requested")
                result.success(false)
            } else {
                // VPN permissions already granted
                Log.d(TAG, "VPN permissions already granted")
                result.success(true)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error requesting VPN permissions", e)
            result.error("PERMISSION_ERROR", "Failed to request VPN permissions", e.message)
        }
    }

    /**
     * Connect to VPN using sing-box
     */
    private fun connect(call: MethodCall, result: Result) {
        val url = call.argument<String>("url")
        val config = call.argument<String>("config")
        
        Log.d(TAG, "Connect called with URL: $url")
        
        try {
            // Check if we have VPN permissions
            val intent = VpnService.prepare(context)
            if (intent != null) {
                result.error("PERMISSION_ERROR", "VPN permissions not granted", null)
                return
            }
            
            // For now, we'll simulate sing-box connection
            // In a real implementation, you would:
            // 1. Use gomobile to call sing-box Go code
            // 2. Set up the VPN interface
            // 3. Start the sing-box process
            
            if (config != null) {
                // Save config to file and start sing-box
                startSingBoxWithConfig(config, result)
            } else {
                // Use URL-based connection
                startSingBoxWithUrl(url, result)
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error connecting to VPN", e)
            result.error("CONNECT_ERROR", "Failed to connect to VPN", e.message)
        }
    }

    /**
     * Start sing-box with configuration
     */
    private fun startSingBoxWithConfig(config: String, result: Result) {
        try {
            // Save config to temporary file
            val configFile = File(context.cacheDir, "sing-box-config.json")
            FileOutputStream(configFile).use { fos ->
                fos.write(config.toByteArray())
            }
            
            Log.d(TAG, "Sing-box config saved to: ${configFile.absolutePath}")
            
            // TODO: Implement actual sing-box integration
            // This would involve:
            // 1. Using gomobile to call sing-box Go code
            // 2. Setting up the VPN interface
            // 3. Starting the sing-box process
            
            // For now, simulate success
            isVpnRunning = true
            sendConnectionStatus("connected")
            result.success("Connected to VPN using sing-box (stub)")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error starting sing-box", e)
            result.error("SINGBOX_ERROR", "Failed to start sing-box", e.message)
        }
    }

    /**
     * Start sing-box with URL
     */
    private fun startSingBoxWithUrl(url: String?, result: Result) {
        try {
            Log.d(TAG, "Starting sing-box with URL: $url")
            
            // TODO: Implement URL-based sing-box connection
            // This would involve:
            // 1. Parsing the URL to extract configuration
            // 2. Converting to sing-box format
            // 3. Starting sing-box with the configuration
            
            // For now, simulate success
            isVpnRunning = true
            sendConnectionStatus("connected")
            result.success("Connected to VPN using sing-box URL (stub)")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error starting sing-box with URL", e)
            result.error("SINGBOX_URL_ERROR", "Failed to start sing-box with URL", e.message)
        }
    }

    /**
     * Disconnect from VPN
     */
    private fun disconnect(result: Result) {
        try {
            Log.d(TAG, "Disconnect called")
            
            // TODO: Implement actual sing-box disconnection
            // This would involve:
            // 1. Stopping the sing-box process
            // 2. Closing the VPN interface
            // 3. Cleaning up resources
            
            // For now, simulate disconnection
            isVpnRunning = false
            sendConnectionStatus("disconnected")
            result.success("Disconnected from VPN (stub)")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error disconnecting from VPN", e)
            result.error("DISCONNECT_ERROR", "Failed to disconnect from VPN", e.message)
        }
    }

    /**
     * Get current connection status
     */
    private fun getConnectionStatus(result: Result) {
        val status = if (isVpnRunning) "connected" else "disconnected"
        result.success(status)
    }

    /**
     * Send connection status to Flutter
     */
    private fun sendConnectionStatus(status: String) {
        channel.invokeMethod("onConnectionStatusChanged", status)
    }

    private fun getPlatformVersion(result: Result) {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        Log.d(TAG, "VpnclientEngineFlutterPlugin detached from engine")
    }
}

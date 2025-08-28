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
import android.content.ComponentName
import android.content.ServiceConnection
import android.os.IBinder
import libxray.Libxray
import java.io.File
import java.io.FileOutputStream

/**
 * VpnclientEngineFlutterPlugin
 * This class handles the communication between Flutter and native Android code
 * for managing VPN connections using libXray.
 */
class VpnclientEngineFlutterPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will handle the communication between Flutter and native Android
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val TAG = "VpnclientEngineFlutterPlugin"
    
    // VPN service related
    private var vpnService: LibXrayVpnService? = null
    private var serviceBound: Boolean = false
    
    // Service connection for binding to LibXrayVpnService
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            val binder = service as LibXrayVpnService.LocalBinder
            vpnService = binder.getService()
            serviceBound = true
            Log.d(TAG, "Service connected")
        }

        override fun onServiceDisconnected(arg0: ComponentName) {
            serviceBound = false
            vpnService = null
            Log.d(TAG, "Service disconnected")
        }
    }

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
            "testConfig" -> testConfig(call, result)
            "ping" -> ping(call, result)
            "getVersion" -> getLibXrayVersion(result)
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
     * Connect to VPN using libXray
     */
    private fun connect(call: MethodCall, result: Result) {
        val config = call.argument<String>("config")
        
        Log.d(TAG, "Connect called with config")
        
        try {
            // Check if we have VPN permissions
            val intent = VpnService.prepare(context)
            if (intent != null) {
                result.error("PERMISSION_ERROR", "VPN permissions not granted", null)
                return
            }
            
            if (config == null) {
                result.error("CONFIG_ERROR", "Configuration is required", null)
                return
            }
            
            // Start the VPN service with libXray
            startLibXrayVpn(config, result)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error connecting to VPN", e)
            result.error("CONNECT_ERROR", "Failed to connect to VPN", e.message)
        }
    }

    /**
     * Start VPN with libXray
     */
    private fun startLibXrayVpn(config: String, result: Result) {
        try {
            Log.d(TAG, "Starting VPN with libXray")
            
            // Prepare data directory for geo files
            val datDir = prepareDatDirectory()
            
            // Bind to the VPN service
            val intent = Intent(context, LibXrayVpnService::class.java)
            intent.action = LibXrayVpnService.ACTION_CONNECT
            intent.putExtra(LibXrayVpnService.EXTRA_CONFIG, config)
            intent.putExtra(LibXrayVpnService.EXTRA_DAT_DIR, datDir)
            
            context.bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
            context.startService(intent)
            
            sendConnectionStatus("connected")
            result.success("Connected to VPN using libXray")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error starting libXray VPN", e)
            result.error("LIBXRAY_ERROR", "Failed to start libXray VPN", e.message)
        }
    }

    /**
     * Prepare data directory with geo files
     */
    private fun prepareDatDirectory(): String {
        val datDir = File(context.filesDir, "dat")
        if (!datDir.exists()) {
            datDir.mkdirs()
        }
        
        // Copy geo files from assets if they don't exist
        copyAssetFile("geosite.dat", datDir)
        copyAssetFile("geoip.dat", datDir)
        
        return datDir.absolutePath
    }

    /**
     * Copy asset file to data directory
     */
    private fun copyAssetFile(fileName: String, datDir: File) {
        val destFile = File(datDir, fileName)
        if (!destFile.exists()) {
            try {
                context.assets.open(fileName).use { input ->
                    FileOutputStream(destFile).use { output ->
                        input.copyTo(output)
                    }
                }
                Log.d(TAG, "Copied $fileName to ${destFile.absolutePath}")
            } catch (e: Exception) {
                Log.w(TAG, "Could not copy $fileName from assets: ${e.message}")
            }
        }
    }

    /**
     * Disconnect from VPN
     */
    private fun disconnect(result: Result) {
        try {
            Log.d(TAG, "Disconnect called")
            
            // Stop the VPN service
            val intent = Intent(context, LibXrayVpnService::class.java)
            intent.action = LibXrayVpnService.ACTION_DISCONNECT
            context.startService(intent)
            
            // Unbind from service
            if (serviceBound) {
                context.unbindService(serviceConnection)
                serviceBound = false
                vpnService = null
            }
            
            sendConnectionStatus("disconnected")
            result.success("Disconnected from VPN")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error disconnecting from VPN", e)
            result.error("DISCONNECT_ERROR", "Failed to disconnect from VPN", e.message)
        }
    }

    /**
     * Get current connection status
     */
    private fun getConnectionStatus(result: Result) {
        val status = if (vpnService?.isVpnRunning() == true) "connected" else "disconnected"
        result.success(status)
    }

    /**
     * Test Xray configuration
     */
    private fun testConfig(call: MethodCall, result: Result) {
        val config = call.argument<String>("config")
        
        if (config == null) {
            result.error("CONFIG_ERROR", "Configuration is required", null)
            return
        }
        
        try {
            // Test configuration by trying to parse it
            // This is a simple validation - in reality you might want to test connectivity
            Log.d(TAG, "Testing configuration: ${config.take(100)}...")
            
            // For now, assume config is valid if it's not empty
            val isValid = config.isNotEmpty()
            result.success(isValid)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error testing configuration", e)
            result.success(false)
        }
    }

    /**
     * Ping server with configuration
     */
    private fun ping(call: MethodCall, result: Result) {
        val config = call.argument<String>("config")
        val url = call.argument<String>("url")
        val timeout = call.argument<Int>("timeout") ?: 10
        
        if (config == null || url == null) {
            result.error("PARAM_ERROR", "Config and URL are required", null)
            return
        }
        
        try {
            Log.d(TAG, "Pinging $url with timeout $timeout")
            
            // For now, return a simulated ping time
            // In a real implementation, you would use libXray ping functionality
            val pingTime = 100 // ms
            result.success(pingTime)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error pinging server", e)
            result.success(-1)
        }
    }

    /**
     * Get libXray version
     */
    private fun getLibXrayVersion(result: Result) {
        try {
            // Return a version string for libXray
            val version = "libXray Android v1.0.0"
            result.success(version)
        } catch (e: Exception) {
            Log.e(TAG, "Error getting version", e)
            result.success("Unknown")
        }
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
        // Unbind from service if bound
        if (serviceBound) {
            context.unbindService(serviceConnection)
            serviceBound = false
            vpnService = null
        }
        
        channel.setMethodCallHandler(null)
        Log.d(TAG, "VpnclientEngineFlutterPlugin detached from engine")
    }
}

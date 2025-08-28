package click.vpnclient.engine.flutter.vpnclient_engine_flutter

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.net.VpnService
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.os.ParcelFileDescriptor
import android.util.Log
import libxray.Libxray
import java.io.File
import java.io.FileOutputStream

/**
 * VPN Service that integrates with libXray
 */
class LibXrayVpnService : VpnService() {
    private val TAG = "LibXrayVpnService"
    private val CHANNEL_ID = "VPN_CHANNEL"
    private val NOTIFICATION_ID = 1
    
    private var vpnInterface: ParcelFileDescriptor? = null
    private var isVpnRunning: Boolean = false
    private val binder = LocalBinder()
    
    /**
     * Local binder for binding to the service
     */
    inner class LocalBinder : Binder() {
        fun getService(): LibXrayVpnService = this@LibXrayVpnService
    }

    override fun onBind(intent: Intent?): IBinder {
        return binder
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        Log.d(TAG, "LibXrayVpnService created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_CONNECT -> {
                val config = intent.getStringExtra(EXTRA_CONFIG)
                val datDir = intent.getStringExtra(EXTRA_DAT_DIR)
                if (config != null && datDir != null) {
                    startVpn(config, datDir)
                }
            }
            ACTION_DISCONNECT -> {
                stopVpn()
            }
        }
        return START_STICKY
    }

    /**
     * Start VPN connection with libXray
     */
    private fun startVpn(configJson: String, datDir: String) {
        try {
            Log.d(TAG, "Starting VPN with libXray")
            
            // Create notification for foreground service
            val notification = createNotification()
            startForeground(NOTIFICATION_ID, notification)
            
            // Setup VPN interface
            val builder = Builder()
                .setSession("LibXray VPN")
                .setMtu(1500)
                .addAddress("10.0.0.1", 32)
                .addRoute("0.0.0.0", 0)
                .addDnsServer("8.8.8.8")
                .addDnsServer("8.8.4.4")
            
            // Establish VPN interface
            vpnInterface = builder.establish()
            
            if (vpnInterface == null) {
                Log.e(TAG, "Failed to establish VPN interface")
                stopSelf()
                return
            }
            
            // Initialize libXray environment
            Libxray.initEnv(datDir)
            
            // Register dialer controller for socket protection
            val dialerController = object : libxray.DialerController {
                override fun protectFd(fd: Long): Boolean {
                    return protect(fd.toInt())
                }
            }
            Libxray.registerDialerController(dialerController)
            Libxray.registerListenerController(dialerController)
            
            // Start Xray with the provided configuration
            Libxray.runXrayFromJSON(datDir, configJson)
            
            isVpnRunning = true
            Log.d(TAG, "VPN started successfully")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error starting VPN", e)
            stopVpn()
        }
    }

    /**
     * Stop VPN connection
     */
    private fun stopVpn() {
        try {
            Log.d(TAG, "Stopping VPN")
            
            // Stop Xray
            if (isVpnRunning) {
                Libxray.stopXray()
            }
            
            // Close VPN interface
            vpnInterface?.close()
            vpnInterface = null
            
            isVpnRunning = false
            
            // Stop foreground service
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            
            Log.d(TAG, "VPN stopped successfully")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping VPN", e)
        }
    }

    /**
     * Check if VPN is currently running
     */
    fun isVpnRunning(): Boolean {
        return isVpnRunning && Libxray.getXrayState()
    }

    /**
     * Create notification channel for Android O+
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "VPN Service"
            val descriptionText = "VPN connection notification"
            val importance = NotificationManager.IMPORTANCE_LOW
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            
            val notificationManager: NotificationManager =
                getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    /**
     * Create notification for foreground service
     */
    private fun createNotification(): Notification {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("VPN Connected")
                .setContentText("LibXray VPN is running")
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setOngoing(true)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("VPN Connected")
                .setContentText("LibXray VPN is running")
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setOngoing(true)
                .build()
        }
    }

    override fun onDestroy() {
        stopVpn()
        super.onDestroy()
        Log.d(TAG, "LibXrayVpnService destroyed")
    }

    companion object {
        const val ACTION_CONNECT = "click.vpnclient.engine.flutter.ACTION_CONNECT"
        const val ACTION_DISCONNECT = "click.vpnclient.engine.flutter.ACTION_DISCONNECT"
        const val EXTRA_CONFIG = "extra_config"
        const val EXTRA_DAT_DIR = "extra_dat_dir"
    }
}

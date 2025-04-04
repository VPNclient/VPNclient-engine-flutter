package click.vpnclient.engine.flutter.vpnclient_engine_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

//import click.vpnclient.engine.VPNManager

/** VpnclientEngineFlutterPlugin */
class VpnclientEngineFlutterPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vpnclient_engine_flutter")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
        "startVPN" -> {
            val config = call.argument<String>("config") ?: return result.error("NO_CONFIG", "Missing config", null)
            //val success = VPNManager.startVPN(context, config)
            //result.success(success)
            result.success(null)
        }
        "stopVPN" -> {
            //VPNManager.stopVPN()
            result.success(null)
        }
        //"status" -> result.success(VPNManager.status())
    }
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

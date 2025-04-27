package com.vpnclient;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import android.util.Log;
import java.nio.charset.StandardCharsets;

import com.vpnclient.vpnclient.VpnStatusDelegate;

public class VpnClientModule extends ReactContextBaseJavaModule implements VpnStatusDelegate {
    private static final String TAG = "VpnClientModule";
    private ReactApplicationContext reactContext;

    public VpnClientModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        com.vpnclient.vpnclient.Vpnclient.INSTANCE.setVpnStatusDelegate(this);
    }

    @Override
    public String getName() {
        return "VpnClientManager";
    }

    private void sendEvent(String eventName, Object params) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

    @ReactMethod
    public void connect(String url, String config, String configType, Promise promise) {
        Log.i(TAG, "Starting VPN using url: " + url);
        Log.i(TAG, "Starting VPN using config: " + config);
        Log.i(TAG, "Starting VPN using configType: " + configType);
        try {
            byte[] byteArray = null;
            if (config != null) {
                byteArray = config.getBytes(StandardCharsets.UTF_8);
            }
            if (config != null && config.length() > 0 && configType.equals("ovpn")) {
                Log.i(TAG, "Connecting to ovpn...");
                com.vpnclient.vpnclient.Vpnclient.INSTANCE.startVpn(url, byteArray);
            } else {
                Log.i(TAG, "Connecting without config...");
                com.vpnclient.vpnclient.Vpnclient.INSTANCE.startVpn(url, null);
            }
             promise.resolve(null);
        }catch (Exception e){
            Log.e(TAG, "Error starting vpn", e);
            promise.reject("Error", "Error starting vpn");
        }
    }

    @ReactMethod
    public void disconnect(Promise promise) {
        Log.i(TAG, "Stopping VPN");
        try {
            com.vpnclient.vpnclient.Vpnclient.INSTANCE.stopVpn();
            promise.resolve(null);
        } catch (Exception e) {
            Log.e(TAG, "Error stopping vpn", e);
            promise.reject("Error", "Error stopping vpn");
        }
    }
    
    //VpnStatusDelegate

    @Override
    public void onVpnStatusChanged(String status) {
        Log.i(TAG, "VPN Status Changed: " + status);
        WritableMap params = Arguments.createMap();
        params.putString("status", status);
        sendEvent("onVpnStatusChanged", params);
    }

     @Override
    public void onVpnError(String error) {
       Log.e(TAG, "VPN Error: " + error);
       WritableMap params = Arguments.createMap();
       params.putString("error", error);
       sendEvent("onVpnError", params);
    }
}
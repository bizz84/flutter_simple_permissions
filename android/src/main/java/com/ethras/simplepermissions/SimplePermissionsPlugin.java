package com.ethras.simplepermissions;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * SimplePermissionsPlugin
 */
public class SimplePermissionsPlugin implements MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {
    private Registrar registrar;
    private Result result;
    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "simple_permissions");
        SimplePermissionsPlugin simplePermissionsPlugin = new SimplePermissionsPlugin(registrar);
        channel.setMethodCallHandler(simplePermissionsPlugin);
        registrar.addRequestPermissionsResultListener(simplePermissionsPlugin);
    }

    private SimplePermissionsPlugin(Registrar registrar) {
        this.registrar = registrar;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        String method = call.method;
        String permission;
        switch (method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "checkPermission":
                permission = call.argument("permission");
                result.success(checkPermission(permission));
                break;
            case "requestPermission":
                permission = call.argument("permission");
                this.result = result;
                requestPermission(permission);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private String getManifestPermission(String permission) {
        String res;
        switch (permission) {
            case "RECORD_AUDIO":
                res = Manifest.permission.RECORD_AUDIO;
                break;
            case "CAMERA":
                res = Manifest.permission.CAMERA;
                break;
            case "WRITE_EXTERNAL_STORAGE":
                res = Manifest.permission.WRITE_EXTERNAL_STORAGE;
                break;
            case "ACCESS_FINE_LOCATION":
                res = Manifest.permission.ACCESS_FINE_LOCATION;
                break;
            case "ACCESS_COARSE_LOCATION":
                res = Manifest.permission.ACCESS_COARSE_LOCATION;
                break;
            default:
                res = "ERROR";
                break;
        }
        return res;
    }

    private void requestPermission(String permission) {
        Activity activity = registrar.activity();
        permission = getManifestPermission(permission);
        Log.i("SimplePermission", "Requesting permission : " + permission);
        String[] perm = {permission};
        ActivityCompat.requestPermissions(activity, perm, 0);
    }

    private boolean checkPermission(String permission) {
        Activity activity = registrar.activity();
        permission = getManifestPermission(permission);
        Log.i("SimplePermission", "Checking permission : " + permission);
        return PackageManager.PERMISSION_GRANTED == ContextCompat.checkSelfPermission(activity, permission);
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] strings, int[] grantResults) {
        boolean res = false;
        if (requestCode == 0 && grantResults.length > 0) {
            res = grantResults[0] == PackageManager.PERMISSION_GRANTED;
            Log.i("SimplePermission", "Requesting permission result : " + res);
            result.success(res);
        }
        return  res;
    }
}

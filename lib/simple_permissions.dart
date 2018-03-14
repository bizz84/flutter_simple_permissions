import 'dart:async';

import 'package:flutter/services.dart';

class SimplePermissions {
  static const MethodChannel _channel =
      const MethodChannel('simple_permissions');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');

  /// Check a [permission] and return a [Future] with the result
  static Future<bool> checkPermission(Permission permission) {
    return _channel.invokeMethod(
        "checkPermission", {"permission": getPermissionString(permission)});
  }

  /// Request a [permission] and return a [Future] with the result
  static Future<bool> requestPermission(Permission permission) {
    return _channel.invokeMethod(
        "requestPermission", {"permission": getPermissionString(permission)});
  }

  static Future<bool> openSettings() {
    return _channel.invokeMethod("openSettings");
  }
}

enum Permission {
  RecordAudio,
  Camera,
  WriteExternalStorage,
  AccessCoarseLocation,
  AccessFineLocation,
  WhenInUseLocation,
  AlwaysLocation
}

String getPermissionString(Permission permission) {
  String res;
  switch (permission) {
    case Permission.Camera:
      res = "CAMERA";
      break;
    case Permission.RecordAudio:
      res = "RECORD_AUDIO";
      break;
    case Permission.WriteExternalStorage:
      res = "WRITE_EXTERNAL_STORAGE";
      break;
    case Permission.AccessFineLocation:
      res = "ACCESS_FINE_LOCATION";
      break;
    case Permission.AccessCoarseLocation:
      res = "ACCESS_COARSE_LOCATION";
      break;
    case Permission.WhenInUseLocation:
      res = "WHEN_IN_USE_LOCATION";
      break;
    case Permission.AlwaysLocation:
      res = "ALWAYS_LOCATION";
      break;
    default:
      res = "ERROR";
  }
  return res;
}

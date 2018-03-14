# Simple Permissions

A new flutter plugin for checking and requesting permissions on iOs and Android.

## Getting Started

Make sure you add the needed permissions to your Android Manifest  [Permission](https://developer.android.com/reference/android/Manifest.permission.html)
and Info.plist.

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## API
### List of currently available permissions

```dart
enum Permission {
  // Microphone
  RecordAudio,

  // Camera
  Camera,

  // External Storage
  WriteExternalStorage,

  // Access Coarse Location (Android) / When In Use iOs
  AccessCoarseLocation,

  // Access Fine Location (Android) / When In Use iOS
  AccessFineLocation,

  // Access Fine Location (Android) / When In Use iOS
  WhenInUseLocation,

  // Access Fine Location (Android) / Always Location iOS  
  AlwaysLocation
}
```

### Methods
```dart
  /// Check a [permission] and return a [Future] with the result
  static Future<bool> checkPermission(Permission permission);

  /// Request a [permission] and return a [Future] with the result
  static Future<bool> requestPermission(Permission permission);

  /// Open app settings on Android and iOs
  static Future<bool> openSettings();
```

## Usage



Check permission

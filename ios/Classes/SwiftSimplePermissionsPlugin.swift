import Flutter
import UIKit
import AVFoundation
import CoreLocation

extension AVAuthorizationStatus : CustomStringConvertible {
  
  public var description: String {
    switch self {
    case .notDetermined: return "notDetermined"
    case .restricted: return "restricted"
    case .denied: return "denied"
    case .authorized: return "authorized"
    }
  }
}

public class SwiftSimplePermissionsPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    var whenInUse = false;
    var result: FlutterResult? = nil;
    var locationManager = CLLocationManager()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "simple_permissions", binaryMessenger: registrar.messenger())
        let instance = SwiftSimplePermissionsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        locationManager.delegate = self;
        let method = call.method;
        let dic = call.arguments as? [String: Any];
        switch(method) {
        case "checkCameraPermission":
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            result(authStatus.description)
        case "checkPermission":
            let permission = dic!["permission"] as! String;
            checkPermission(permission, result: result);
            break;
        case "requestPermission":
            let permission = dic!["permission"] as! String;
            requestPermission(permission, result: result);
            break;
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            break;
        case "openSettings":
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        result(true);
                    } else {
                        // Fallback on earlier versions
                        result(FlutterMethodNotImplemented);
                    }
                }
            }
            break;
        default:
            result(FlutterMethodNotImplemented);
            break;
        }
        
    }
    private func requestPermission(_ permission: String, result: @escaping FlutterResult) {
        switch(permission) {
        case "RECORD_AUDIO":
            requestAudioPermission(result: result);
            break;
        case "CAMERA":
            requestCameraPermission(result: result);
            break;
case "ACCESS_COARSE_LOCATION", "ACCESS_FINE_LOCATION", "WHEN_IN_USE_LOCATION":
            self.result = result;
            requestLocationWhenInUsePermission();
            break;
        case "ALWAYS_LOCATION":
            self.result = result;
            requestLocationAlwaysPermission();
            break;
        default:
            result(FlutterMethodNotImplemented);
            break;
        }
    }
    
    private func checkPermission(_ permission: String, result: @escaping FlutterResult) {
        switch(permission) {
        case "RECORD_AUDIO":
            result(checkAudioPermission());
            break;
        case "CAMERA":
            result(checkCameraPermission());
            break;
        case "ACCESS_COARSE_LOCATION", "ACCESS_FINE_LOCATION", "WHEN_IN_USE_LOCATION":
            result(checkLocationWhenInUsePermission());
            break;
        case "ALWAYS_LOCATION":
            result(checkLocationAlwaysPermission());
            break;
        default:
            result(FlutterMethodNotImplemented);
            break;
        }
    }
    
    private func checkLocationAlwaysPermission() -> Bool {
        return CLLocationManager.authorizationStatus() == .authorizedAlways;
    }
    
    private func checkLocationWhenInUsePermission() -> Bool {
        let authStatus = CLLocationManager.authorizationStatus();
        return  authStatus == .authorizedAlways  || authStatus == .authorizedWhenInUse;
    }
    
    private func requestLocationWhenInUsePermission() -> Void {
        if (CLLocationManager.authorizationStatus() == .notDetermined) {
            self.whenInUse = true;
            locationManager.requestWhenInUseAuthorization();
        }
        else  {
            self.result!(checkLocationWhenInUsePermission());
        }
    }
    
    private func requestLocationAlwaysPermission() -> Void {
        if (CLLocationManager.authorizationStatus() == .notDetermined) {
        self.whenInUse = false;
        locationManager.requestAlwaysAuthorization();
        }
        else  {
            self.result!(checkLocationAlwaysPermission());
        }
    }
    
    public func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if (whenInUse)  {
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self.result!(true);
                break;
            default:
                self.result!(false);
                break;
            }
        }
        else {
            self.result!(status == .authorizedAlways)
        }
    }
    
    private func checkAudioPermission() -> Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio);
        return authStatus == .authorized;
    }
    
    private func requestAudioPermission(result: @escaping FlutterResult) -> Void {
        if (AVAudioSession.sharedInstance().responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({granted in
                result(granted);
            })
        }
    }
    
    private func checkCameraPermission()-> Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video);
        return authStatus == .authorized;
    }
    
    private func requestCameraPermission(result: @escaping FlutterResult) -> Void {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            result(response);
        }
    }
}

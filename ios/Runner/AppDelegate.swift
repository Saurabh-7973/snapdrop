import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "security/jailbreak", binaryMessenger: controller.binaryMessenger)

    // Handle method calls from Flutter
    channel.setMethodCallHandler { (call, result) in
        if call.method == "isJailbroken" {
            result(JailbreakDetector.isJailbroken()) // Return the jailbreak status
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    //For Screenshot
    let window = UIWindow()
    window.isHidden = false
    window.layer.contents = nil

    
    //For Overlay
    UIApplication.shared.beginIgnoringInteractionEvents()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}


class JailbreakDetector {
    static func isJailbroken() -> Bool {
        let fileManager = FileManager.default
        
        // 🚨 Check for common jailbreak files
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/Applications/FakeCarrier.app",
            "/Applications/blackra1n.app",
            "/Applications/Icy.app",
            "/Applications/IntelliScreen.app",
            "/Applications/MxTube.app",
            "/Applications/RockApp.app",
            "/Applications/SBSettings.app",
            "/Applications/WinterBoard.app",
            "/bin/bash",
            "/bin/sh",
            "/etc/apt",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/usr/bin/sshd",
            "/usr/libexec/sftp-server",
            "/private/var/tmp/cydia.log",
            "/var/tmp/cydia.log"
        ]
        
        for path in jailbreakPaths {
            if fileManager.fileExists(atPath: path) {
                return true
            }
        }
        
        // 🚨 Check if app can open Cydia
        if let cydiaUrl = URL(string: "cydia://package/com.example.package"),
           UIApplication.shared.canOpenURL(cydiaUrl) {
            return true
        }
        
        // 🚨 Check for suspicious sandbox behavior
        let testWrite = "/private/jailbreak.txt"
        do {
            try "Jailbreak Test".write(toFile: testWrite, atomically: true, encoding: .utf8)
            try fileManager.removeItem(atPath: testWrite)
            return true
        } catch {
            return false
        }
    }
}
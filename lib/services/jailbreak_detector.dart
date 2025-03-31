import 'dart:io';
import 'package:flutter/services.dart';

class JailbreakDetector {
  static const MethodChannel _channel = MethodChannel('security/jailbreak');

  /// Checks if the device is jailbroken and exits the app if detected
  static Future<void> checkJailbreakStatus() async {
    try {
      final bool isJailbroken = await _channel.invokeMethod('isJailbroken');
      if (isJailbroken) {
        exit(0); // Immediately exit the app
      }
    } catch (e) {
      print("e");
    }
  }
}

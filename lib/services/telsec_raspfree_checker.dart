import 'dart:io';
import 'package:flutter/material.dart';
import 'package:freerasp/freerasp.dart';

import '../main.dart';
import '../widgets/security_screen.dart';

class TelsecRaspfreeChecker {
  final BuildContext context;

  TelsecRaspfreeChecker(this.context);

  Future<void> automatedSecurityCheck() async {
    // Convert SHA-256 hash to Base64 (Ensure the format is correct)
    String base64Hash = hashConverter.fromSha256toBase64(
        "3A:72:93:F2:13:B4:42:B3:4D:03:D8:39:05:54:14:14:AA:80:6B:5E:7F:55:84:E7:94:D1:0B:90:C1:A7:21:CA");

    // Configure Talsec RASP for security checks
    final config = TalsecConfig(
      androidConfig: AndroidConfig(
        packageName: 'com.saurabh7973.snapdrop',
        signingCertHashes: [base64Hash],
      ),
      iosConfig: IOSConfig(
        bundleIds: ['com.saurabh7973.snapdrop'],
        teamId: 'YOUR APP STORE TEAM ID HERE',
      ),
      isProd: true,
      watcherMail: 'saurabhupadhyay7973developers@gmail.com',
    );

    // Define security threat responses
    final callback = ThreatCallback(
      onAppIntegrity: () => logSecurityIssue("App integrity compromised!"),
      onObfuscationIssues: () =>
          logSecurityIssue("Code obfuscation issues detected!"),
      onDebug: () => logSecurityIssue("Debugger detected!"),
      onDeviceBinding: () => logSecurityIssue("Device binding issue detected!"),
      onDeviceID: () => logSecurityIssue("Device ID manipulation detected!"),
      onHooks: () => logSecurityIssue("Hooking detected!"),
      onPrivilegedAccess: () => logSecurityIssue("Root/jailbreak detected!"),
      onSecureHardwareNotAvailable: () =>
          logSecurityIssue("Secure hardware is missing!"),
      onSimulator: () => logSecurityIssue("Running on an emulator!"),
      onUnofficialStore: () =>
          logSecurityIssue("App installed from an unofficial store!"),
    );

    // Attach the listener first
    Talsec.instance.attachListener(callback);

    // Start security monitoring
    await Talsec.instance.start(config);
  }

  // Show Security Warning Screen Instead of Exiting Immediately
  void logSecurityIssue(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => SecurityScreen(message: message),
      ));
    });
  }
}

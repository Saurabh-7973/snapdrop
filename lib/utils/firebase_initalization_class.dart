import 'dart:developer';
import 'dart:ui';

import 'package:Snapdrop/services/check_app_version.dart';
import 'package:Snapdrop/utils/firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class FirebaseInitalizationClass {
  static FirebaseAnalytics? analytics;
  static FirebaseAnalyticsObserver? observer;
  static FirebaseRemoteConfig? remoteConfig;

  static Future<void> initalizeFireBase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static void initalizeFireBaseAnalytics() {
    analytics = FirebaseAnalytics.instance;
    observer = FirebaseAnalyticsObserver(analytics: analytics!);
  }

  static void eventTracker(String name, Map<String, Object?>? parameters) {
    analytics!.logEvent(name: name, parameters: parameters);
  }

  static void enableDataCollection() {
    analytics!.setAnalyticsCollectionEnabled(true);
  }

  static void disableDataCollection() {
    analytics!.setAnalyticsCollectionEnabled(false);
  }

  static void catchFatalErrors() {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  static void catchAsynchronusErrors() {
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static void remoteConfigInitialization() async {
    remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig!.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
  }

  static void remoteConfigSetDefaultValues() async {
    await remoteConfig!.setDefaults(const {
      "app_version": 1.0,
    });
  }

  static void remoteConfigGetDefaultValues() async {
    await remoteConfig!.fetchAndActivate().then((value) {
      log(value.toString());
    });
  }

  static void remoteConfigUpdateValuesRealtime() async {
    remoteConfig!.onConfigUpdated.listen((event) async {
      await remoteConfig!.activate();
    });
  }

  static void remoteConfigFetchAppVersion() {
    CheckAppVersion.minimumAppVersion = remoteConfig!.getString('app_version');
    CheckAppVersion.checkAppVersion();
  }
}

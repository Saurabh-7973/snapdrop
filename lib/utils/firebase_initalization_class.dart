import 'dart:developer';

import 'package:Snapdrop/services/check_app_version.dart';
import 'package:Snapdrop/utils/firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class FirebaseInitalizationClass {
  static FirebaseAnalytics? analytics;
  static FirebaseAnalyticsObserver? observer;
  static FirebaseRemoteConfig? remoteConfig;
  static FirebasePerformance? performance;

  static Future<void> initalizeFireBase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static void initalizeFireBaseAnalytics() {
    analytics = FirebaseAnalytics.instance;
    observer = FirebaseAnalyticsObserver(analytics: analytics!);
  }

  static void eventTracker(String name, Map<String, Object>? parameters) {
    if (!kDebugMode) {
      analytics!.logEvent(name: name, parameters: parameters);
    }
  }

  static void enableDataCollection() {
    analytics!.setAnalyticsCollectionEnabled(true);
  }

  static void disableDataCollection() {
    analytics!.setAnalyticsCollectionEnabled(false);
  }

  static void catchFatalErrors() {
    if (!kDebugMode) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
    }
  }

  static void catchAsynchronusErrors() {
    if (!kDebugMode) {
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
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

  // ---- Performance monitoring (P1-8) ----
  // Collects in the field once google-services.json is in place (see REVIVAL_LOG).
  static void initalizePerformance() {
    performance = FirebasePerformance.instance;
  }

  /// Custom trace, e.g. `time_to_pair`, `transfer_duration`. Returns null if
  /// performance isn't available (e.g. unit tests). Caller starts/stops + sets metrics.
  static Trace? newTrace(String name) => performance?.newTrace(name);

  // ---- Crashlytics depth (P1-8): non-fatals, custom keys, breadcrumbs ----
  /// Record a caught (non-fatal) exception with context, on the transfer/pairing/
  /// permission paths. No-op in debug to match the existing crash-handler gating.
  static void recordNonFatal(Object error, StackTrace? stack, {String? reason}) {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance
          .recordError(error, stack, reason: reason, fatal: false);
    }
  }

  /// Attach context that rides along with the next crash/non-fatal report
  /// (current screen, transfer state, image count, payload size, paired/not).
  static void setCustomKey(String key, Object value) {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.setCustomKey(key, value);
    }
  }

  /// Breadcrumb along the flow (shows up in the crash timeline).
  static void breadcrumb(String message) {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.log(message);
    }
  }
}

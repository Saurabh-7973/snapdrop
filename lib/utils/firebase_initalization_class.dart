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

  /// Full Remote Config setup, run once after first frame. Every step here is
  /// best-effort: a fetch on a slow/offline device throws
  /// PlatformException(firebase_remote_config, "Unable to connect to the
  /// server…") and, because these used to be `void async`, that error escaped
  /// uncaught to PlatformDispatcher.onError and was logged as a FATAL crash
  /// (crash-on-startup reports on budget devices). Remote Config is optional —
  /// never let it take down the app. Failures are recorded as non-fatals.
  static Future<void> setupRemoteConfig() async {
    try {
      remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig!.setDefaults(const {
        "app_version": 1.0,
      });
      // Defaults are already applied above, so a failed fetch is harmless.
      final activated = await remoteConfig!.fetchAndActivate();
      log(activated.toString());
      remoteConfigFetchAppVersion();
      remoteConfigUpdateValuesRealtime();
    } catch (e, s) {
      // Offline / slow network is expected — degrade gracefully to defaults.
      recordNonFatal(e, s, reason: 'remoteConfig setup failed');
    }
  }

  static void remoteConfigUpdateValuesRealtime() {
    remoteConfig?.onConfigUpdated.listen((event) async {
      try {
        await remoteConfig!.activate();
      } catch (e, s) {
        recordNonFatal(e, s, reason: 'remoteConfig realtime activate failed');
      }
    });
  }

  static void remoteConfigFetchAppVersion() {
    final rc = remoteConfig;
    if (rc == null) return;
    CheckAppVersion.minimumAppVersion = rc.getString('app_version');
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
  static void recordNonFatal(Object error, StackTrace? stack,
      {String? reason}) {
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

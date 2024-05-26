import 'package:Snapdrop/utils/firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseInitalizationClass {
  static FirebaseAnalytics? analytics;
  static FirebaseAnalyticsObserver? observer;

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
}

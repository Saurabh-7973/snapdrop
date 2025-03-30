import 'package:in_app_review/in_app_review.dart';

import '../utils/firebase_initalization_class.dart';

class InAppReviewService {
  final InAppReview inAppReview = InAppReview.instance;

  checkForInAppReview() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
      FirebaseInitalizationClass.eventTracker(
          'app_install', {'first_time': 'true'});
    }
  }
}

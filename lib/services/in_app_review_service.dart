class InAppReviewService {
  final InAppReview inAppReview = InAppReview.instance;

  Future<void> requestReview() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }
}

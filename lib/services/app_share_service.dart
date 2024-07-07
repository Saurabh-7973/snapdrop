import 'package:share_plus/share_plus.dart';

class AppShareService {
  void shareApp() {
    String url =
        'https://play.google.com/store/apps/details?id=com.saurabh7973.snapdrop&pcampaignid=web_share';

    Share.share(
      '🚀 Discover Snapdrop - the easiest way to transfer images directly to your Figma designs! 🎨\n\n'
      '📲 Download now and streamline your design workflow:\n\n'
      '$url',
    );
  }
}

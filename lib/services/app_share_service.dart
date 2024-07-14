import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

//flutter localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppShareService {
  void shareApp(BuildContext context) {
    String url =
        'https://play.google.com/store/apps/details?id=com.saurabh7973.snapdrop&pcampaignid=web_share';

    Share.share(
      '${AppLocalizations.of(context)!.app_share_text_1}  ${AppLocalizations.of(context)!.app_share_text_2} $url',
    );
  }
}

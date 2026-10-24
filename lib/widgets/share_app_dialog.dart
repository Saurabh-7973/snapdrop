import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_share_service.dart';
import 'app_dialog.dart';

/// De-hyped app-share prompt on the shared dark dialog card
/// (snapdrop_dialogs_inlanguage.html). Same trigger and behavior as before
/// (fires at reviewCounter == 3 after a successful transfer); only the surface
/// and copy changed. Primary "Share" → the OS share sheet + Play link.
Future<void> showShareDialog(BuildContext context) {
  return showAppDialog(
    context: context,
    icon: Icons.share_outlined,
    title: AppLocalizations.of(context)!.share_dialog_title,
    body: AppLocalizations.of(context)!.share_dialog_body,
    primaryLabel: AppLocalizations.of(context)!.share_dialog_share,
    secondaryLabel: AppLocalizations.of(context)!.share_dialog_maybe_later,
    onPrimary: () => AppShareService().shareApp(context),
  );
}

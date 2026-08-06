import 'package:flutter/material.dart';

import '../constant/theme_contants.dart';
import '../l10n/app_localizations.dart';
import 'qr_help_sheet.dart';
import 'step_badge.dart';

/// "How Snapdrop works" — the same three steps as onboarding, reachable at any
/// time from the "?" in the header. Onboarding is shown once on first launch;
/// testers who skipped or forgot it had no way back to the explanation.
Future<void> showHelpSheet(BuildContext context) async {
  final result = await showModalBottomSheet<Object?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0xFF040A07).withValues(alpha: 0.62),
    // Chaining is driven from HERE, not from inside the sheet: the sheet's own
    // context is defunct the moment it pops, so opening the QR sheet with it
    // would look up a Navigator on a dead element.
    builder: (sheetContext) => HelpSheet(
      onShowQrHelp: () => Navigator.of(sheetContext).pop(_chainQrHelp),
    ),
  );
  if (result == _chainQrHelp && context.mounted) {
    await showQrHelpSheet(context);
  }
}

/// Sentinel: "the user asked for the QR sheet next".
const Object _chainQrHelp = Object();

class HelpSheet extends StatelessWidget {
  /// Opens the "Where's the QR code?" sheet after this one closes.
  final VoidCallback onShowQrHelp;

  const HelpSheet({super.key, required this.onShowQrHelp});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF183121),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0x24FFFFFF))),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 26),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(
                l.onboarding_title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l.onboarding_subtitle,
                textAlign: TextAlign.center,
                style: ThemeConstant.subtitleMuted.copyWith(fontSize: 13.5),
              ),
              const SizedBox(height: 22),
              _step(1, l.onboarding_step1_title, l.onboarding_step1_desc),
              const SizedBox(height: 14),
              _step(2, l.onboarding_step2_title, l.onboarding_step2_desc),
              const SizedBox(height: 14),
              _step(3, l.onboarding_step3_title, l.onboarding_step3_desc),
              const SizedBox(height: 18),
              _note(l.onboarding_note),
              const SizedBox(height: 20),
              // Straight through to the QR explanation — the single most asked
              // question in testing.
              _ghostButton(
                label: l.scan_help_link,
                icon: Icons.qr_code_rounded,
                onTap: onShowQrHelp,
              ),
              const SizedBox(height: 10),
              _ghostButton(
                label: l.qr_help_dismiss,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(int n, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepBadge(n, size: 27),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 14.5,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF93A79C),
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _note(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.info_outline_rounded,
              size: 14, color: Colors.white.withValues(alpha: 0.5)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF93A79C),
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _ghostButton({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return SizedBox(
      height: 50,
      child: Material(
        color: Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

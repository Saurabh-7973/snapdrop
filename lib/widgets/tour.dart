import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constant/theme_contants.dart';
import '../l10n/app_localizations.dart';
import '../services/first_time_login.dart';
import '../utils/firebase_initalization_class.dart';

/// The first-run coach marks, wrapped so every screen's tour gets the same
/// Skip button. Skipping ends this screen's tour and marks the first run as
/// done, so the QR and send screens don't start their own tours afterwards.
class Tour extends StatefulWidget {
  /// Which screen's tour this is, for the `tutorial_skipped` event.
  final String screen;
  final WidgetBuilder builder;

  const Tour({super.key, required this.screen, required this.builder});

  @override
  State<Tour> createState() => _TourState();
}

class _TourState extends State<Tour> {
  // ShowCaseWidget takes no key, so keep a context from inside it instead.
  BuildContext? _inner;

  void _skip() {
    final inner = _inner;
    if (inner != null && inner.mounted) ShowCaseWidget.of(inner).dismiss();
    FirstTimeLogin.setFirstTimeLoginFalse();
    FirebaseInitalizationClass.eventTracker(
        'tutorial_skipped', {'screen': widget.screen});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ShowCaseWidget(
      blurValue: 1,
      autoPlayDelay: const Duration(seconds: 3),
      globalTooltipActionConfig: const TooltipActionConfig(
        alignment: MainAxisAlignment.end,
        position: TooltipActionPosition.inside,
      ),
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          name: l.tour_skip,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            color: ThemeConstant.ink,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          // Replaces the skip type's own tap, so it has to dismiss too.
          onTap: _skip,
        ),
      ],
      builder: (inner) {
        _inner = inner;
        return widget.builder(inner);
      },
    );
  }
}

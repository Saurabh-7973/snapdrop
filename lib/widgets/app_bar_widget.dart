import 'package:flutter/material.dart';

/// App header: wordmark centred in the bar, with optional back (leading) and
/// help (trailing) actions laid over it.
///
/// The wordmark used to sit between two Spacers in a Row, so any leading icon
/// pushed it off-centre — the header read as misaligned on every screen with a
/// back button. A Stack keeps it centred on the screen regardless of actions.
class AppBarWidget extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onBack;

  /// Optional trailing action (e.g. the "?" help button on Home).
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final String? actionTooltip;

  const AppBarWidget({
    super.key,
    this.showBackButton = false,
    this.onBack,
    this.actionIcon,
    this.onAction,
    this.actionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42, // mockup nav height
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        child: Stack(
          children: [
            Center(child: Image.asset("assets/logo/snapdrop_header-min.png")),
            if (showBackButton)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: _tapTarget(
                  // Points back along the reading direction under RTL too.
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack,
                  flip: Directionality.of(context) == TextDirection.rtl,
                ),
              ),
            if (actionIcon != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Tooltip(
                  message: actionTooltip ?? '',
                  child: _tapTarget(icon: actionIcon!, onTap: onAction),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tapTarget({
    required IconData icon,
    VoidCallback? onTap,
    bool flip = false,
  }) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Transform.flip(
          flipX: flip,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

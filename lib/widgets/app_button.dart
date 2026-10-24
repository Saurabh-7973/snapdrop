import 'package:flutter/material.dart';

import '../constant/theme_contants.dart';

/// The single button spec (design §5). Primary = solid white pill; secondary =
/// ghost pill (transparent, white-20% border). Fixed 52dp height, StadiumBorder,
/// optional leading icon + 8dp gap. Use [AppButtonRow] for the edge-to-edge,
/// equal-split two-button rows (transfer complete, dialogs).
class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool primary;

  /// Fixed pill width; null = fill available width.
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.primary = true,
    this.width,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.width,
  }) : primary = false;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? ThemeConstant.buttonInk : Colors.white;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ],
    );

    return SizedBox(
      width: width,
      height: 52,
      child: Material(
        color: primary ? Colors.white : Colors.transparent,
        shape: StadiumBorder(
          side: primary
              ? BorderSide.none
              : BorderSide(
                  color: Colors.white.withValues(alpha: 0.2), width: 1.3),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Edge-to-edge two-button row: ghost (left) + solid (right), equal split, 12dp
/// gap, both 52dp. Fixes the transfer-complete buttons that weren't full width.
class AppButtonRow extends StatelessWidget {
  final AppButton left;
  final AppButton right;
  const AppButtonRow({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

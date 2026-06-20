import 'dart:ui';
import 'package:flutter/material.dart';

import '../constant/theme_contants.dart';

/// The single, dark, on-brand dialog. Every former white `AlertDialog` routes
/// through this. Matches snapdrop_dialogs_inlanguage.html: dimmed + blurred
/// backdrop, centered #1E2A23 card (22px radius, white-8% border), optional
/// 48px soft-green icon, white bold title, muted body, 1–2 pill actions
/// (ghost on the left, solid on the right).
///
/// Resolves to `true` if the solid (primary) action is tapped, `false` if the
/// ghost (secondary) action or the backdrop is tapped. Callbacks fire after the
/// dialog is dismissed.
Future<bool?> showAppDialog({
  required BuildContext context,
  IconData? icon,
  required String title,
  required String body,
  required String primaryLabel,
  VoidCallback? onPrimary,
  String? secondaryLabel,
  VoidCallback? onSecondary,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: const Color(0x9E060C09), // rgba(6,12,9,.62)
    builder: (dialogCtx) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 18),
          child: _AppDialogCard(
            icon: icon,
            title: title,
            body: body,
            primaryLabel: primaryLabel,
            secondaryLabel: secondaryLabel,
            onPrimary: () {
              Navigator.of(dialogCtx).pop(true);
              onPrimary?.call();
            },
            onSecondary: () {
              Navigator.of(dialogCtx).pop(false);
              onSecondary?.call();
            },
          ),
        ),
      );
    },
  );
}

class _AppDialogCard extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String body;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  const _AppDialogCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeConstant.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 50,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: ThemeConstant.accentGreen.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Icon(icon, color: ThemeConstant.softGreen, size: 24),
            ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: ThemeConstant.ink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.18,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: ThemeConstant.muted,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (secondaryLabel != null) ...[
                Expanded(
                  child: _DialogButton(
                    label: secondaryLabel!,
                    solid: false,
                    onTap: onSecondary,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: _DialogButton(
                  label: primaryLabel,
                  solid: true,
                  onTap: onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final bool solid;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.solid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: solid ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: solid
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.2), width: 1.3),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: solid ? ThemeConstant.buttonInk : const Color(0xFFD6DCD8),
            ),
          ),
        ),
      ),
    );
  }
}

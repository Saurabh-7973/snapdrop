import 'package:flutter/material.dart';

import '../constant/theme_contants.dart';

/// Dark, on-brand toast — replaces the default grey SnackBar on this dark
/// background. Matches the no-internet toast in snapdrop_qr_edge_states.html:
/// #222E27 pill, white-10% border, rounded, glyph + message.
void appToast(
  BuildContext context,
  String message, {
  IconData icon = Icons.wifi_off_rounded,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 3),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: ThemeConstant.toastSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ThemeConstant.softGreen, size: 18),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFFE9ECE9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

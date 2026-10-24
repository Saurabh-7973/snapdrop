import 'package:flutter/material.dart';
import '../constant/theme_contants.dart';

/// The small rounded-square number badge shared by the onboarding step cards
/// and the "Where's the QR?" help sheet (locked design: mockups in
/// docs/mockups). Green-on-dark number, faint green fill + hairline border.
class StepBadge extends StatelessWidget {
  final int number;
  final double size;

  const StepBadge(this.number, {super.key, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF206946).withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(9),
        border:
            Border.all(color: ThemeConstant.accentOnDark.withValues(alpha: 0.26)),
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          fontFamily: 'Inter',
          color: ThemeConstant.accentOnDark,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

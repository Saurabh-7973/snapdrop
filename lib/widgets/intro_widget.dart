import 'package:flutter/material.dart';
import '../constant/theme_contants.dart';

class IntroWidget extends StatelessWidget {
  final IconData icon;
  final String text;

  const IntroWidget({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    bool isRTL = Directionality.of(context) == TextDirection.rtl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: ThemeConstant.accentGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
          ),
          child: Icon(icon, color: ThemeConstant.softGreen, size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Directionality(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFFEEF1EF),
                fontSize: 15.5,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.start,
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }
}

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
        Icon(
          icon,
          color: ThemeConstant.whiteColor,
          size: 30,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Directionality(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            child: Text(
              text,
              style: ThemeConstant.smallTextSizeWhiteFontWidth,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }
}

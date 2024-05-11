import 'package:flutter/material.dart';

import '../constant/theme_contants.dart';

class IntroWidget extends StatelessWidget {
  IconData icon;
  String text;
  IntroWidget({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: ThemeConstant.whiteColor,
          size: 30,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          text,
          style: ThemeConstant.smallTextSizeWhiteFontWidth,
        )
      ],
    );
  }
}

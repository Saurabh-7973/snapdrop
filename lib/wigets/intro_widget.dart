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
        Container(
          decoration: BoxDecoration(
            color: ThemeConstant.primaryAppColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
              )
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: ThemeConstant.whiteColor,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: ThemeConstant.smallTextSizeWhiteFontWidth,
            ),
          ),
        )
      ],
    );
  }
}

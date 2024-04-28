import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constant/theme_contants.dart';

class FigmaDisplayHelper extends StatelessWidget {
  const FigmaDisplayHelper({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeConstant themeConstant = ThemeConstant();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/svg_asset/figma.svg'),
        const SizedBox(
          width: 5,
        ),
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            "Scan QR code to Connect",
            style: ThemeConstant.smallTextSizeLight,
          ),
        )
      ],
    );
  }
}

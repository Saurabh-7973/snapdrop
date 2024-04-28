import 'package:flutter/material.dart';

import '../constant/theme_contants.dart';

class HeroText extends StatelessWidget {
  String firstLine;
  String secondLine;
  String thirdLine;

  HeroText(
      {super.key,
      required this.firstLine,
      required this.secondLine,
      required this.thirdLine});

  @override
  Widget build(BuildContext context) {
    final themeConstant = ThemeConstant();

    return Container(
      // color: Colors.amber,
      margin: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
      height: MediaQuery.of(context).size.height / 6,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          firstLine == ''
              ? Container()
              : Text(
                  firstLine,
                  style: ThemeConstant.largeTextSize,
                ),
          secondLine == ''
              ? Container()
              : Text(
                  secondLine,
                  style: ThemeConstant.largeTextSize,
                ),
          const SizedBox(
            height: 10,
          ),
          thirdLine == ''
              ? Container()
              : Text(
                  thirdLine,
                  style: ThemeConstant.smallTextSizeLight,
                ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constant/theme_contants.dart';

class HeroText extends StatelessWidget {
  String firstLine;
  String secondLine;
  String thirdLine;
  int? size;

  HeroText(
      {super.key,
      required this.firstLine,
      required this.secondLine,
      required this.thirdLine,
      this.size});

  @override
  Widget build(BuildContext context) {
    bool isRTL = Directionality.of(context) == TextDirection.rtl;
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
      height: MediaQuery.of(context).size.height / 6,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOut,
            builder: (context, offset, child) {
              return Transform.translate(
                offset: offset,
                child: Directionality(
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (firstLine.isNotEmpty)
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              firstLine,
                              textAlign: TextAlign.center,
                              style: ThemeConstant.largeTextSize,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      if (secondLine.isNotEmpty)
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              secondLine,
                              textAlign: TextAlign.center,
                              style: ThemeConstant.largeTextSize,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      if (thirdLine.isNotEmpty)
                        Flexible(
                          child: Text(
                            thirdLine,
                            textAlign: TextAlign.center,
                            style: ThemeConstant.smallTextSizeLight,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(height: 5),
                      Container(
                        height: 2,
                        width: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ThemeConstant.primaryAppColor.withValues(alpha: 0.6),
                              ThemeConstant.whiteColor.withValues(alpha: 0.2)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

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
                child: Column(
                  children: [
                    if (firstLine.isNotEmpty)
                      Text(
                        firstLine,
                        style: ThemeConstant.largeTextSize,
                      ),
                    if (secondLine.isNotEmpty)
                      Text(
                        secondLine,
                        style: ThemeConstant.largeTextSize,
                      ),
                    const SizedBox(height: 10),
                    if (thirdLine.isNotEmpty)
                      Text(
                        thirdLine,
                        style: ThemeConstant.smallTextSizeLight,
                      ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 2,
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ThemeConstant.primaryAppColor.withOpacity(0.6),
                            ThemeConstant.whiteColor.withOpacity(0.2)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

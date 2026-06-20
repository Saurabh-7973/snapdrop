import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onBack;

  const AppBarWidget({
    super.key,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42, // mockup nav height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        child: Row(
          children: [
            if (showBackButton)
              InkWell(
                onTap: onBack,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            const Spacer(),
            Image.asset("assets/logo/snapdrop_header-min.png"),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

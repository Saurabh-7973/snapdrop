import 'package:Snapdrop/constant/theme_contants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';

import 'home_screen.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  //final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (_) => HomeScreen(
                socketService: null,
              )),
    );
  }

  Widget _buildFullscreenImage() {
    return SvgPicture.asset(
      'assets/svg_asset/upload.svg',
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );
  }

  Widget _buildImage(String assetName,
      [double width = 350, double height = 400]) {
    return SvgPicture.asset(
      'assets/svg_asset/$assetName',
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: ThemeConstant.greenAccentColor,
      imagePadding: EdgeInsets.zero,
      // boxDecoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       colors: [Color(0xff206946), Color(0xff071414), Color(0xff040807)],
      //       begin: Alignment.topCenter,
      //       end: Alignment.bottomCenter,
      //     ),
      //   ),
    );

    return IntroductionScreen(
      //key: introKey,
      globalBackgroundColor: ThemeConstant.greenAccentColor,
      allowImplicitScrolling: true,
      autoScrollDuration: 3000,
      infiniteAutoScroll: true,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildImage('snapdrop_logo.svg', 50, 50)),
          ),
        ),
      ),
      // globalFooter: SizedBox(
      //   width: double.infinity,
      //   height: 60,
      //   child: ElevatedButton(
      //     child: const Text(
      //       'Let\'s go right away!',
      //       style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      //     ),
      //     onPressed: () => _onIntroEnd(context),
      //   ),
      // ),
      pages: [
        PageViewModel(
          title: "Welcome to Snapdrop!",
          body: "Effortless image transfer for UI/UX Designers.",
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            imageFlex: 3,
            bodyAlignment: Alignment.bottomCenter,
            imageAlignment: Alignment.topCenter,
          ),
          image: _buildImage('send.svg'),
          reverse: true,
        ),
        PageViewModel(
          title: "Choose Your Photos",
          body: "Pick the images you want to use in your Figma design.",
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            imageFlex: 3,
            bodyAlignment: Alignment.bottomCenter,
            imageAlignment: Alignment.topCenter,
          ),
          image: _buildImage('select_images.svg', 300, 500),
          reverse: true,
        ),
        PageViewModel(
          title: " Generate & Scan the Code",
          body:
              "1. Search Snapdrop Plugin on Figma. \n 2. Scan it with your phone's camera to Connect.",
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            imageFlex: 3,
            bodyAlignment: Alignment.bottomCenter,
            imageAlignment: Alignment.topCenter,
          ),
          image: _buildImage('qr_scan.svg'),
          reverse: true,
        ),
        PageViewModel(
          title: " Snap & Drop!",
          body: "Watch your images appear in Figma, ready to use.",
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            imageFlex: 3,
            bodyAlignment: Alignment.bottomCenter,
            imageAlignment: Alignment.topCenter,
          ),
          image: _buildImage('upload.svg'),
          reverse: true,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
      next: const Icon(Icons.arrow_forward, color: Colors.black87),
      done: const Text('Done',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.black87,
        activeSize: Size(22.0, 10.0),
        activeColor: Colors.black87,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25.0),
          ),
        ),
      ),
      dotsContainerDecorator: ShapeDecoration(
        color: ThemeConstant.whiteColor.withOpacity(0.6),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}

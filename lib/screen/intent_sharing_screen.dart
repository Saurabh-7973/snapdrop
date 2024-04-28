import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../wigets/app_bar_widget.dart';
import '../wigets/hero_text.dart';
import '../wigets/intent_file_displayer.dart';

class IntentSharingScreen extends StatefulWidget {
  List<SharedMediaFile>? listOfMedia;

  IntentSharingScreen({super.key, required this.listOfMedia});

  @override
  State<IntentSharingScreen> createState() => _IntentSharingScreenState();
}

class _IntentSharingScreenState extends State<IntentSharingScreen> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff206946), Color(0xff071414), Color(0xff040807)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                const AppBarWidget(),
                HeroText(
                  firstLine: "Shared Images",
                  secondLine: "from Other Apps",
                  thirdLine: "",
                ),
                Expanded(
                    child: IntentFileDisplayer(
                  isIntentSharing: true,
                  listOfMedia: widget.listOfMedia,
                  connectDisplayer: true,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

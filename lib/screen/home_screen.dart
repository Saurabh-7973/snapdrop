import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/socket_service.dart';
import '../wigets/app_bar_widget.dart';
import '../wigets/dropdown_view.dart';
import '../wigets/hero_text.dart';

class HomeScreen extends StatefulWidget {
  SocketService? socketService;
  HomeScreen({super.key, required this.socketService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
                Expanded(
                  flex: 3,
                  child: HeroText(
                    firstLine: "Select Images",
                    secondLine: "to Continue",
                    thirdLine: "Upto 10 images",
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: DropDownView(
                    socketService: widget.socketService,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

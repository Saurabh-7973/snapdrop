import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'screen/home_screen.dart';
import 'screen/intent_sharing_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Use the static instance provided by the package
  ReceiveSharingIntent receiveSharingIntent = ReceiveSharingIntent.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log('State : $state');

    if (state == AppLifecycleState.paused) {
      log('App Paused Triggered');
    }
    if (state == AppLifecycleState.resumed) {
      log('App Resumed Triggered');
      receiveSharingIntent.getMediaStream().listen(
          (List<SharedMediaFile> listOfMedia) async {
        if (listOfMedia.isNotEmpty) {
          Navigator.pop(context);
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => IntentSharingScreen(
                        listOfMedia: listOfMedia,
                      )));
        }
      }, onError: (err) {
        debugPrint("Error : $err");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<List<SharedMediaFile>>(
        future: receiveSharingIntent.getInitialMedia(),
        builder: (BuildContext context,
            AsyncSnapshot<List<SharedMediaFile>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return IntentSharingScreen(listOfMedia: snapshot.data);
            } else {
              return HomeScreen(
                socketService: null,
              );
            }
          } else {
            return const SizedBox(
                height: 10, width: 10, child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screen/home_screen.dart';
import 'screen/onboard_screen.dart';
import 'screen/qr_screen.dart';
import 'utils/firebase_initalization_class.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitalizationClass.initalizeFireBase();
  FirebaseInitalizationClass.initalizeFireBaseAnalytics();
  FirebaseInitalizationClass.enableDataCollection();
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
  bool? firstTimeAppOpen;

  @override
  void initState() {
    super.initState();
    // Obtain shared preferences.
    firstTimeInstallation();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // log('State : $state');

    if (state == AppLifecycleState.paused) {
      // log('App Paused Triggered');
    }
    if (state == AppLifecycleState.resumed) {
      // log('App Resumed Triggered');
      receiveSharingIntent.getMediaStream().listen(
          (List<SharedMediaFile> listOfMedia) async {
        if (listOfMedia.isNotEmpty) {
          Navigator.pop(context);
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QRScreen(
                        isIntentSharing: true,
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
      navigatorObservers: <NavigatorObserver>[
        FirebaseInitalizationClass.observer!
      ],
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<List<SharedMediaFile>>(
        future: receiveSharingIntent.getInitialMedia(),
        builder: (BuildContext context,
            AsyncSnapshot<List<SharedMediaFile>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              //return IntentSharingScreen(listOfMedia: snapshot.data);
              return QRScreen(
                isIntentSharing: true,
                listOfMedia: snapshot.data,
              );
            } else {
              return firstTimeAppOpen == true
                  ? const OnboardScreen()
                  : HomeScreen(
                      socketService: null,
                      isIntentSharing: false,
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

  firstTimeInstallation() async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    firstTimeAppOpen = prefs.getBool('firstTimeAppOpen');
    if (firstTimeAppOpen == null) {
      await prefs.setBool('firstTimeAppOpen', true);
      //Event (App Install)
      FirebaseInitalizationClass.eventTracker(
          'app_install', {'first_time': 'true'});
    } else if (firstTimeAppOpen == true) {
      await prefs.setBool('firstTimeAppOpen', false);
      //Event (App Launch)
      FirebaseInitalizationClass.eventTracker(
          'app_launch', {'first_time': 'false'});
    }
    firstTimeAppOpen = prefs.getBool('firstTimeAppOpen');
    setState(() {});
  }
}

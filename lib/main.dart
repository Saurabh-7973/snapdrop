import 'dart:async';
import 'package:Snapdrop/services/selected_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'screen/home_screen.dart';
import 'screen/language_selection.dart';
import 'screen/qr_screen.dart';
import 'utils/firebase_initalization_class.dart';
import 'package:upgrader/upgrader.dart';

// int languageIndex = 0;

final List<Locale> appLocales = [
  const Locale('en'),
  const Locale('es'),
  const Locale('zh'),
  const Locale('hi'),
  const Locale('ar'),
  const Locale('pt'),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitalizationClass.initalizeFireBase();
  FirebaseInitalizationClass.initalizeFireBaseAnalytics();
  FirebaseInitalizationClass.enableDataCollection();
  FirebaseInitalizationClass.catchFatalErrors();
  FirebaseInitalizationClass.catchAsynchronusErrors();
  FirebaseInitalizationClass.remoteConfigInitialization();
  FirebaseInitalizationClass.remoteConfigGetDefaultValues();
  FirebaseInitalizationClass.remoteConfigUpdateValuesRealtime();
  FirebaseInitalizationClass.remoteConfigFetchAppVersion();
  await Upgrader.clearSavedSettings(); // REMOVE this for release builds

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ReceiveSharingIntent receiveSharingIntent = ReceiveSharingIntent.instance;
  bool? firstTimeAppOpen;
  StreamSubscription<List<SharedMediaFile>>? _intentDataStreamSubscription;

  _MyAppState();

  @override
  void initState() {
    super.initState();
    firstTimeInstallation();
    WidgetsBinding.instance!.addObserver(this);

    // Listen to intent data streams
    _intentDataStreamSubscription = receiveSharingIntent
        .getMediaStream()
        .listen((List<SharedMediaFile> listOfMedia) async {
      if (listOfMedia.isNotEmpty && mounted) {
        Navigator.pop(context);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRScreen(
              isIntentSharing: true,
              listOfMedia: listOfMedia,
            ),
          ),
        );
      }
    }, onError: (err) {
      // Handle error
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Check if the widget is still mounted before navigating
      _intentDataStreamSubscription = receiveSharingIntent
          .getMediaStream()
          .listen((List<SharedMediaFile> listOfMedia) async {
        if (listOfMedia.isNotEmpty && mounted) {
          Navigator.pop(context);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRScreen(
                isIntentSharing: true,
                listOfMedia: listOfMedia,
              ),
            ),
          );
        }
      }, onError: (err) {
        // Handle error
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: appLocales[SelectedLanguage.selectedLanguageIndex],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: appLocales,
      navigatorObservers: <NavigatorObserver>[
        FirebaseInitalizationClass.observer!,
      ],
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<List<SharedMediaFile>>(
        future: receiveSharingIntent.getInitialMedia(),
        builder: (BuildContext context,
            AsyncSnapshot<List<SharedMediaFile>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return QRScreen(
                isIntentSharing: true,
                listOfMedia: snapshot.data!,
              );
            } else {
              return firstTimeAppOpen == true
                  //? const OnboardScreen()
                  ? LanguageSelectionScreen()
                  : HomeScreen(
                      socketService: null,
                      isIntentSharing: false,
                    );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void firstTimeInstallation() async {
    firstTimeAppOpen = true;
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // firstTimeAppOpen = prefs.getBool('firstTimeAppOpen');
    // if (firstTimeAppOpen == null || firstTimeAppOpen == false) {
    //   await prefs.setBool('firstTimeAppOpen', true);
    //   FirebaseInitalizationClass.eventTracker(
    //       'app_install', {'first_time': 'true'});
    // } else if (firstTimeAppOpen == true) {
    //   await prefs.setBool('firstTimeAppOpen', false);
    //   FirebaseInitalizationClass.eventTracker(
    //       'app_launch', {'first_time': 'false'});
    // }
    // firstTimeAppOpen = prefs.getBool('firstTimeAppOpen');
    // if (mounted) {
    //   setState(() {});
    // }
  }
}

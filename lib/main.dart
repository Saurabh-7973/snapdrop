import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screen/home_screen.dart';
import 'screen/onboard_screen.dart';
import 'screen/qr_screen.dart';
import 'utils/firebase_initalization_class.dart';
import 'package:upgrader/upgrader.dart';

// Flutter localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'utils/restart.dart';

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

  // Load stored language before app starts
  Locale locale = await getStoredLocale();
  runApp(MyApp(initialLocale: locale));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(locale);
    RestartWidget.restartApp(context);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ReceiveSharingIntent receiveSharingIntent = ReceiveSharingIntent.instance;
  bool? firstTimeAppOpen;
  StreamSubscription<List<SharedMediaFile>>? _intentDataStreamSubscription;
  Locale _selectedLocale = const Locale('en'); // Default to English

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.initialLocale;
    firstTimeInstallation();
    WidgetsBinding.instance.addObserver(this);

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
      debugPrint("Error : $err");
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
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
        debugPrint("Error : $err");
      });
    }
  }

  /// ✅ **Updates the language instantly**
  void changeLocale(Locale locale) async {
    await setStoredLocale(locale); // Save language preference
    setState(() {
      _selectedLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _selectedLocale, // Dynamically change language
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('zh'),
        Locale('hi'),
        Locale('fr'),
        Locale('ar')
      ],
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
              return QRScreen(
                isIntentSharing: true,
                listOfMedia: snapshot.data!,
              );
            } else {
              return firstTimeAppOpen == true
                  ? const OnboardScreen() // Navigate to onboarding
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    firstTimeAppOpen = prefs.getBool('firstTimeAppOpen');
    if (firstTimeAppOpen == null || firstTimeAppOpen == false) {
      await prefs.setBool('firstTimeAppOpen', true);
      FirebaseInitalizationClass.eventTracker(
          'app_install', {'first_time': 'true'});
    } else if (firstTimeAppOpen == true) {
      await prefs.setBool('firstTimeAppOpen', false);
      FirebaseInitalizationClass.eventTracker(
          'app_launch', {'first_time': 'false'});
    }

    firstTimeAppOpen = prefs.getBool('firstTimeAppOpen');
    if (mounted) {
      setState(() {});
    }
  }
}

/// ✅ Get stored language from SharedPreferences
Future<Locale> getStoredLocale() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('selectedLanguage');
  return Locale(languageCode ?? 'en'); // Default to English
}

/// ✅ Save selected language
Future<void> setStoredLocale(Locale locale) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('selectedLanguage', locale.languageCode);
}

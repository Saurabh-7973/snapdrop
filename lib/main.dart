import 'dart:async';
import 'package:Snapdrop/services/check_app_version.dart';
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
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';

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
  //FirebaseInitalizationClass.remoteConfigInitialization();
  //FirebaseInitalizationClass.remoteConfigGetDefaultValues();
  //FirebaseInitalizationClass.remoteConfigUpdateValuesRealtime();
  //FirebaseInitalizationClass.remoteConfigFetchAppVersion();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ReceiveSharingIntent receiveSharingIntent = ReceiveSharingIntent.instance;
  bool? firstTimeAppOpen;
  StreamSubscription<List<SharedMediaFile>>? _intentDataStreamSubscription;
  Locale? _locale;
  PackageInfo _packageInfo = PackageInfo();
  int? reviewCounter;

  @override
  void initState() {
    super.initState();
    firstTimeInstallation();
    WidgetsBinding.instance!.addObserver(this);

    _loadLocale();

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

    // In App Update
    //getPackageData();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getPackageData() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    _packageInfo = await PackageManager.getPackageInfo();
    await CheckAppVersion().checkForAppUpdate(_packageInfo);

    if (mounted) setState(() {});
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
      locale: _locale ?? appLocales[SelectedLanguage.selectedLanguageIndex],
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
    //firstTimeAppOpen = true; // for debug
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    firstTimeAppOpen = prefs.getBool('firstTimeAppOpen');
    reviewCounter = prefs.getInt('reviewCounter');
    if (reviewCounter == null) {
      await prefs.setInt('reviewCounter', 0);
    }
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

  void setLocale(Locale locale) {
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  void _loadLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? selectedIndex = prefs.getInt('selectedLanguageIndex');
    if (selectedIndex != null) {
      SelectedLanguage.selectedLanguageIndex = selectedIndex;
      setLocale(appLocales[selectedIndex]);
    }
  }
}

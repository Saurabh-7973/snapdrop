import 'dart:async';
import 'package:Snapdrop/services/check_app_version.dart';
import 'package:Snapdrop/services/selected_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'widgets/app_background.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'screen/home_screen.dart';
import 'screen/onboard_screen.dart';
import 'screen/qr_screen.dart';
import 'utils/firebase_initalization_class.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:guidester/guidester.dart';

final List<Locale> appLocales = [
  const Locale('en'),
  const Locale('es'),
  const Locale('zh'),
  const Locale('hi'),
  const Locale('ar'),
  const Locale('pt'),
  const Locale('fr'),
];

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ceiling on decoded-thumbnail memory so a long grid scroll can't bloat the
  // image cache (the grid loads many right-sized thumbs via AssetEntityImage).
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100 MB

  // Edge-to-edge: background bleeds behind transparent status & nav bars, light icons.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
    systemStatusBarContrastEnforced: false,
  ));

  // Critical for first paint + crash/analytics continuity — keep synchronous.
  await FirebaseInitalizationClass.initalizeFireBase();
  FirebaseInitalizationClass.initalizeFireBaseAnalytics();
  FirebaseInitalizationClass.enableDataCollection();
  FirebaseInitalizationClass.catchFatalErrors();
  FirebaseInitalizationClass.catchAsynchronusErrors();

  // Tester feedback. The api key is the switch: a release build passes no
  // --dart-define=GUIDESTER_KEY, the key is empty, and the overlay returns its
  // child on the first line of build(). Nothing else in this app changes.
  Guidester.init(apiKey: const String.fromEnvironment('GUIDESTER_KEY'));

  runApp(MyApp());

  // Non-critical — deferred until after the first frame so startup paints fast
  // (perf instrumentation + remote-config fetch don't gate the UI).
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FirebaseInitalizationClass.initalizePerformance();
    // Self-contained + fully guarded: ordered internally and can never throw
    // out (network failures degrade to defaults, logged as non-fatal).
    FirebaseInitalizationClass.setupRemoteConfig();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      firstTimeInstallation();
    });
    WidgetsBinding.instance.addObserver(this);

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

  Future<void> getPackageData() async {
    if (!mounted) return;
    _packageInfo = await PackageManager.getPackageInfo();
    await CheckAppVersion().checkForAppUpdate(_packageInfo);
    if (mounted) setState(() {});
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
        // Handle error
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      // The overlay wraps the app's own content and nothing else. It never
      // pushes a route and never replaces the tree, so the Navigator above it
      // is untouched.
      builder: (context, child) => GuidesterOverlay(child: child!),
      // Null until the user has picked a language: leaving it null lets Flutter
      // resolve the device locale against supportedLocales (English only if the
      // phone speaks nothing we ship). Pinning appLocales[0] here forced every
      // fresh install to English regardless of system language.
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: appLocales,
      // Analytics may be absent if Firebase failed to initialize on this device
      // — force-unwrapping it here crashed the first build (startup crash).
      navigatorObservers: <NavigatorObserver>[
        if (FirebaseInitalizationClass.observer != null)
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
                  ? const OnboardScreen()
                  : HomeScreen(
                      socketService: null,
                      isIntentSharing: false,
                    );
            }
          } else {
            return const AppBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(child: CircularProgressIndicator()),
              ),
            );
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
    // just to check
    // firstTimeAppOpen = null;
    if (firstTimeAppOpen == null) {
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
    if (selectedIndex != null &&
        selectedIndex >= 0 &&
        selectedIndex < appLocales.length) {
      SelectedLanguage.selectedLanguageIndex = selectedIndex;
      setLocale(appLocales[selectedIndex]);
    }
  }
}

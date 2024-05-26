// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCgxNnuaJg409evjzct-f6Vpx091Ftr4qs',
    appId: '1:62956973537:web:4d99fd567d8ee6c12ef6a0',
    messagingSenderId: '62956973537',
    projectId: 'snapdrop-e786e',
    authDomain: 'snapdrop-e786e.firebaseapp.com',
    storageBucket: 'snapdrop-e786e.appspot.com',
    measurementId: 'G-S08SZ2HBJ4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBuUx4ccbaw3Chp03JKTquk--CNPtCamB4',
    appId: '1:62956973537:android:0aad956b137b85632ef6a0',
    messagingSenderId: '62956973537',
    projectId: 'snapdrop-e786e',
    storageBucket: 'snapdrop-e786e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBm6zqCp5FgOLRjwYJQ-3NXnrliyKiylcw',
    appId: '1:62956973537:ios:3318cca4e8de70602ef6a0',
    messagingSenderId: '62956973537',
    projectId: 'snapdrop-e786e',
    storageBucket: 'snapdrop-e786e.appspot.com',
    iosBundleId: 'com.example.snapdrop',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBm6zqCp5FgOLRjwYJQ-3NXnrliyKiylcw',
    appId: '1:62956973537:ios:3318cca4e8de70602ef6a0',
    messagingSenderId: '62956973537',
    projectId: 'snapdrop-e786e',
    storageBucket: 'snapdrop-e786e.appspot.com',
    iosBundleId: 'com.example.snapdrop',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCgxNnuaJg409evjzct-f6Vpx091Ftr4qs',
    appId: '1:62956973537:web:83cf764f2e7008ca2ef6a0',
    messagingSenderId: '62956973537',
    projectId: 'snapdrop-e786e',
    authDomain: 'snapdrop-e786e.firebaseapp.com',
    storageBucket: 'snapdrop-e786e.appspot.com',
    measurementId: 'G-RZZ2P9ZHX7',
  );
}

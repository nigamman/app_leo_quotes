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
    apiKey: 'AIzaSyDCvsrD7m_-ITB-pE0hk9YHwwnbfPrrhhs',
    appId: '1:941534078452:web:84ba177d7a7f43ea8cc5a1',
    messagingSenderId: '941534078452',
    projectId: 'leoq-cc59a',
    authDomain: 'leoq-cc59a.firebaseapp.com',
    databaseURL: 'https://leoq-cc59a-default-rtdb.firebaseio.com',
    storageBucket: 'leoq-cc59a.appspot.com',
    measurementId: 'G-FY3BNM2MEY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkMPp9jQQignTUCxUCTwOoVlOxwb36Xrk',
    appId: '1:941534078452:android:41ded1c0b339a62f8cc5a1',
    messagingSenderId: '941534078452',
    projectId: 'leoq-cc59a',
    databaseURL: 'https://leoq-cc59a-default-rtdb.firebaseio.com',
    storageBucket: 'leoq-cc59a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALAIjcFLcxauQM_EmZhC3DAfyTY6HAZ18',
    appId: '1:941534078452:ios:2386ad23f88837f68cc5a1',
    messagingSenderId: '941534078452',
    projectId: 'leoq-cc59a',
    databaseURL: 'https://leoq-cc59a-default-rtdb.firebaseio.com',
    storageBucket: 'leoq-cc59a.appspot.com',
    iosBundleId: 'com.example.untitled5',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyALAIjcFLcxauQM_EmZhC3DAfyTY6HAZ18',
    appId: '1:941534078452:ios:2386ad23f88837f68cc5a1',
    messagingSenderId: '941534078452',
    projectId: 'leoq-cc59a',
    databaseURL: 'https://leoq-cc59a-default-rtdb.firebaseio.com',
    storageBucket: 'leoq-cc59a.appspot.com',
    iosBundleId: 'com.example.untitled5',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDCvsrD7m_-ITB-pE0hk9YHwwnbfPrrhhs',
    appId: '1:941534078452:web:e380103b3269523b8cc5a1',
    messagingSenderId: '941534078452',
    projectId: 'leoq-cc59a',
    authDomain: 'leoq-cc59a.firebaseapp.com',
    databaseURL: 'https://leoq-cc59a-default-rtdb.firebaseio.com',
    storageBucket: 'leoq-cc59a.appspot.com',
    measurementId: 'G-CZ62YJ9SE7',
  );

}
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
    apiKey: 'AIzaSyCuWlVM__P9whHEqCvXwIRAci060V5M2Dg',
    appId: '1:378817763502:web:096acb6272e18d2812353f',
    messagingSenderId: '378817763502',
    projectId: 'otomoto-1533c',
    authDomain: 'otomoto-1533c.firebaseapp.com',
    storageBucket: 'otomoto-1533c.firebasestorage.app',
    measurementId: 'G-02CF5Y50MY',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCuWlVM__P9whHEqCvXwIRAci060V5M2Dg',
    appId: '1:378817763502:web:cec1ec8536c8fc4b12353f',
    messagingSenderId: '378817763502',
    projectId: 'otomoto-1533c',
    authDomain: 'otomoto-1533c.firebaseapp.com',
    storageBucket: 'otomoto-1533c.firebasestorage.app',
    measurementId: 'G-2G1YXFKVD8',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDRnjQ4-P3i_380x1atdGbYOVkmrUzH6kE',
    appId: '1:378817763502:ios:7263e8f30566fb7f12353f',
    messagingSenderId: '378817763502',
    projectId: 'otomoto-1533c',
    storageBucket: 'otomoto-1533c.firebasestorage.app',
    iosBundleId: 'com.example.otomoto',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDRnjQ4-P3i_380x1atdGbYOVkmrUzH6kE',
    appId: '1:378817763502:ios:7263e8f30566fb7f12353f',
    messagingSenderId: '378817763502',
    projectId: 'otomoto-1533c',
    storageBucket: 'otomoto-1533c.firebasestorage.app',
    iosBundleId: 'com.example.otomoto',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_hNOA4xrp0622-IHRolE6eeuchWmcKX0',
    appId: '1:378817763502:android:56229b0040ed0afc12353f',
    messagingSenderId: '378817763502',
    projectId: 'otomoto-1533c',
    storageBucket: 'otomoto-1533c.firebasestorage.app',
  );

}
// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDb0WK37eCzqV-n1j9gByTlB0InCMgExtw',
    appId: '1:1065920604068:android:dcb85308fc825f9a8c0331',
    messagingSenderId: '1065920604068',
    projectId: 'deliverapp-4ce26',
    storageBucket: 'deliverapp-4ce26.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAi5A01CfT2_BMEDEb5_wYMEgvqTt88DvA',
    appId: '1:1065920604068:ios:ed221dcd17341f078c0331',
    messagingSenderId: '1065920604068',
    projectId: 'deliverapp-4ce26',
    storageBucket: 'deliverapp-4ce26.appspot.com',
    androidClientId: '1065920604068-qpte8illchj280si95o4rcrnf9ho9spt.apps.googleusercontent.com',
    iosClientId: '1065920604068-m58cl1r1tjie77iudenb4kna0ikbek82.apps.googleusercontent.com',
    iosBundleId: 'com.example.deliveryApp',
  );
}

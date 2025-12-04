// Clean, single-definition Firebase options for project: fir-flutter-codelab-5e0ce
// ignore_for_file: prefer_single_quotes, constant_identifier_names
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
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
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for linux - you can reconfigure this by running the FlutterFire CLI again.');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD7ffem2gX63FxEAc-7Bkckvf1ketKhWws',
    authDomain: 'fir-flutter-codelab-5e0ce.firebaseapp.com',
    projectId: 'fir-flutter-codelab-5e0ce',
    storageBucket: 'fir-flutter-codelab-5e0ce.firebasestorage.app',
    messagingSenderId: '825270004794',
    appId: '1:825270004794:web:99fdd070729fb9a5121903',
    measurementId: 'G-6NZD8X97QQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzUu48wwN5yAkjuKV_h1Bp9APg6JSGAe4',
    appId: '1:825270004794:android:2d51e8491a47442c121903',
    messagingSenderId: '825270004794',
    projectId: 'fir-flutter-codelab-5e0ce',
    storageBucket: 'fir-flutter-codelab-5e0ce.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAJiAbKau_jOvFjUbO-V-BgKpJUdAKNX00',
    appId: '1:825270004794:ios:b57746857f2393f8121903',
    messagingSenderId: '825270004794',
    projectId: 'fir-flutter-codelab-5e0ce',
    storageBucket: 'fir-flutter-codelab-5e0ce.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAJiAbKau_jOvFjUbO-V-BgKpJUdAKNX00',
    appId: '1:825270004794:ios:b57746857f2393f8121903',
    messagingSenderId: '825270004794',
    projectId: 'fir-flutter-codelab-5e0ce',
    storageBucket: 'fir-flutter-codelab-5e0ce.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD7ffem2gX63FxEAc-7Bkckvf1ketKhWws',
    appId: '1:825270004794:web:a46f0a8d97150f08121903',
    messagingSenderId: '825270004794',
    projectId: 'fir-flutter-codelab-5e0ce',
    authDomain: 'fir-flutter-codelab-5e0ce.firebaseapp.com',
    storageBucket: 'fir-flutter-codelab-5e0ce.firebasestorage.app',
    measurementId: 'G-LJB8TMFK3Q',
  );
}

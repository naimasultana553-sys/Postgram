import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDpBaXtRwKrqfcDMgw1PUcHH5Jb3J7dmLk',
    appId: '1:172894217379:web:8e82b1b32b98779cec4b16',
    messagingSenderId: '172894217379',
    projectId: 'postgram-1dfd2',
    authDomain: 'postgram-1dfd2.firebaseapp.com',
    storageBucket: 'postgram-1dfd2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDpBaXtRwKrqfcDMgw1PUcHH5Jb3J7dmLk',
    appId: '1:172894217379:android:some_guessed_id', // I'll use a placeholder for Android/iOS
    messagingSenderId: '172894217379',
    projectId: 'postgram-1dfd2',
    storageBucket: 'postgram-1dfd2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDpBaXtRwKrqfcDMgw1PUcHH5Jb3J7dmLk',
    appId: '1:172894217379:ios:some_guessed_id',
    messagingSenderId: '172894217379',
    projectId: 'postgram-1dfd2',
    storageBucket: 'postgram-1dfd2.firebasestorage.app',
    iosBundleId: 'com.example.postgram',
  );
}

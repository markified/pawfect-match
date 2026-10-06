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
    apiKey: 'AIzaSyDLiLjNL48OwIrT8errZyk5WK18r9z7idQ',
    appId: '1:357499125175:web:744cda1213f0110b16bc32',
    messagingSenderId: '357499125175',
    projectId: 'pawfect-match-a4d14',
    authDomain: 'pawfect-match-a4d14.firebaseapp.com',
    storageBucket: 'pawfect-match-a4d14.firebasestorage.app',
    measurementId: 'G-PM7BKXX6CX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBqwDBsp9MdQ3U2yLhh0S-5EdFWfJVBsyg',
    appId: '1:357499125175:android:084b2137c57cea2916bc32',
    messagingSenderId: '357499125175',
    projectId: 'pawfect-match-a4d14',
    storageBucket: 'pawfect-match-a4d14.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA4iwhMZ45cGyllzwuT4yVHQMHhHlt724o',
    appId: '1:357499125175:ios:1c2b1ff01b8e7fda16bc32',
    messagingSenderId: '357499125175',
    projectId: 'pawfect-match-a4d14',
    storageBucket: 'pawfect-match-a4d14.firebasestorage.app',
    iosBundleId: 'com.example.pawfect',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA4iwhMZ45cGyllzwuT4yVHQMHhHlt724o',
    appId: '1:357499125175:ios:1c2b1ff01b8e7fda16bc32',
    messagingSenderId: '357499125175',
    projectId: 'pawfect-match-a4d14',
    storageBucket: 'pawfect-match-a4d14.firebasestorage.app',
    iosBundleId: 'com.example.pawfect',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDLiLjNL48OwIrT8errZyk5WK18r9z7idQ',
    appId: '1:357499125175:web:fe7c2806a58c2a7316bc32',
    messagingSenderId: '357499125175',
    projectId: 'pawfect-match-a4d14',
    authDomain: 'pawfect-match-a4d14.firebaseapp.com',
    storageBucket: 'pawfect-match-a4d14.firebasestorage.app',
    measurementId: 'G-018D9QBC2C',
  );
}

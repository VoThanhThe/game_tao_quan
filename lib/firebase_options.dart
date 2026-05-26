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
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // 🌐 WEB
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBaMHeU5wjJbOYu9tNZnrE6QIWCFX__RuY",
    authDomain: "game-flappy-tao-quan.firebaseapp.com",
    projectId: "game-flappy-tao-quan",
    storageBucket: "game-flappy-tao-quan.firebasestorage.app",
    messagingSenderId: "751852021794",
    appId: "1:751852021794:web:507139f3793da4a4d9827b",
    measurementId: "G-PXGB7KKBEW",
    databaseURL: "https://game-flappy-tao-quan-default-rtdb.firebaseio.com",
  );

  // 🤖 ANDROID
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAyf-ktzpiiUyfygDbYlmJY9uY0ZaY8OGg",
    appId: "1:751852021794:android:f708ef6558e3d29cd9827b",
    messagingSenderId: "751852021794",
    projectId: "game-flappy-tao-quan",
    storageBucket: "game-flappy-tao-quan.firebasestorage.app",
  );

  // 🍎 iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDTEJ7Z2DZdKGr7tH9b0N_nGbFJ-RR_On4",
    appId: "1:751852021794:ios:51006930f19d0a56d9827b",
    messagingSenderId: "751852021794",
    projectId: "game-flappy-tao-quan",
    storageBucket: "game-flappy-tao-quan.firebasestorage.app",
    iosBundleId: "com.example.gameTaoQuan",
  );
}

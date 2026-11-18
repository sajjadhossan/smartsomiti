// File generated for somitiapp-1f0a2
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCg4XAdBGbZOLzrWnRmIh9QItthL9IAEGc',
    appId: '1:122717224216:web:9f108416895741b190726d',
    messagingSenderId: '122717224216',
    projectId: 'somitiapp-1f0a2',
    authDomain: 'somitiapp-1f0a2.firebaseapp.com',
    storageBucket: 'somitiapp-1f0a2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBaOVbmjGZi-7zyPGIc0LmP4Ou4_hW4shA',
    appId: '1:122717224216:android:de4a7bbc92ecd0b590726d',
    messagingSenderId: '122717224216',
    projectId: 'somitiapp-1f0a2',
    storageBucket: 'somitiapp-1f0a2.firebasestorage.app',
  );
}

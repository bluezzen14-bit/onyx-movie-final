import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAcyVYdazn6MzNuo8esv8BrRw7ew8GF3WQ',
    appId: '1:243702982500:android:5ba692bcbe72e0b3ec7c71',
    messagingSenderId: '243702982500',
    projectId: 'onyx-movies-2b58b',
    databaseURL: 'https://onyx-movies-2b58b-default-rtdb.firebaseio.com',
    storageBucket: 'onyx-movies-2b58b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAcyVYdazn6MzNuo8esv8BrRw7ew8GF3WQ',
    appId: '1:243702982500:ios:xxxx',
    messagingSenderId: '243702982500',
    projectId: 'onyx-movies-2b58b',
    databaseURL: 'https://onyx-movies-2b58b-default-rtdb.firebaseio.com',
    storageBucket: 'onyx-movies-2b58b.firebasestorage.app',
  );
}

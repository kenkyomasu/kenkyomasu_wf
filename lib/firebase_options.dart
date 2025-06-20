import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
        // ignore: unused_shown_name
        show
        // ignore: unused_shown_name
        defaultTargetPlatform,
        kIsWeb,
        // ignore: unused_shown_name
        TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAfngNII3iVr_nsSNBpgxhSDXBsa0AwtpQ',
    authDomain: 'pruebas-flutter-b71de.firebaseapp.com',
    databaseURL: 'https://pruebas-flutter-b71de-default-rtdb.firebaseio.com/',
    projectId: 'pruebas-flutter-b71de',
    storageBucket: 'pruebas-flutter-b71de.firebasestorage.app',
    messagingSenderId: '785349532440',
    appId: '1:785349532440:web:00a47b74361d845a251c6d',
    measurementId: 'G-2MJETHK2L1',
  );
}

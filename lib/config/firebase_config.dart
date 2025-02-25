import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static FirebaseOptions get platformOptions {
    // Utilise les options web pour le web ET pour Windows
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      return webOptions;
    } else {
      return defaultOptions;
    }
  }

  static const FirebaseOptions webOptions = FirebaseOptions(
    apiKey: 'AIzaSyAs9E4OGy_87bExSmRfZlAMChJT8d_8uZw',
    appId: '1:315559019098:web:e9a58373a7699baaa9ce63',
    messagingSenderId: '315559019098',
    projectId: 'ypmanagement-2302',
    authDomain: 'ypmanagement-2302.firebaseapp.com',
    storageBucket: 'ypmanagement-2302.firebasestorage.app',
    measurementId: 'G-9NK351L6PG',
  );

  static const FirebaseOptions defaultOptions = FirebaseOptions(
    apiKey: "AIzaSyAs9E4OGy_87bExSmRfZlAMChJT8d_8uZw",
    projectId: "ypmanagement-2302",
    storageBucket: "ypmanagement-2302.firebasestorage.app",
    messagingSenderId: "315559019098",
    appId: "1:315559019098:web:e9a58373a7699baaa9ce63",
  );
}

import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleAuthDesktop {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle() async {
    final googleSignInArgs = GoogleSignInArgs(
      clientId: '315559019098-linegi1g3s97l6p1vsf959pqhetcr17l.apps.googleusercontent.com', // Ton client OAuth Desktop
      redirectUri: 'http://localhost',
      scope: 'email profile',
    );

    try {
      final result = await DesktopWebviewAuth.signIn(googleSignInArgs);

      if (result == null || result.accessToken == null || result.idToken == null) {
        throw Exception('Erreur ou utilisateur annulé');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: result.accessToken!,
        idToken: result.idToken!,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Erreur OAuth Desktop: $e');
    }
  }
}



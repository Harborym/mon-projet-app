import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/google_auth_service.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Vérifier l'état de connexion dès l'ouverture
    _checkUserLogin();
  }

  void _checkUserLogin() {
    if (_auth.currentUser != null) {
      // si connecté, direction playlist automatiquement
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/environments');
      });
    }
  }

  void _signInWithGoogle(BuildContext context) async {
    final googleAuth = GoogleAuthService();
    try {
      final result = await googleAuth.signInWithGoogle();
      if (result != null) {

        // créer immédiatement entrée utilisateur si nécessaire
        final firestoreService = FirestoreService();
        await firestoreService.createUserIfNotExists();
        Navigator.pushReplacementNamed(context, '/environments');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion Google : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/youtube_logo.png', height: 50),
              const SizedBox(height: 25),
              const Text(
                'Youtube Playlist Manager',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/create-local');
                },
                child: const Text('Créer un environnement local'),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/open-local');
                },
                child: const Text('Ouvrir un environnement local'),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () => _signInWithGoogle(context),
                icon: const Icon(Icons.login),
                label: const Text('Se connecter avec Google'),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/ypm-auth');
                },
                child: const Text('Se connecter avec YPM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youtubeplaylistmanager/screens/environment_screen.dart';
import 'package:youtubeplaylistmanager/screens/environments_screen.dart';
import 'config/firebase_config.dart';
import 'screens/home_screen.dart';
//import 'screens/playlist_screen.dart';
import 'screens/local_environnement_screen.dart';
import 'screens/open_local_environment_screen.dart';
import 'screens/ypm_auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
  //await Firebase.initializeApp(options: FirebaseConfig.platformOptions);
  //} else {
  //await Firebase.initializeApp();
  //}
  //runApp(const MyApp());
//}

  if (kIsWeb) {
    await Firebase.initializeApp(options: FirebaseConfig.webOptions);
  } else if (defaultTargetPlatform == TargetPlatform.windows) {
// Pour Windows, tu peux aussi utiliser webOptions si nécessaire
    await Firebase.initializeApp(options: FirebaseConfig.webOptions);
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100], // gris clair partout
        canvasColor: Colors.grey[100], // fond du Drawer également gris clair
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/environments': (context) => EnvironmentsScreen(),
        '/environment': (context) => EnvironmentScreen(
          environmentId: ModalRoute.of(context)!.settings.arguments as String,
        ),
        //'/playlists': (context) => const PlaylistsScreen(),
        '/create-local': (context) => const LocalEnvironmentScreen(),
        '/open-local': (context) => const OpenLocalEnvironmentScreen(),
        '/ypm-auth': (context) => const YpmAuthScreen(),
      },
    );

  }
}

import 'package:flutter/material.dart';
import 'package:youtubeplaylistmanager/models/environment.dart';
import 'package:youtubeplaylistmanager/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnvironmentsScreen extends StatelessWidget {
  EnvironmentsScreen({super.key});

  final firestoreService = FirestoreService();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Environnements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 600,
          child: StreamBuilder<List<Environment>>(
            stream: firestoreService.getUserEnvironments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erreur : ${snapshot.error}'));
              }

              final environments = snapshot.data ?? [];

              return ListView.builder(
                itemCount: environments.length,
                itemBuilder: (context, index) {
                  final env = environments[index];
                  return ListTile(
                    leading: const Icon(Icons.folder, color: Colors.red),
                    title: Text(env.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Supprimer environnement'),
                            content: const Text('Confirmer la suppression de cet environnement ?'),
                            actions: [
                              TextButton(
                                child: const Text('Annuler'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                onPressed: () async {
                                  final envRef = FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(currentUser!.uid)
                                      .collection('environments')
                                      .doc(env.id);

                                  final playlists = await envRef.collection('playlists').get();
                                  for (final playlist in playlists.docs) {
                                    await playlist.reference.delete(); // supprime chaque playlist
                                  }

                                  await envRef.delete(); // puis supprime l'environnement
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/environment', arguments: env.id);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => firestoreService.createNewEnvironment('Nouvel environnement'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

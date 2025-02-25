import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youtubeplaylistmanager/models/youtube_playlist.dart';
import 'package:youtubeplaylistmanager/models/environment.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> createUserIfNotExists() async {
    final user = auth.currentUser;
    if (user == null) return;

    final userRef = firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      await userRef.set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await userRef.collection('environments').add({
        'name': 'Environnement par défaut',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<Environment>> getUserEnvironments() {
    final user = auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('environments')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Environment.fromFirestore(doc)).toList());
  }

  Future<void> createNewEnvironment(String envName) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('environments')
        .add({
      'name': envName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addPlaylistToEnvironment(String environmentId, YoutubePlaylist playlist) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('environments')
        .doc(environmentId)
        .collection('playlists')
        .doc(playlist.id)
        .set({
      'id': playlist.id,
      'title': playlist.title,
      'thumbnailUrl': playlist.thumbnailUrl,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }
}

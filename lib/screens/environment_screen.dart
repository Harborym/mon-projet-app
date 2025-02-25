import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:youtubeplaylistmanager/services/firestore_service.dart';
import 'package:youtubeplaylistmanager/services/youtube_service.dart';
import 'package:youtubeplaylistmanager/models/youtube_playlist.dart';
import 'package:youtubeplaylistmanager/models/youtube_video.dart';
import 'package:youtubeplaylistmanager/widgets/playlist_details_widget.dart';
import 'package:youtubeplaylistmanager/widgets/playlist_videos_popup.dart';

import '../widgets/modern_collapsible_sidebar.dart';
import '../widgets/youtube_search.dart';

class EnvironmentScreen extends StatefulWidget {
  final String environmentId;
  const EnvironmentScreen({super.key, required this.environmentId});

  @override
  State<EnvironmentScreen> createState() => _EnvironmentScreenState();
}

class _EnvironmentScreenState extends State<EnvironmentScreen> {
  final _firestoreService = FirestoreService();
  final _youtubeService = YoutubeService();
  List<YoutubePlaylist> playlists = [];
  YoutubePlaylist? selectedPlaylist;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  void _loadPlaylists() {
    _firestoreService.getUserEnvironments().listen((environments) async {
      final environment = environments.firstWhere((env) => env.id == widget.environmentId);
      final playlistDocs = await _firestoreService.firestore
          .collection('users')
          .doc(_firestoreService.auth.currentUser!.uid)
          .collection('environments')
          .doc(environment.id)
          .collection('playlists')
          .get();

      setState(() {
        playlists = playlistDocs.docs.map((doc) {
          final data = doc.data();
          return YoutubePlaylist(
            id: data['id'],
            title: data['title'],
            thumbnailUrl: data['thumbnailUrl'],
            description: '',
            channelTitle: '',
            privacyStatus: '',
            publishedAt: DateTime.now(),
            itemCount: 0,
          );
        }).toList();
      });
    });
  }

  void _addPlaylistDialog() {
    final controller = TextEditingController();
    bool isSearching = false;
    List<YoutubePlaylist> searchResults = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajouter une playlist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Lien ou recherche YouTube'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text('Rechercher sur YouTube'),
                onPressed: () async {
                  setState(() => isSearching = true);
                  searchResults = await _youtubeService.searchPlaylists(controller.text);
                  setState(() => isSearching = false);
                },
              ),
              if (isSearching) const CircularProgressIndicator(),
              if (searchResults.isNotEmpty)
                YoutubeSearchWidget(
                  playlists: searchResults,
                  onPlaylistSelected: (playlist) async {
                    await _firestoreService.addPlaylistToEnvironment(widget.environmentId, playlist);
                    _loadPlaylists();
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Ajouter via URL'),
              onPressed: () async {
                final playlistId = _extractPlaylistIdFromUrl(controller.text.trim());
                if (playlistId != null && playlistId.isNotEmpty) {
                  final playlist = await _youtubeService.getPlaylistDetails(playlistId);
                  await _firestoreService.addPlaylistToEnvironment(widget.environmentId, playlist);
                  _loadPlaylists();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('URL invalide ou ID introuvable')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }


// Fonction très claire qui extrait automatiquement l'ID de playlist depuis l'URL
  String? _extractPlaylistIdFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.queryParameters.containsKey('list')) {
      return uri.queryParameters['list'];
    }
    return null; // Retourne null si l'URL n'est pas valide ou ne contient pas "list"
  }

  void _showPlaylistVideos(YoutubePlaylist playlist) async {
    final videos = await _youtubeService.getPlaylistVideos(playlist.id);
    PlaylistVideosPopup.show(context, videos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Environnement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/environments', (route) => false),
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
      body: Row(
        children: [
          ModernCollapsibleSidebar(
            playlists: playlists,
            onSelectPlaylist: (playlist) {
              if (playlist != selectedPlaylist) {
                setState(() {
                  selectedPlaylist = playlist;
                });
              }
            },
            onAddPlaylist: _addPlaylistDialog,
            onNavigateEnvironments: () => Navigator.pushNamed(context, '/environments'),
            onViewVideos: (playlist) => _showPlaylistVideos(playlist),
            environmentId: widget.environmentId,
          ),
          Expanded(
            child: selectedPlaylist != null
                ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlaylistDetailsWidget(
                    playlist: selectedPlaylist!,
                    onShowVideos: () => _showPlaylistVideos(selectedPlaylist!),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gestion des filtres',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('Ici tu pourras prochainement gérer précisément les filtres avancés de tes vidéos.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<List<YoutubeVideo>>(
                    future: _youtubeService.getPlaylistVideos(selectedPlaylist!.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Erreur : ${snapshot.error}');
                      }
                      final videos = snapshot.data ?? [];
                      return Column(
                        children: videos
                            .map((video) => ListTile(
                          leading: Image.network(video.thumbnailUrl, width: 100),
                          title: Text(video.title),
                          subtitle: Text(video.channelTitle),
                        ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            )
                : const Center(child: Text('Sélectionnez une playlist depuis la sidebar')),
          ),
        ],
      ),
    );
  }
}

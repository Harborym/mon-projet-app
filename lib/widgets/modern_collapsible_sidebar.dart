import 'package:flutter/material.dart';
import 'package:youtubeplaylistmanager/models/youtube_playlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModernCollapsibleSidebar extends StatefulWidget {
  final List<YoutubePlaylist> playlists;
  // On accepte une valeur nullable pour notifier la suppression.
  final Function(YoutubePlaylist?) onSelectPlaylist;
  final VoidCallback onAddPlaylist;
  final VoidCallback onNavigateEnvironments;
  final Function(YoutubePlaylist) onViewVideos;
  final String environmentId;

  const ModernCollapsibleSidebar({
    super.key,
    required this.playlists,
    required this.onSelectPlaylist,
    required this.onAddPlaylist,
    required this.onNavigateEnvironments,
    required this.onViewVideos,
    required this.environmentId,
  });

  @override
  State<ModernCollapsibleSidebar> createState() =>
      _ModernCollapsibleSidebarState();
}

class _ModernCollapsibleSidebarState extends State<ModernCollapsibleSidebar> {
  bool isExpanded = false;

  Future<void> deletePlaylist(String playlistId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('environments')
        .doc(widget.environmentId)
        .collection('playlists')
        .doc(playlistId)
        .delete();

    // Mise à jour immédiate de la liste et notifier le parent pour vider la sélection.
    setState(() {
      widget.playlists.removeWhere((playlist) => playlist.id == playlistId);
    });
    widget.onSelectPlaylist(null);
  }

  @override
  Widget build(BuildContext context) {
    double sidebarWidth =
    isExpanded ? MediaQuery.of(context).size.width * 0.35 : 70;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: sidebarWidth,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bouton pour ouvrir/fermer la sidebar
          IconButton(
            icon:
            Icon(isExpanded ? Icons.arrow_back_ios : Icons.arrow_forward_ios),
            onPressed: () => setState(() => isExpanded = !isExpanded),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bouton "Playlists" avec texte
                InkWell(
                  onTap: widget.onAddPlaylist,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.add, color: Colors.red),
                        if (isExpanded) ...[
                          const SizedBox(width: 10),
                          const Flexible(
                            child: Text('Playlists',
                                style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Bouton "Environnements"
                InkWell(
                  onTap: widget.onNavigateEnvironments,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_open, color: Colors.blue),
                        if (isExpanded) ...[
                          const SizedBox(width: 10),
                          const Flexible(
                            child: Text('Environnements',
                                style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Divider(),
                // Liste des playlists
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = widget.playlists[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 5),
                        child: Row(
                          children: [
                            // L'image de la playlist : uniquement sur l'image on déclenche la sélection
                            GestureDetector(
                              onTap: () {
                                widget.onSelectPlaylist(playlist);
                              },
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: Image.network(
                                  playlist.thumbnailUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (isExpanded) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  playlist.title,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              // Encapsuler le menu dans un widget qui absorbe les taps pour éviter toute propagation.
                              GestureDetector(
                                onTap: () {}, // Absorbe le tap
                                child: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert,
                                      color: Colors.black54),
                                  onSelected: (value) async {
                                    if (value == 'show_videos') {
                                      widget.onViewVideos(playlist);
                                    } else if (value == 'delete_playlist') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title:
                                          const Text('Supprimer playlist'),
                                          content: const Text(
                                              'Confirmer la suppression de cette playlist ?'),
                                          actions: [
                                            TextButton(
                                              child: const Text('Annuler'),
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                            ),
                                            TextButton(
                                              child: const Text(
                                                'Supprimer',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await deletePlaylist(playlist.id);
                                      }
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem<String>(
                                      value: 'show_videos',
                                      child: Text('Voir les vidéos'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete_playlist',
                                      child: Text('Supprimer la playlist',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

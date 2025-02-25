import 'package:flutter/material.dart';
import 'package:youtubeplaylistmanager/models/youtube_playlist.dart';

class PlaylistDetailsWidget extends StatelessWidget {
  final YoutubePlaylist playlist;
  final VoidCallback onShowVideos;

  const PlaylistDetailsWidget({
    super.key,
    required this.playlist,
    required this.onShowVideos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Image.network(playlist.thumbnailUrl, width: double.infinity, height: 125, fit: BoxFit.cover),
            Positioned(
              top: 10,
              right: 10,
              child: PopupMenuButton(
                onSelected: (value) {
                  if (value == 'show_videos') onShowVideos();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'show_videos', child: Text('Afficher les vidéos')),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(playlist.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Chaîne : ${playlist.channelTitle}'),
              Text('Statut : ${playlist.privacyStatus}'),
              Text('Vidéos : ${playlist.itemCount}'),
            ],
          ),
        ),
      ],
    );
  }
}

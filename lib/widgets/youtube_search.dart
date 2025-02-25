import 'package:flutter/material.dart';
import 'package:youtubeplaylistmanager/models/youtube_playlist.dart';
import 'package:youtubeplaylistmanager/models/youtube_video.dart';
import 'package:youtubeplaylistmanager/services/youtube_service.dart';
import 'playlist_videos_popup.dart';

class YoutubeSearchWidget extends StatelessWidget {
  final List<YoutubePlaylist> playlists;
  final Function(YoutubePlaylist) onPlaylistSelected;

  const YoutubeSearchWidget({
    super.key,
    required this.playlists,
    required this.onPlaylistSelected,
  });

  @override
  Widget build(BuildContext context) {
    final youtubeService = YoutubeService();

    return SizedBox(
      height: 400,
      width: double.maxFinite,
      child: ListView.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return ListTile(
            leading: Image.network(playlist.thumbnailUrl, width: 80, fit: BoxFit.cover),
            title: Text(playlist.title),
            subtitle: Text(playlist.channelTitle),
            trailing: IconButton(
              icon: const Icon(Icons.preview),
              onPressed: () async {
                final videos = await youtubeService.getPlaylistVideos(playlist.id);
                PlaylistVideosPopup.show(context, videos);
              },
            ),
            onTap: () => onPlaylistSelected(playlist),
          );
        },
      ),
    );
  }
}

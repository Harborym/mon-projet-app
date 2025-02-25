import 'package:flutter/material.dart';
import 'package:youtubeplaylistmanager/models/youtube_video.dart';

class PlaylistVideosPopup {
  static void show(BuildContext context, List<YoutubeVideo> videos) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: videos.map((video) => ListTile(
          leading: Image.network(video.thumbnailUrl, width: 100),
          title: Text(video.title),
          subtitle: Text(video.channelTitle),
        )).toList(),
      ),
    );
  }
}

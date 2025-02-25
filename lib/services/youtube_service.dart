import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtubeplaylistmanager/models/youtube_playlist.dart';
import 'package:youtubeplaylistmanager/models/youtube_video.dart';

class YoutubeService {
  static const apiKey = 'AIzaSyBXKbwjDSRq7HzJquAOGMbCGBuUNql1rBI';
  static const baseUrl = 'https://www.googleapis.com/youtube/v3';

  Future<YoutubePlaylist> getPlaylistDetails(String playlistId) async {
    final url = Uri.parse(
      '$baseUrl/playlists?part=snippet,contentDetails,status&id=$playlistId&key=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['items'].isEmpty) {
        throw Exception('Playlist non trouvée.');
      }
      return YoutubePlaylist.fromJson(data['items'][0]);
    } else {
      throw Exception('Erreur API YouTube: ${response.statusCode}');
    }
  }

  Future<List<YoutubeVideo>> getPlaylistVideos(String playlistId) async {
    final url = Uri.parse(
      '$baseUrl/playlistItems?part=snippet&playlistId=$playlistId&maxResults=50&key=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['items'] as List)
          .map((item) => YoutubeVideo.fromJson(item))
          .toList();
    } else {
      throw Exception('Erreur API YouTube: ${response.statusCode}');
    }
  }

  // Recherche de playlists directement via YouTube
  Future<List<YoutubePlaylist>> searchPlaylists(String query) async {
    final url = Uri.parse(
      '$baseUrl/search?part=snippet&type=playlist&maxResults=20&q=${Uri.encodeQueryComponent(query)}&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['items'] as List).map((item) {
        return YoutubePlaylist(
          id: item['id']['playlistId'],
          title: item['snippet']['title'],
          description: item['snippet']['description'],
          thumbnailUrl: item['snippet']['thumbnails']['high']['url'],
          channelTitle: item['snippet']['channelTitle'],
          privacyStatus: 'public',
          publishedAt: DateTime.parse(item['snippet']['publishedAt']),
          itemCount: 0,
        );
      }).toList();
    } else {
      throw Exception('Erreur recherche YouTube: ${response.statusCode}');
    }
  }


}

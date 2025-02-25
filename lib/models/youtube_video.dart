class YoutubeVideo {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;
  final DateTime publishedAt;

  YoutubeVideo({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.publishedAt,
  });

  factory YoutubeVideo.fromJson(Map<String, dynamic> json) {
    return YoutubeVideo(
      id: json['snippet']['resourceId']['videoId'],
      title: json['snippet']['title'],
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'],
      channelTitle: json['snippet']['channelTitle'],
      publishedAt: DateTime.parse(json['snippet']['publishedAt']),
    );
  }
}

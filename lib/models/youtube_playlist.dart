class YoutubePlaylist {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final String privacyStatus;
  final DateTime publishedAt;
  final int itemCount;

  YoutubePlaylist({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.privacyStatus,
    required this.publishedAt,
    required this.itemCount,
  });

  factory YoutubePlaylist.fromJson(Map<String, dynamic> json) {
    return YoutubePlaylist(
      id: json['id'],
      title: json['snippet']['title'],
      description: json['snippet']['description'],
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'],
      channelTitle: json['snippet']['channelTitle'],
      privacyStatus: json['status']['privacyStatus'],
      publishedAt: DateTime.parse(json['snippet']['publishedAt']),
      itemCount: json['contentDetails']['itemCount'],
    );
  }
}

enum MediaType { audio, video }

class MediaItem {
  final int sl;
  final String link;
  final String file;
  final MediaType type;

  MediaItem({
    required this.sl,
    required this.link,
    required this.file,
    required this.type,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      sl: json['sl'] as int,
      link: json['link'] as String,
      file: json['file'] as String,
      type: json['type'] == 'audio' ? MediaType.audio : MediaType.video,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sl': sl,
      'link': link,
      'file': file,
      'type': type == MediaType.audio ? 'audio' : 'video',
    };
  }
}

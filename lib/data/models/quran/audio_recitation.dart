class AudioRecitation {
  final String reciterId;
  final String reciterName;
  final String language;
  final String audioUrl;
  final int? duration;
  final String format;
  final int? bitrate;
  final bool isDownloaded;
  final String? localPath;
  final DateTime? downloadedAt;

  const AudioRecitation({
    required this.reciterId,
    required this.reciterName,
    required this.language,
    required this.audioUrl,
    this.duration,
    this.format = 'mp3',
    this.bitrate,
    this.isDownloaded = false,
    this.localPath,
    this.downloadedAt,
  });

  factory AudioRecitation.fromJson(Map<String, dynamic> json) {
    return AudioRecitation(
      reciterId: json['reciterId'],
      reciterName: json['reciterName'],
      language: json['language'],
      audioUrl: json['audioUrl'],
      duration: json['duration'],
      format: json['format'] ?? 'mp3',
      bitrate: json['bitrate'],
      isDownloaded: json['isDownloaded'] ?? false,
      localPath: json['localPath'],
      downloadedAt: json['downloadedAt'] != null ? DateTime.parse(json['downloadedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reciterId': reciterId,
      'reciterName': reciterName,
      'language': language,
      'audioUrl': audioUrl,
      'duration': duration,
      'format': format,
      'bitrate': bitrate,
      'isDownloaded': isDownloaded,
      'localPath': localPath,
      'downloadedAt': downloadedAt?.toIso8601String(),
    };
  }
}

enum ReadingMode {
  reading,
  listening,
  memorizing,
  studying,
}
import 'package:json_annotation/json_annotation.dart';

part 'audio_recitation_model.g.dart';

@JsonSerializable()
class AudioRecitationModel {
  final String reciterId;
  final String reciterName;
  final String audioUrl;
  final int? duration;
  final String format;
  final bool isDownloaded;
  final String? localPath;
  final DateTime? downloadedAt;

  const AudioRecitationModel({
    required this.reciterId,
    required this.reciterName,
    required this.audioUrl,
    this.duration,
    this.format = 'mp3',
    this.isDownloaded = false,
    this.localPath,
    this.downloadedAt,
  });

  factory AudioRecitationModel.fromJson(Map<String, dynamic> json) => _$AudioRecitationModelFromJson(json);
  Map<String, dynamic> toJson() => _$AudioRecitationModelToJson(this);

  factory AudioRecitationModel.fromApiResponse(Map<String, dynamic> json) {
    return AudioRecitationModel(
      reciterId: json['edition']?['identifier'] ?? '',
      reciterName: json['edition']?['name'] ?? '',
      audioUrl: json['audio'] ?? '',
      duration: json['duration'],
      format: json['edition']?['format'] ?? 'mp3',
    );
  }

  AudioRecitationModel copyWith({
    String? reciterId,
    String? reciterName,
    String? audioUrl,
    int? duration,
    String? format,
    bool? isDownloaded,
    String? localPath,
    DateTime? downloadedAt,
  }) {
    return AudioRecitationModel(
      reciterId: reciterId ?? this.reciterId,
      reciterName: reciterName ?? this.reciterName,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      format: format ?? this.format,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }
}
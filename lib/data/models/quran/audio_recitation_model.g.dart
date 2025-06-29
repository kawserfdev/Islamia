// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_recitation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioRecitationModel _$AudioRecitationModelFromJson(
  Map<String, dynamic> json,
) => AudioRecitationModel(
  reciterId: json['reciterId'] as String,
  reciterName: json['reciterName'] as String,
  audioUrl: json['audioUrl'] as String,
  duration: (json['duration'] as num?)?.toInt(),
  format: json['format'] as String? ?? 'mp3',
  isDownloaded: json['isDownloaded'] as bool? ?? false,
  localPath: json['localPath'] as String?,
  downloadedAt:
      json['downloadedAt'] == null
          ? null
          : DateTime.parse(json['downloadedAt'] as String),
);

Map<String, dynamic> _$AudioRecitationModelToJson(
  AudioRecitationModel instance,
) => <String, dynamic>{
  'reciterId': instance.reciterId,
  'reciterName': instance.reciterName,
  'audioUrl': instance.audioUrl,
  'duration': instance.duration,
  'format': instance.format,
  'isDownloaded': instance.isDownloaded,
  'localPath': instance.localPath,
  'downloadedAt': instance.downloadedAt?.toIso8601String(),
};

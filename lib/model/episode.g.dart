// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Episode _$EpisodeFromJson(Map<String, dynamic> json) {
  return Episode(
    id: json['id'] as String,
    audio: json['audio'] as String,
    image: json['image'] as String,
    title: json['title'] as String,
    publishDateTime: _fromJson(json['pub_date_ms'] as int),
    length: json['length'] as int,
  );
}

Map<String, dynamic> _$EpisodeToJson(Episode instance) => <String, dynamic>{
      'id': instance.id,
      'audio': instance.audio,
      'image': instance.image,
      'title': instance.title,
      'pub_date_ms': instance.publishDateTime.toIso8601String(),
      'length': instance.length,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Podcast _$PodcastFromJson(Map<String, dynamic> json) {
  return Podcast(
    id: json['id'] as String,
    rss: Uri.parse(json['rss'] as String),
    image: Uri.parse(json['image'] as String),
    title: json['title'] as String,
    thumbnail: Uri.parse(json['thumbnail'] as String),
    lastPublishedDate: _fromJson(json['latest_pub_date_ms'] as int),
    episodes: (json['episodes'] as List)
        .map((e) => Episode.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$PodcastToJson(Podcast instance) => <String, dynamic>{
      'id': instance.id,
      'rss': instance.rss.toString(),
      'image': instance.image.toString(),
      'title': instance.title,
      'thumbnail': instance.thumbnail.toString(),
      'latest_pub_date_ms': instance.lastPublishedDate.toIso8601String(),
      'episodes': instance.episodes,
    };

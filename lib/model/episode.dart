import 'package:json_annotation/json_annotation.dart';

part 'episode.g.dart';

@JsonSerializable(nullable: false)
class Episode {
  final String id;
  final String audio;
  final String image;
  final String title;
  @JsonKey(name: 'pub_date_ms', fromJson: _fromJson)
  final DateTime publishDateTime;
  final int length;

  Episode({this.id, this.audio, this.image, this.title, this.publishDateTime, this.length});

  factory Episode.fromJson(Map<String, dynamic> json) => _$EpisodeFromJson(json);
}

DateTime _fromJson(int date) => DateTime.fromMillisecondsSinceEpoch(date);

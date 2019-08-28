import 'package:podcast/model/episode.dart';
import 'package:json_annotation/json_annotation.dart';

part 'podcast.g.dart';

@JsonSerializable(nullable: false)
class Podcast {
  final String id;
  final Uri rss;
  final Uri image;
  final String title;
  final Uri thumbnail;
  @JsonKey(name: 'latest_pub_date_ms', fromJson: _fromJson)
  final DateTime lastPublishedDate;
  final List<Episode> episodes;

  Podcast({this.id, this.rss, this.image, this.title, this.thumbnail, this.lastPublishedDate, List<Episode> episodes})
      : this.episodes = episodes ?? [];

  factory Podcast.fromJson(Map<String, dynamic> json) => _$PodcastFromJson(json);
}

DateTime _fromJson(int date) => DateTime.fromMillisecondsSinceEpoch(date);

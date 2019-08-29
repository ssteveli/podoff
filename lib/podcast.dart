import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podcast/db.dart';
import 'package:podcast/download_manager.dart';
import 'package:podcast/episode.dart';
import 'package:podcast/player_manager.dart';
import 'package:provider/provider.dart';
import 'listenapi.dart';
import 'models.dart';

class PodcastPage extends StatefulWidget {
  final String id;

  PodcastPage(this.id);

  createState() => _PodcastPageState(id);
}

class _PodcastPageState extends State<PodcastPage> {
  final String podcastId;
  final ListenAPI _api = ListenAPI();
  final Db _db = Db();

  _PodcastPageState(this.podcastId);

  final Map<String, Stream<double>> _downloads = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _api.getPodcast(podcastId),
      builder: (context, AsyncSnapshot<Podcast> snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data.title),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Image.network(snapshot.data.image.toString()),
                  Text(
                    snapshot.data.title,
                    style: Theme.of(context).textTheme.headline,
                  ),
                  Divider(),
                  ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) => Divider(),
                    itemCount: snapshot.data.episodes.length,
                    itemBuilder: (context, idx) {
                      Episode episode = snapshot.data.episodes[idx];
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(episode.title),
                            )
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(
                                  '${episode.publishDateTime.month} / ${episode.publishDateTime.day} / ${episode.publishDateTime.year}',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ],
                            ),
                            _determineControlWidget(episode),
                          ],
                        ),
                        onTap: () =>
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EpisodePage(episode))),
                      );
                    },
                  )
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _determineControlWidget(Episode episode) {
    return FutureBuilder(
      future: _db.exists(episode.id),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data) {
            return _playerWidget(episode);
          }
          if (_downloads.containsKey(episode.id)) {
            return _downloadingWidget(episode);
          } else {
            return _downloadWidget(episode);
          }
        }

        return Container();
      },
    );
  }

  Widget _downloadingWidget(Episode episode) {
    return StreamBuilder(
      stream: _downloads[episode.id],
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _playerWidget(episode);
        }

        if (snapshot.hasData) {
          return Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                value: snapshot.data,
              ));
        }

        return Icon(Icons.access_time);
      },
    );
  }

  Widget _downloadWidget(Episode episode) {
    return IconButton(
        icon: Icon(Icons.file_download),
        onPressed: () async {
          _downloads[episode.id] = Provider.of<DownloadManager>(context).download(episode.id, episode.audio);
          setState(() {});
        });
  }

  Widget _playerWidget(Episode episode) {
    return Row(
      children: <Widget>[
        Consumer<PlayerManager>(
          builder: (context, playerManager, _) {
            if (playerManager.currentId == episode.id) {
              switch (playerManager.state) {
                case AudioPlayerState.COMPLETED:
                case AudioPlayerState.PAUSED:
                case AudioPlayerState.STOPPED:
                  return IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () async {
                      File f = await Provider.of<DownloadManager>(context, listen: false).getDownloadedFile(episode.id);
                      Provider.of<PlayerManager>(context).play(episode.id, f.path);
                    },
                  );
                case AudioPlayerState.PLAYING:
                  return Row(children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: () => Provider.of<PlayerManager>(context).pause(),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          Text(_printDuration(playerManager.position)),
                          if (playerManager.duration?.inSeconds != 0)
                            Padding(
                              padding: EdgeInsets.only(left: 5.0, right: 10.0),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                value: playerManager.position.inMilliseconds / playerManager.duration.inMilliseconds,
                              ),
                            ),
                          Text(_printDuration(playerManager.duration)),
                        ],
                      ),
                    ),
                  ]);
              }
            }

            return IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () async {
                File f = await Provider.of<DownloadManager>(context, listen: false).getDownloadedFile(episode.id);
                Provider.of<PlayerManager>(context).play(episode.id, f.path);
              },
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {},
        )
      ],
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes);
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

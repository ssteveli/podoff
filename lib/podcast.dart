import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final String id;
  final ListenAPI api = ListenAPI();

  _PodcastPageState(this.id);

  final Map<String, Stream<double>> _downloads = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: api.getPodcast(id),
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
                        title: Text(episode.title),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (!_downloads.containsKey(episode.id))
                              IconButton(
                                  icon: Icon(Icons.file_download),
                                  onPressed: () async {
                                    _downloads[episode.id] =
                                        Provider.of<DownloadManager>(context).download(episode.id, episode.audio);
                                    setState(() {});
                                  }),
                            if (_downloads.containsKey(episode.id))
                              StreamBuilder(
                                stream: _downloads[episode.id],
                                builder: (context, AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    return _playerWidget(episode.id);
                                  }

                                  if (snapshot.hasData) {
                                    return Row(
                                      children: <Widget>[
                                        CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                          value: snapshot.data,
                                        )
                                      ],
                                    );
                                  }

                                  return Icon(Icons.access_time);
                                },
                              )
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

  Widget _playerWidget(String id) {
    return Consumer<PlayerManager>(
      builder: (context, playerManager, _) {
        if (playerManager.currentId == id) {
          switch (playerManager.state) {
            case AudioPlayerState.COMPLETED:
            case AudioPlayerState.PAUSED:
            case AudioPlayerState.STOPPED:
              return IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () async {
                  File f = await Provider.of<DownloadManager>(context, listen: false).getDownloadedFile(id);
                  Provider.of<PlayerManager>(context).play(id, f.path);
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
            File f = await Provider.of<DownloadManager>(context, listen: false).getDownloadedFile(id);
            Provider.of<PlayerManager>(context).play(id, f.path);
          },
        );
      },
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

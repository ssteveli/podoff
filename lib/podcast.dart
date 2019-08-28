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
              title: Text(
                snapshot.data.title,
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Image.network(snapshot.data.image.toString()),
                  Text(snapshot.data.title),
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
                                          value: snapshot.data,
                                        )
                                      ],
                                    );
                                  }

                                  return Icon(Icons.cloud_download);
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
              return IconButton(
                icon: Icon(Icons.pause),
                onPressed: () => Provider.of<PlayerManager>(context).pause(),
              );
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
}

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:podcast/download_manager.dart';
import 'package:podcast/model/episode.dart';
import 'package:podcast/player_manager.dart';
import 'package:provider/provider.dart';

class EpisodePage extends StatefulWidget {
  final Episode episode;

  EpisodePage(this.episode);

  @override
  _EpisodePageState createState() => _EpisodePageState(this.episode);
}

class _EpisodePageState extends State<EpisodePage> {
  final Episode episode;
  _EpisodePageState(this.episode);

  File _file;
  double _progress;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500), () async {
      DownloadManager dm = Provider.of<DownloadManager>(context, listen: false);
      File f = await dm.getDownloadedFile(episode.id);

      if (f != null) {
        setState(() => _file = f);
      } else {
        await for (var progress in Provider.of<DownloadManager>(context).download(episode.id, episode.audio)) {
          setState(() => _progress = progress);
        }

        f = await dm.getDownloadedFile(episode.id);
        print('exists: ${await f.exists()}');
        print('size: ${await f.length()}');
        setState(() => _file = f);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _downloading() {
    if (_progress == null) {
      return Text('Waiting to start');
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Text('Downloading'),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: CircularProgressIndicator(
              value: _progress,
            ),
          ),
        ],
      );
    }
  }

  Widget _episode() {
    return Column(children: [
      Consumer<PlayerManager>(
        builder: (context, playerManager, _) {
          if (playerManager.currentId == episode.id) {
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.replay_10),
                  onPressed: () async {
                    playerManager.jumpBack(Duration(seconds: 10));
                  },
                ),
                FloatingActionButton(
                  onPressed: () async {
                    switch (playerManager.state) {
                      case AudioPlayerState.PLAYING:
                        await playerManager.pause();
                        break;
                      case AudioPlayerState.PAUSED:
                        await playerManager.resume();
                        break;
                      default:
                        print('playing: ${_file.path}');
                        await playerManager.play(episode.id, _file.path);
                        break;
                    }

                    setState(() {});
                  },
                  tooltip: playerManager.state == AudioPlayerState.PLAYING ? 'Pause' : 'Play',
                  child: Icon(playerManager.state == AudioPlayerState.PLAYING ? Icons.pause : Icons.play_arrow),
                ),
                IconButton(
                  icon: Icon(Icons.forward_10),
                  onPressed: () async {
                    playerManager.jumpAhead(const Duration(seconds: 10));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.forward_30),
                  onPressed: () async {
                    playerManager.jumpAhead(const Duration(seconds: 30));
                  },
                ),
              ],
            );
          }

          return FloatingActionButton(
            onPressed: () async {
              print('playing: ${_file.path}');
              await playerManager.play(episode.id, _file.path);

              setState(() {});
            },
            tooltip: playerManager.state == AudioPlayerState.PLAYING ? 'Pause' : 'Play',
            child: Icon(playerManager.state == AudioPlayerState.PLAYING ? Icons.pause : Icons.play_arrow),
          );
        },
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.network(
              episode.image,
            ),
            Text(episode.title),
            _file == null ? _downloading() : _episode(),
          ],
        ),
      ),
    );
  }
}
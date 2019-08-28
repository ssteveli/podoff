import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:podcast/model/episode.dart';
import 'package:path_provider/path_provider.dart';

class PlayerPage extends StatefulWidget {
  final Episode episode;

  PlayerPage(this.episode);

  @override
  _PlayerPageState createState() => _PlayerPageState(this.episode);
}

class _PlayerPageState extends State<PlayerPage> {
  static AudioPlayer _player = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
  final Dio dio = new Dio();
  String downloadTaskId;

  final Episode episode;

  _PlayerPageState(this.episode);

  File _file;
  double _progress;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500), () async {
      Directory directory = await getTemporaryDirectory();
      File f = File('${directory.path}/${episode.id}');

      if (await f.exists()) {
        setState(() => _file = f);
      } else {
        var response = await dio.download(episode.audio, f.path, onReceiveProgress: (count, total) {
          print('downloading ${count / total}');
          if (mounted) setState(() => _progress = count / total);
        });
        print('download completed, status code: ${response.statusCode}');
        print('exists: ${await f.exists()}');
        print('size: ${await f.length()}');

        if (response.statusCode == 200) {
          setState(() => _file = f);
          _player.play(_file.path, isLocal: true);
        }
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
      StreamBuilder(
        stream: _player.onPlayerStateChanged,
        builder: (context, AsyncSnapshot<AudioPlayerState> snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data.toString());
          }

          return Text(_player.state.toString());
        },
      ),
      if (_file != null)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
              stream: _player.onAudioPositionChanged,
              builder: (context, AsyncSnapshot<Duration> snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data.inSeconds.toString());
                }

                return (Text('0'));
              },
            ),
            Text('/'),
            StreamBuilder(
              stream: _player.onDurationChanged,
              builder: (context, AsyncSnapshot<Duration> snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data.inSeconds.toString());
                }

                return (Text('0'));
              },
            )
          ],
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
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.replay_10),
                onPressed: () async {
                  await _player.seek(Duration(milliseconds: -10000 + (await _player.getCurrentPosition())));
                },
              ),
              FloatingActionButton(
                onPressed: () async {
                  switch (_player.state) {
                    case AudioPlayerState.PLAYING:
                      await _player.pause();
                      break;
                    case AudioPlayerState.PAUSED:
                      await _player.resume();
                      break;
                    default:
                      print('playing: ${_file.path}');
                      await _player.play(_file.path, isLocal: true);
                      break;
                  }

                  setState(() {});
                },
                tooltip: _player.state == AudioPlayerState.PLAYING ? 'Pause' : 'Play',
                child: Icon(_player.state == AudioPlayerState.PLAYING ? Icons.pause : Icons.play_arrow),
              ),
              IconButton(
                icon: Icon(Icons.forward_10),
                onPressed: () async {
                  await _player.seek(Duration(milliseconds: 10000 + (await _player.getCurrentPosition())));
                },
              ),
              IconButton(
                icon: Icon(Icons.forward_30),
                onPressed: () async {
                  await _player.seek(Duration(milliseconds: 30000 + (await _player.getCurrentPosition())));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

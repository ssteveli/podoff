import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:podcast/model/episode.dart';

class PlayerPage extends StatefulWidget {
  final Episode episode;

  PlayerPage(this.episode);

  @override
  _PlayerPageState createState() => _PlayerPageState(this.episode);
}

class _PlayerPageState extends State<PlayerPage> {
  static AudioPlayer _player = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
  static DefaultCacheManager _cache = DefaultCacheManager();

  final Episode episode;

  _PlayerPageState(this.episode);

  File _file;

  @override
  void initState() {
    super.initState();

    _cache.getSingleFile(episode.audio).then((file) => setState(() => _file = file));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              episode.image,
              headers: {'X-ListenAPI-Key': '8c5425ad6ed043838fbddab4ecc7c2e8'},
            ),
            Text(episode.title),
            if (_file == null) Text('Download ...'),
            if (_file != null)
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
              ),
            RaisedButton(
              child: Text('Clear Cache'),
              onPressed: () => _cache.emptyCache(),
            )
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

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:podcast/db.dart';

class PlayerManager with ChangeNotifier {
  static AudioPlayer _player = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
  Db _db;

  Duration _position;
  Duration _length;
  AudioPlayerState _state;
  String _currentId;

  Duration get position => _position ?? Duration.zero;
  Duration get duration => _length ?? Duration(milliseconds: 1);
  AudioPlayerState get state => _state;
  String get currentId => _currentId;

  PlayerManager() {
    _player.onAudioPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });

    _player.onDurationChanged.listen((duration) {
      _length = duration;
      notifyListeners();
    });

    _player.onPlayerStateChanged.listen((state) {
      _state = state;
      notifyListeners();
    });

    _db = Db(playerManager: this);
  }

  @override
  void dispose() {
    super.dispose();
    _db?.close();
  }

  Future<void> play(String id, String path) async {
    if (_player.state == AudioPlayerState.PLAYING && _currentId == id) return;
    if (_player.state == AudioPlayerState.PLAYING) await _player.stop();

    _currentId = id;
    _player.play(path, isLocal: true, position: Duration(milliseconds: await _db.currentPosition(id) ?? 0));

    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    notifyListeners();
  }

  Future<void> pause() async {
    await _player.pause();
    notifyListeners();
  }

  Future<void> resume() async {
    await _player.resume();
    notifyListeners();
  }

  Future<void> jumpAhead(Duration duration) async {
    await _player.seek(Duration(milliseconds: duration.inMilliseconds + _position.inMilliseconds));
  }

  Future<void> jumpBack(Duration duration) async {
    var pos = _position.inMilliseconds - duration.inMilliseconds;

    await _player.seek(pos <= 0 ? Duration.zero : Duration(milliseconds: pos));
  }
}

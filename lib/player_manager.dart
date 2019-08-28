import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

class PlayerManager with ChangeNotifier {
  static AudioPlayer _player = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

  Duration _position;
  Duration _length;
  AudioPlayerState _state;
  String _currentId;

  final Map<String, Duration> _positions = {};
  Duration get position => _position;
  Duration get duration => _length;
  AudioPlayerState get state => _state;
  String get currentId => _currentId;

  PlayerManager() {
    _player.onAudioPositionChanged.listen((position) {
      _positions[_currentId] = position;
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
  }

  Future<void> play(String id, String path) async {
    if (_player.state == AudioPlayerState.PLAYING && _currentId == id) return;

    await _player.stop();
    _currentId = id;
    _player.play(path, isLocal: true, position: _positions[id] ?? Duration.zero);

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

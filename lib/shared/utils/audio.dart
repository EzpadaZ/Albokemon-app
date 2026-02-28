import 'package:just_audio/just_audio.dart';

class Audio {
  Audio._();
  static final Audio instance = Audio._();

  final _player = AudioPlayer();
  bool _ready = false;

  Future<void> playLoop(String assetPath, {double volume = 0.7}) async {
    if (!_ready) {
      await _player.setLoopMode(LoopMode.one);
      _ready = true;
    }
    await _player.setAsset(assetPath);
    _player.setVolume(volume);
    await _player.play();
  }

  Future<void> stop() => _player.stop();
  Future<void> dispose() => _player.dispose();
}
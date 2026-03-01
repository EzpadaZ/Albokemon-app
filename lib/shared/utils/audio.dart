import 'package:albokemon_app/shared/utils/game_manager.dart';
import 'package:just_audio/just_audio.dart';

class Audio {
  Audio._();
  static final Audio instance = Audio._();

  final _player = AudioPlayer();
  bool _ready = false;

  Future<void> playLoop(String assetPath) async {
    if (!_ready) {
      await _player.setLoopMode(LoopMode.one);
      _ready = true;
    }
    await _player.setAsset(assetPath);
    _player.setVolume(GameManager.instance.music_volume);
    await _player.play();
  }

  updateVolume(){
    _player.setVolume(GameManager.instance.music_volume);
  }

  Future<void> stop() => _player.stop();
  Future<void> dispose() => _player.dispose();
}
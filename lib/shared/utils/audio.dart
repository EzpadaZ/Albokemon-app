import 'package:just_audio/just_audio.dart';
import 'package:albokemon_app/shared/utils/game_manager.dart';

class Audio {
  Audio._();
  static final Audio instance = Audio._();

  final AudioPlayer _bgm = AudioPlayer();
  bool _bgmReady = false;

  Future<void> playLoop(String assetPath) async {
    if (!_bgmReady) {
      await _bgm.setLoopMode(LoopMode.one);
      _bgmReady = true;
    }
    await _bgm.setAsset(assetPath);
    _bgm.setVolume(GameManager.instance.music_volume);
    await _bgm.play();
  }

  Future<void> playSfx(String assetPath) async {
    final p = AudioPlayer();
    try {
      await p.setAsset(assetPath);
      p.setVolume(5 * GameManager.instance.music_volume);
      await p.play();
    } finally {
      await p.dispose();
    }
  }

  void updateVolume() {
    _bgm.setVolume(GameManager.instance.music_volume);
  }

  isPlaying() {
    return _bgm.playing;
  }

  Future<void> stop() => _bgm.stop();
  Future<void> dispose() => _bgm.dispose();
}
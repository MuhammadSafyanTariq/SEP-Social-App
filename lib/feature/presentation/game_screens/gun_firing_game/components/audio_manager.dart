import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sep/utils/appUtils.dart';

class AudioManager extends Component {
  bool musicEnabled = true;
  bool soundsEnabled = true;

  final List<String> _sounds = [
    'click',
    'collect',
    'explode1',
    'explode2',
    'fire',
    'hit',
    'laser',
    'start',
  ];

  final Map<String, AudioPlayer> _soundPlayers = {};

  @override
  FutureOr<void> onLoad() async {
    FlameAudio.bgm.initialize();

    for (final sound in _sounds) {
      final player = AudioPlayer(playerId: sound);
      await player.setSourceAsset('audio/$sound.wav');
      await player.setReleaseMode(ReleaseMode.stop); // don't loop
      _soundPlayers[sound] = player;
      AppUtils.log('Preloaded $sound');
    }

    return super.onLoad();
  }

  void playMusic() {
    if (musicEnabled) {
      FlameAudio.bgm.play('music.wav');
    }
  }

  void playSound(String sound) {
    if (soundsEnabled && _soundPlayers.containsKey(sound)) {
      AppUtils.log("Playing sound: $sound");
      _soundPlayers[sound]!.resume(); // .resume plays from start if not paused
    }
  }

  void toggleMusic() {
    musicEnabled = !musicEnabled;
    if (musicEnabled) {
      playMusic();
    } else {
      FlameAudio.bgm.stop();
    }
  }

  void toggleSounds() {
    soundsEnabled = !soundsEnabled;
  }

  void stopAllSounds() {
    FlameAudio.bgm.stop();
    for (var player in _soundPlayers.values) {
      player.stop();
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    for (var player in _soundPlayers.values) {
      player.dispose();
    }
  }
}

import 'package:just_audio/just_audio.dart';

class Audio {
  static AudioPlayer audioPlayer = AudioPlayer();

  static Future<void> playMove() async {
    var duration = await audioPlayer.setAsset(
      'lib/feature/presentation/game_screens/ludo_flutter-master/assets/sounds/move.wav',
    );
    audioPlayer.play();
    return Future.delayed(duration ?? Duration.zero);
  }

  static Future<void> playKill() async {
    var duration = await audioPlayer.setAsset(
      'lib/feature/presentation/game_screens/ludo_flutter-master/assets/sounds/laugh.mp3',
    );
    audioPlayer.play();
    return Future.delayed(duration ?? Duration.zero);
  }

  static Future<void> rollDice() async {
    var duration = await audioPlayer.setAsset(
      'lib/feature/presentation/game_screens/ludo_flutter-master/assets/sounds/roll_the_dice.mp3',
    );
    audioPlayer.play();
    return Future.delayed(duration ?? Duration.zero);
  }
}

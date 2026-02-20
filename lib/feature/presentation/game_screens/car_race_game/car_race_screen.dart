import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:sep/feature/presentation/game_screens/car_race_game/car_race.dart';
import 'package:sep/feature/presentation/game_screens/car_race_game/widgets/widgets.dart';

/// Car Race game screen (token flow handled before navigation).
class CarRaceScreen extends StatefulWidget {
  const CarRaceScreen({Key? key}) : super(key: key);

  @override
  State<CarRaceScreen> createState() => _CarRaceScreenState();
}

class _CarRaceScreenState extends State<CarRaceScreen> {
  late final CarRace _game;

  @override
  void initState() {
    super.initState();
    _game = CarRace();
  }

  @override
  void dispose() {
    FlameAudio.bgm.stop();
    FlameAudio.updatePrefix('assets/audio/');
    // Restore default so Flappy/Fruit Ninja (using short paths) load correctly
    Flame.images.prefix = 'assets/images/';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _game.pauseEngine();
          FlameAudio.bgm.stop();
          Flame.images.prefix = 'assets/images/';
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Car Race'),
        ),
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                constraints: const BoxConstraints(
                  maxWidth: 800,
                  minWidth: 550,
                ),
                child: GameWidget(
                  game: _game,
                  overlayBuilderMap: <String, Widget Function(BuildContext, Game)>{
                    'gameOverlay': (context, game) => GameOverlay(game),
                    'mainMenuOverlay': (context, game) => MainMenuOverlay(game),
                    'gameOverOverlay': (context, game) => GameOverOverlay(game),
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

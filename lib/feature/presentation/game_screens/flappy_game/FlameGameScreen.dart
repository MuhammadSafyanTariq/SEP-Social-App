
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:sep/feature/presentation/game_screens/flappy_game/screens/game_over_screen.dart';
import 'package:sep/feature/presentation/game_screens/flappy_game/screens/main_menu_screen.dart';

import 'game/flappy_bird_game.dart';

class FlameGameScreen extends StatelessWidget {
  final FlappyBirdGame game = FlappyBirdGame();

  FlameGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: game,
      initialActiveOverlays: const [MainMenuScreen.id],
      overlayBuilderMap: {
        MainMenuScreen.id: (context, _) => MainMenuScreen(game: game),
        GameOverScreen.id: (context, _) => GameOverScreen(game: game),
      },
    );
  }
}

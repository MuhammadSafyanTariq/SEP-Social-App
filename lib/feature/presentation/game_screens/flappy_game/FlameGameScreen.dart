
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
    return WillPopScope(
      onWillPop: () async {
        game.pauseEngine();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GameWidget(
              game: game,
              initialActiveOverlays: const [MainMenuScreen.id],
              overlayBuilderMap: {
                MainMenuScreen.id: (context, _) => MainMenuScreen(game: game),
                GameOverScreen.id: (context, _) => GameOverScreen(game: game),
              },
            ),
            // Floating exit button (only show when not in main menu)
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    game.pauseEngine();
                    Navigator.of(context).pop();
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

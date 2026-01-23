import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'my_game.dart';
import 'overlays/title_overlay.dart';
import 'overlays/game_over_overlay.dart';

class GunFiringScreen extends StatelessWidget {
  GunFiringScreen({super.key});

  final MyGame _game = MyGame();

  @override
  Widget build(BuildContext context) {
    _game.onQuit = () {
      // Ensure audio stops when exiting
      _game.audioManager.stopAllSounds();
      Navigator.of(context).pop();
    };

    return WillPopScope(
      onWillPop: () async {
        _game.audioManager.stopAllSounds();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GameWidget<MyGame>(
              game: _game,
              initialActiveOverlays: const [TitleOverlay.id],
              overlayBuilderMap: {
                TitleOverlay.id:  (ctx, game) => TitleOverlay(game: _game),
                GameOverOverlay.id: (ctx, game) => GameOverOverlay(game: _game),
              },
            ),
            // Floating exit button
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    _game.audioManager.stopAllSounds();
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


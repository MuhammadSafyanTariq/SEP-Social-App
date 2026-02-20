import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'my_game.dart';
import 'overlays/title_overlay.dart';
import 'overlays/game_over_overlay.dart';

class GunFiringScreen extends StatefulWidget {
  GunFiringScreen({super.key});

  @override
  State<GunFiringScreen> createState() => _GunFiringScreenState();
}

class _GunFiringScreenState extends State<GunFiringScreen> {
  final MyGame _game = MyGame();

  @override
  void dispose() {
    _game.audioManager.stopAllSounds();
    // Restore default so other games (Flappy, etc.) load assets correctly
    Flame.images.prefix = 'assets/images/';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _game.onQuit = () {
      _game.audioManager.stopAllSounds();
      Navigator.of(context).pop();
    };

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _game.audioManager.stopAllSounds();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GameWidget<MyGame>(
              game: _game,
              initialActiveOverlays: const [TitleOverlay.id],
              overlayBuilderMap: {
                TitleOverlay.id: (ctx, game) => TitleOverlay(game: _game),
                GameOverOverlay.id: (ctx, game) => GameOverOverlay(game: _game),
              },
            ),
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


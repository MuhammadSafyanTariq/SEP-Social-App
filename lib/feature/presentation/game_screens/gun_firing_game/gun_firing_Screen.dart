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
      Navigator.of(context).pop();
    };

    return GameWidget<MyGame>(
      game: _game,
      initialActiveOverlays: const [TitleOverlay.id],
      overlayBuilderMap: {
        TitleOverlay.id:  (ctx, game) => TitleOverlay(game: _game),
        GameOverOverlay.id: (ctx, game) => GameOverOverlay(game: _game),
      },
    );
  }
}


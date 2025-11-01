import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:flame/components.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';

class HomeView {
  final FruitGame game;
  late Rect titleRect;
  late Sprite titleSprite;

  HomeView(this.game) {
    resize();
    titleSprite = Sprite(game.images.fromCache('title.png'));
  }

  void render(Canvas c) {
    titleSprite.render(
      c,
      size: Vector2(titleRect.width, titleRect.height),
      position: Vector2(titleRect.left, titleRect.top),
    );
  }

  void resize() {
    titleRect = Rect.fromLTWH(
      game.tileSize,
      (game.screenSize.height / 2) - (game.tileSize * 4),
      game.tileSize * 7,
      game.tileSize * 3.5,
    );
  }
}

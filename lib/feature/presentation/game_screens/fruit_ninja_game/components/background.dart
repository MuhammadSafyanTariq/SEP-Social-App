import 'dart:ui';
import 'package:flame/components.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';

class BackgroundGame {
  final FruitGame game;
  late Sprite bgSprite;
  late Rect bgRect;

  BackgroundGame(this.game) {
    bgSprite = Sprite(game.images.fromCache('backyard.png'));
    resize();
  }

  void render(Canvas c) {
    bgSprite.render(
      c,
      size: Vector2(bgRect.width, bgRect.height),
      position: Vector2(bgRect.left, bgRect.top),
    );
  }

  void resize() {
    bgRect = Rect.fromLTWH(
      0,
      game.screenSize.height - (game.tileSize * 23),
      game.tileSize * 9,
      game.tileSize * 23,
    );
  }

  void update(double t) {}
}

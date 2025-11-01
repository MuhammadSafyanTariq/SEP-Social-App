import 'dart:ui';
import 'package:flame/components.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';

class LostView {
  final FruitGame game;
  late Rect rect;
  late Sprite sprite;

  LostView(this.game) {
    resize();
    sprite = Sprite(game.images.fromCache('lose-splash.png'));
  }

  void render(Canvas c) {
    sprite.render(
      c,
      size: Vector2(rect.width, rect.height),
      position: Vector2(rect.left, rect.top),
    );
  }

  void resize() {
    rect = Rect.fromLTWH(
      game.tileSize,
      (game.screenSize.height / 2) - (game.tileSize * 3),
      game.tileSize * 7,
      game.tileSize * 3,
    );
  }
}

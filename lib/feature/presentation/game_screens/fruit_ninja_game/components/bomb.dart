import 'dart:ui';
import 'package:flame/components.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/throw_fruit.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';

class Bomb extends ThrowFruit {
  @override
  double get speed => game.tileSize * 5;

  Bomb(FruitGame game, double x, double y) : super(game) {
    resize(x: x, y: y);
    isBomb = true;
    flyingSprite = [
      Sprite(game.images.fromCache('bomb.png')),
      Sprite(game.images.fromCache('bomb.png')),
    ];
    deadSprite = Sprite(game.images.fromCache('bomb.png'));
    splash = Sprite(game.images.fromCache('banana-splash.png'));
  }

  void resize({double? x, double? y}) {
    x ??= fruitRect.left;
    y ??= fruitRect.top;
    fruitRect = Rect.fromLTWH(x, y, game.tileSize * 1.5, game.tileSize * 1.5);
    super.resize();
  }
}

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/throw_fruit.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';

class Pineapple extends ThrowFruit {
  @override
  double get speed => game.tileSize * 5;

  Pineapple(FruitGame game, double x, double y) : super(game) {
    resize(x: x, y: y);
    flyingSprite = [
      Sprite(game.images.fromCache('pineapple.png')),
      Sprite(game.images.fromCache('pineapple.png')),
    ];
    deadSprite = Sprite(game.images.fromCache('pineapple-cut-1.png'));
    deadSprite2 = Sprite(game.images.fromCache('pineapple-cut-2.png'));
    splash = Sprite(game.images.fromCache('banana-splash.png'));
  }

  void resize({double? x, double? y}) {
    x ??= fruitRect.left;
    y ??= fruitRect.top;
    fruitRect = Rect.fromLTWH(x, y, game.tileSize * 1, game.tileSize * 1);
    super.resize();
  }
}

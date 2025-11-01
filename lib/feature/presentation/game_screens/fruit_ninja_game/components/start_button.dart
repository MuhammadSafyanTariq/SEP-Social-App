import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:flame/components.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/bgm.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/view.dart';

class StartButton {
  final FruitGame game;
  late Rect rect;
  late Sprite sprite;

  StartButton(this.game) {
    resize();
    sprite = Sprite(game.images.fromCache('start-button.png'));
  }

  void render(Canvas c) {
    sprite.render(
      c,
      size: Vector2(rect.width, rect.height),
      position: Vector2(rect.left, rect.top),
    );
  }

  void update(double t) {}

  void resize() {
    rect = Rect.fromLTWH(
      game.tileSize * 1.5,
      (game.screenSize.height * .75) - (game.tileSize * 1.5),
      game.tileSize * 6,
      game.tileSize * 3,
    );
  }

  void onTapDown() {
    game.score = 0;
    game.lives = 3;
    game.activeView = View.playing;
    game.spawner.start();
    BGM.play(BGMType.playing);
  }
}

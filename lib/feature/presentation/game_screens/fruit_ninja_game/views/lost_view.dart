import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show TextStyle, FontWeight, Color;
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';
import 'package:sep/utils/game_messages.dart';

class LostView {
  final FruitGame game;
  late Rect rect;
  late Sprite sprite;
  late Rect messageRect;
  final TextPaint messagePaint = TextPaint(
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFFFFD700),
    ),
  );

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

    // Render motivating message
    final message = GameMessages.getFruitNinjaMessage();
    messagePaint.render(
      c,
      message,
      Vector2(
        game.screenSize.width / 2 - (message.length * 6),
        rect.bottom + game.tileSize * 0.5,
      ),
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

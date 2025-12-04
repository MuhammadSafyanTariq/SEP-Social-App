import 'dart:ui';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';
import 'package:flutter/material.dart' as material;

class CloseButton {
  final FruitGame game;
  late Rect rect;

  CloseButton(this.game) {
    resize();
  }

  void render(Canvas c) {
    // Draw a circular background
    final paint = Paint()
      ..color = material.Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final center = Offset(
      rect.left + rect.width / 2,
      rect.top + rect.height / 2,
    );

    c.drawCircle(center, rect.width / 2, paint);

    // Draw the X icon
    final iconPaint = Paint()
      ..color = material.Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final iconSize = rect.width * 0.5;
    final iconOffset = iconSize / 2;

    // Draw X
    c.drawLine(
      Offset(center.dx - iconOffset, center.dy - iconOffset),
      Offset(center.dx + iconOffset, center.dy + iconOffset),
      iconPaint,
    );
    c.drawLine(
      Offset(center.dx + iconOffset, center.dy - iconOffset),
      Offset(center.dx - iconOffset, center.dy + iconOffset),
      iconPaint,
    );
  }

  void resize() {
    // Position at top-right corner
    rect = Rect.fromLTWH(
      game.screenSize.width - game.tileSize * 1.5,
      game.tileSize * .25,
      game.tileSize,
      game.tileSize,
    );
  }

  void onTapDown() {
    game.onQuit?.call();
  }
}

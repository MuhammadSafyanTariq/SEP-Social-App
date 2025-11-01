import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';

class LivesDisplay {
  final FruitGame game;
  Offset position = Offset.zero;

  LivesDisplay(this.game) {
    resize();
  }

  void render(Canvas c) {
    // Draw hearts for lives
    final heartSize = game.tileSize * 0.6;
    final spacing = game.tileSize * 0.1;

    for (int i = 0; i < 3; i++) {
      final x = position.dx + (i * (heartSize + spacing));
      final y = position.dy;

      final paint = Paint()
        ..color = i < game.lives ? Color(0xFFFF0000) : Color(0xFF666666)
        ..style = PaintingStyle.fill;

      // Draw heart shape
      final path = Path();
      path.moveTo(x + heartSize / 2, y + heartSize * 0.3);

      // Left curve
      path.cubicTo(
        x + heartSize / 2,
        y + heartSize * 0.15,
        x + heartSize * 0.2,
        y,
        x + heartSize * 0.2,
        y + heartSize * 0.25,
      );
      path.cubicTo(
        x + heartSize * 0.2,
        y + heartSize * 0.4,
        x + heartSize * 0.2,
        y + heartSize * 0.5,
        x + heartSize / 2,
        y + heartSize * 0.85,
      );

      // Right curve
      path.cubicTo(
        x + heartSize * 0.8,
        y + heartSize * 0.5,
        x + heartSize * 0.8,
        y + heartSize * 0.4,
        x + heartSize * 0.8,
        y + heartSize * 0.25,
      );
      path.cubicTo(
        x + heartSize * 0.8,
        y,
        x + heartSize / 2,
        y + heartSize * 0.15,
        x + heartSize / 2,
        y + heartSize * 0.3,
      );

      c.drawPath(path, paint);

      // Add border
      final borderPaint = Paint()
        ..color = Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      c.drawPath(path, borderPaint);
    }
  }

  void resize() {
    position = Offset(game.tileSize * 0.25, game.tileSize * 1.5);
  }
}

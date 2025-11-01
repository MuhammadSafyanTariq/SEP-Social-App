import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';

class ScoreDisplay {
  final FruitGame game;
  late TextPainter painter;
  Offset position = Offset.zero;

  ScoreDisplay(this.game) {
    painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    position = Offset.zero;
  }

  void render(Canvas c) {
    painter.paint(c, position);
  }

  void update(double t) {
    if ((painter.text?.toPlainText() ?? '') != game.score.toString()) {
      resize();
    }
  }

  void resize() {
    painter.text = TextSpan(
      text: game.score.toString(),
      style: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: game.tileSize * 2.5,
        fontWeight: FontWeight.bold,
        shadows: <Shadow>[
          Shadow(
            blurRadius: game.tileSize * 0.8,
            color: Color(0xFF000000),
            offset: Offset(4, 4),
          ),
          Shadow(
            blurRadius: game.tileSize * 0.4,
            color: Color(0xFFFF6B00),
            offset: Offset(0, 0),
          ),
        ],
      ),
    );
    painter.layout();
    position = Offset(
      (game.screenSize.width / 2) - (painter.width / 2),
      (game.screenSize.height * .15) - (painter.height / 2),
    );
  }
}

import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';

class HighscoreDisplay {
  final FruitGame game;
  late TextPainter painter;
  Offset position = Offset.zero;

  HighscoreDisplay(this.game) {
    painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    position = Offset.zero;

    updateHighscore();
  }

  void updateHighscore() {
    resize();
  }

  void resize() {
    int highscore = game.storage.getInt('highscore') ?? 0;

    Shadow shadow = Shadow(
      blurRadius: game.tileSize * 0.1,
      color: Color(0xff000000),
      offset: Offset(2, 2),
    );

    painter.text = TextSpan(
      text: 'Best: $highscore',
      style: TextStyle(
        color: Color(0xffFFD700),
        fontSize: game.tileSize * .7,
        fontWeight: FontWeight.bold,
        shadows: <Shadow>[shadow, shadow],
      ),
    );

    painter.layout();
    position = Offset(
      game.screenSize.width - (game.tileSize * .25) - painter.width,
      game.tileSize * .25,
    );
  }

  void render(Canvas c) {
    painter.paint(c, position);
  }
}

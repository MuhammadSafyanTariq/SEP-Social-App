import 'dart:io'; // For platform check
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sep/feature/presentation/Home/homeScreen.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/widget.dart';

import '../game/assets.dart';
import '../game/flappy_bird_game.dart';

class GameOverScreen extends StatelessWidget {
  final FlappyBirdGame game;

  static const String id = 'gameOver';

  const GameOverScreen({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black38,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Score: ${game.bird.score}',
            style: const TextStyle(
              fontSize: 60,
              color: Colors.white,
              fontFamily: 'Game',
            ),
          ),
          20.height,
          Image.asset(Assets.gameOver),
          20.height,
          ElevatedButton(
            onPressed: onRestart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text(
              'Restart',
              style: TextStyle(fontSize: 20),
            ),
          ),
          10.height,
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Exit Game',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    ),
  );

  void onRestart() {
    game.bird.reset();
    game.overlays.remove(GameOverScreen.id);
    game.resumeEngine();
  }
}

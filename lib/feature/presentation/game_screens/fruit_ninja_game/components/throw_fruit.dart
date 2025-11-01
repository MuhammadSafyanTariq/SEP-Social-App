import 'dart:ui';
import 'package:flame/components.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/bgm.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/view.dart';

class ThrowFruit {
  final FruitGame game;
  List<Sprite> flyingSprite = [];
  late Sprite deadSprite;
  late Sprite deadSprite2;
  late Sprite splash;
  double flyingSpriteIndex = 0;
  late Rect fruitRect;
  Rect? deadZone;
  bool isDead = false;
  bool isOffScreen = false;
  late Offset targetLocation;

  bool isBomb = false;
  bool missedAndCounted =
      false; // Track if this fruit already caused a life loss

  double get speed => game.tileSize * 10;

  double rotate = 0;

  bool destroy = false;

  ThrowFruit(this.game) {
    targetLocation = Offset(
      game.rnd.nextDouble() * (game.screenSize.width - (game.tileSize * 1.35)),
      game.screenSize.height - (game.screenSize.height / 0.8),
    );
  }

  void setTargetLocation() {
    targetLocation = Offset(
      game.rnd.nextDouble() * (game.screenSize.width - (game.tileSize * 1.35)),
      game.screenSize.height,
    );
    destroy = true;
  }

  void render(Canvas c) {
    if (isDead) {
      deadZone ??= fruitRect;
      if (!isBomb) {
        try {
          splash.render(
            c,
            size: Vector2(deadZone!.width, deadZone!.height),
            position: Vector2(deadZone!.left, deadZone!.top),
          );

          c.save();
          c.translate(fruitRect.center.dx, fruitRect.center.dy);
          c.rotate(5 * 3.14159 / 180);
          c.translate(-fruitRect.width * 0.75, -fruitRect.height * 0.75);
          deadSprite.render(
            c,
            size: Vector2(fruitRect.width * 1.5, fruitRect.height * 1.5),
          );
          c.restore();

          c.save();
          c.translate(fruitRect.center.dx, fruitRect.center.dy);
          c.rotate(-5 * 3.14159 / 180);
          c.translate(-fruitRect.width * 0.75, -fruitRect.height * 0.75);
          deadSprite2.render(
            c,
            size: Vector2(fruitRect.width * 1.5, fruitRect.height * 1.5),
          );
          c.restore();
        } catch (e) {
          // Sprites not loaded yet
        }
      }
    } else {
      if (flyingSprite.isNotEmpty) {
        final inflatedRect = fruitRect.inflate(fruitRect.width / 4);
        flyingSprite[flyingSpriteIndex.toInt()].render(
          c,
          size: Vector2(inflatedRect.width, inflatedRect.height),
          position: Vector2(inflatedRect.left, inflatedRect.top),
        );
      }
    }
  }

  void update(double t) {
    if (isDead) {
      rotate += 2 * t;
      fruitRect = fruitRect.translate(0, game.tileSize * 12 * t);
      if (fruitRect.top > game.screenSize.height) {
        isOffScreen = true;
      }
    } else {
      flyingSpriteIndex += 30 * t;
      while (flyingSpriteIndex >= 2) {
        flyingSpriteIndex -= 2;
      }

      double stepDistance = speed * t;
      Offset toTarget = targetLocation - Offset(fruitRect.left, fruitRect.top);
      if (stepDistance < toTarget.distance) {
        Offset stepToTarget = Offset.fromDirection(
          toTarget.direction,
          stepDistance,
        );
        fruitRect = fruitRect.shift(stepToTarget);
      } else {
        fruitRect = fruitRect.shift(toTarget);

        if (destroy) {
          if (game.activeView == View.playing && !isBomb && !missedAndCounted) {
            // Fruit reached bottom without being sliced - lose a life
            missedAndCounted =
                true; // Mark as counted to prevent duplicate life loss
            game.lives -= 1;

            if (game.soundButton.isEnabled) {
              print('Playing miss sound');
              BGM.playSFX('audio/haha2.ogg');
            }

            if (game.lives <= 0) {
              BGM.play(BGMType.home);
              game.activeView = View.lost;
            }
          }
          // Immediately mark as off-screen so it gets removed
          isOffScreen = true;
        } else {
          setTargetLocation();
        }
      }
    }
  }

  void resize() {}

  void onTapDown() {
    if (!isDead) {
      isDead = true;

      if (game.activeView == View.playing) {
        if (isBomb) {
          // Hit a bomb - lose all lives instantly
          if (game.soundButton.isEnabled) {
            print('Playing bomb sound');
            BGM.playSFX('audio/bomb_explode.wav');
          }
          game.lives = 0;
          BGM.play(BGMType.home);
          game.activeView = View.lost;
        } else {
          // Successfully sliced a fruit
          game.score += 1;

          if (game.soundButton.isEnabled) {
            print('Playing swipe sound');
            BGM.playSFX('audio/swipe.wav');
          }

          if (game.score > (game.storage.getInt('highscore') ?? 0)) {
            game.storage.setInt('highscore', game.score);
            game.highscoreDisplay.updateHighscore();
          }
        }
      }
    }
  }
}

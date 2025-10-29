import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bgm.dart';

class FruitNinjaGame extends FlameGame with TapDetector {
  final SharedPreferences storage;
  late Random random;
  late Timer fruitSpawnTimer;
  int score = 0;
  int lives = 3;
  bool gameStarted = false;
  bool gameOver = false;

  TextComponent? scoreText;
  TextComponent? livesText;
  TextComponent? gameOverText;
  TextComponent? startText;
  TextComponent? highScoreText;
  PositionComponent? startDialog;
  PositionComponent? gameOverDialog;

  FruitNinjaGame(this.storage);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    random = Random();

    // Initialize BGM and preload audio
    await BGM.preload();

    // Preload sound effects
    await FlameAudio.audioCache.load('swipe.wav');
    await FlameAudio.audioCache.load('bomb_explode.wav');

    // Add background
    final background = SpriteComponent()
      ..sprite = await loadSprite('backyard.png')
      ..size = size;
    add(background);

    // Initialize UI components with improved styling
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 40),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 3,
              color: Colors.black.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
    add(scoreText!);

    livesText = TextComponent(
      text: '❤️❤️❤️',
      position: Vector2(200, 40), // Will be updated in onGameResize
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.red[300]!,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 3,
              color: Colors.black.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
    add(livesText!);

    final currentHighScore = storage.getInt('highScore') ?? 0;

    // Create start dialog with game-style design
    startDialog = _createGameDialog(
      Vector2(350, 220),
      Colors.orange.withOpacity(0.9),
    );

    startText = TextComponent(
      text:
          '🥷 FRUIT NINJA 🥷\n\n🏆 High Score: $currentHighScore\n\n    TAP TO START!',
      position: Vector2(200, 300), // Will be updated in onGameResize
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 6,
              color: Colors.orange.withOpacity(0.8),
            ),
            Shadow(
              offset: Offset(0, 0),
              blurRadius: 10,
              color: Colors.orange.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );

    // Add dialog first, then text on top
    add(startDialog!);
    add(startText!);

    highScoreText = TextComponent(
      text: '🏆 High Score: $currentHighScore',
      position: Vector2(200, 100), // Will be updated in onGameResize
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.yellow[300]!,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 3,
              color: Colors.black.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
    add(highScoreText!);

    // Create game over dialog with game-style design
    gameOverDialog = _createGameDialog(
      Vector2(360, 240),
      Colors.red.withOpacity(0.9),
    );

    gameOverText = TextComponent(
      text: '� GAME OVER! �\n\n🏆 Final Score: $score\n\n⚔️ TAP TO RESTART ⚔️',
      position: Vector2(200, 300), // Will be updated in onGameResize
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 6,
              color: Colors.red.withOpacity(0.8),
            ),
            Shadow(
              offset: Offset(0, 0),
              blurRadius: 10,
              color: Colors.red.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );

    // Spawn timer - starts slower and gets faster
    fruitSpawnTimer = Timer(1.5, onTick: spawnFruit, repeat: true);

    // Play background music
    print('Game initialized, starting BGM...');
    await BGM.play(BGMType.home);
  }

  void startGame() {
    gameStarted = true;
    gameOver = false;
    score = 0;
    lives = 3;

    // Remove start dialog and text
    startDialog?.removeFromParent();
    startText?.removeFromParent();

    // Remove game over dialog and text if present
    if (gameOverDialog?.parent != null) {
      gameOverDialog?.removeFromParent();
    }
    if (gameOverText?.parent != null) {
      gameOverText?.removeFromParent();
    }

    fruitSpawnTimer.start();
    BGM.play(BGMType.playing);
    updateUI();
  }

  void endGame() {
    gameOver = true;
    gameStarted = false;
    fruitSpawnTimer.stop();

    // Check for new high score
    final currentHighScore = storage.getInt('highScore') ?? 0;
    bool isNewHighScore = score > currentHighScore;

    if (isNewHighScore) {
      storage.setInt('highScore', score);
      gameOverText?.text =
          '🎉 NEW HIGH SCORE! 🎉\n\n💥 GAME OVER! 💥\nScore: $score\n\nTap to Restart';
    } else {
      gameOverText?.text =
          '💥 GAME OVER! 💥\nScore: $score\nHigh Score: $currentHighScore\n\n    Tap to Restart';
    }

    // Add dialog background first, then text on top
    if (gameOverDialog != null) {
      add(gameOverDialog!);
    }
    if (gameOverText != null) {
      add(gameOverText!);
    }

    // Update high score display
    highScoreText?.text =
        '🏆 High Score: ${isNewHighScore ? score : currentHighScore}';

    BGM.play(BGMType.home);
  }

  void spawnFruit() {
    if (!gameStarted || gameOver) return;

    final fruitType = random.nextInt(
      5,
    ); // Added one more type for better bomb distribution
    final x = random.nextDouble() * (size.x - 120) + 60; // Better margins
    final y = size.y + 50;

    FruitComponent fruit;
    switch (fruitType) {
      case 0:
        fruit = FruitComponent('melancia.png', false, Vector2(x, y));
        break;
      case 1:
        fruit = FruitComponent('banana.png', false, Vector2(x, y));
        break;
      case 2:
        fruit = FruitComponent('pineapple.png', false, Vector2(x, y));
        break;
      case 3:
        // Add another fruit for variety
        fruit = FruitComponent('melancia.png', false, Vector2(x, y));
        break;
      case 4:
      default:
        fruit = FruitComponent('bomb.png', true, Vector2(x, y));
        break;
    }

    // Add some horizontal velocity for more interesting movement
    final horizontalVelocity = (random.nextDouble() - 0.5) * 100;
    fruit.velocity.x = horizontalVelocity;

    add(fruit);
  }

  void updateUI() {
    scoreText?.text = '🏆 $score';

    // Update lives with appropriate emoji - just hearts, no text
    String livesEmoji = '';
    for (int i = 0; i < lives; i++) {
      livesEmoji += '❤️';
    }
    for (int i = lives; i < 3; i++) {
      livesEmoji += '🖤';
    }
    livesText?.text = livesEmoji;
  }

  void onFruitTapped(FruitComponent fruit) {
    if (fruit.isBomb) {
      lives--;
      // Update UI first to show correct lives count
      updateUI();
      // Play bomb sound
      print('Playing bomb sound...');
      _playSound('bomb_explode.wav');
      if (lives <= 0) {
        endGame();
      }
    } else {
      score += 10;
      // Play slice sound
      print('Playing slice sound...');
      _playSound('swipe.wav');

      // Create sliced fruit effect
      _createSlicedFruitEffect(fruit);
      updateUI();
    }

    fruit.removeFromParent();
  }

  void _createSlicedFruitEffect(FruitComponent fruit) {
    // Create particles or simple effect
    final effectDuration = 0.8;

    // Create multiple small pieces for better effect
    for (int i = 0; i < 4; i++) {
      final piece = SpriteComponent()
        ..sprite = fruit.sprite
        ..size = Vector2(fruit.size.x / 3, fruit.size.y / 3)
        ..position =
            fruit.position +
            Vector2(
              (Random().nextDouble() - 0.5) * 40,
              (Random().nextDouble() - 0.5) * 40,
            )
        ..anchor = Anchor.center;

      add(piece);

      // Animate pieces falling with physics
      final velocity = Vector2(
        (Random().nextDouble() - 0.5) * 200,
        -Random().nextDouble() * 100 - 50,
      );

      _animatePiece(piece, velocity, effectDuration);
    }
  }

  void _animatePiece(SpriteComponent piece, Vector2 velocity, double duration) {
    final gravity = Vector2(0, 300); // Gravity effect
    final startTime = DateTime.now().millisecondsSinceEpoch;

    void updatePiece() {
      final elapsed =
          (DateTime.now().millisecondsSinceEpoch - startTime) / 1000.0;
      if (elapsed >= duration) {
        piece.removeFromParent();
        return;
      }

      // Apply physics
      piece.position += velocity * 0.016; // Assuming 60 FPS
      velocity += gravity * 0.016;

      // Fade out
      piece.paint.colorFilter = ColorFilter.mode(
        Colors.white.withOpacity(1.0 - (elapsed / duration)),
        BlendMode.modulate,
      );

      // Schedule next update
      Future.delayed(const Duration(milliseconds: 16), updatePiece);
    }

    updatePiece();
  }

  void _playSound(String soundPath) {
    try {
      print('Playing sound: $soundPath');
      FlameAudio.play(soundPath, volume: 0.6);
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  PositionComponent _createGameDialog(Vector2 size, Color primaryColor) {
    final dialog = PositionComponent(size: size, anchor: Anchor.center);

    // Main background with gradient effect
    final mainBg = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.black.withOpacity(0.85)
        ..style = PaintingStyle.fill,
    );
    dialog.add(mainBg);

    // Border frame
    final border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    dialog.add(border);

    // Inner border for depth
    final innerBorder = RectangleComponent(
      size: Vector2(size.x - 8, size.y - 8),
      position: Vector2(4, 4),
      paint: Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    dialog.add(innerBorder);

    // Top accent bar
    final topAccent = RectangleComponent(
      size: Vector2(size.x - 20, 6),
      position: Vector2(10, 10),
      paint: Paint()
        ..color = primaryColor.withOpacity(0.8)
        ..style = PaintingStyle.fill,
    );
    dialog.add(topAccent);

    // Bottom accent bar
    final bottomAccent = RectangleComponent(
      size: Vector2(size.x - 20, 6),
      position: Vector2(10, size.y - 16),
      paint: Paint()
        ..color = primaryColor.withOpacity(0.8)
        ..style = PaintingStyle.fill,
    );
    dialog.add(bottomAccent);

    // Corner decorations
    _addCornerDecorations(dialog, size, primaryColor);

    return dialog;
  }

  void _addCornerDecorations(
    PositionComponent dialog,
    Vector2 size,
    Color color,
  ) {
    final cornerSize = 12.0;

    // Top-left corner
    final topLeft = RectangleComponent(
      size: Vector2(cornerSize, cornerSize),
      position: Vector2(8, 8),
      paint: Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    dialog.add(topLeft);

    // Top-right corner
    final topRight = RectangleComponent(
      size: Vector2(cornerSize, cornerSize),
      position: Vector2(size.x - cornerSize - 8, 8),
      paint: Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    dialog.add(topRight);

    // Bottom-left corner
    final bottomLeft = RectangleComponent(
      size: Vector2(cornerSize, cornerSize),
      position: Vector2(8, size.y - cornerSize - 8),
      paint: Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    dialog.add(bottomLeft);

    // Bottom-right corner
    final bottomRight = RectangleComponent(
      size: Vector2(cornerSize, cornerSize),
      position: Vector2(size.x - cornerSize - 8, size.y - cornerSize - 8),
      paint: Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    dialog.add(bottomRight);
  }

  @override
  void update(double dt) {
    super.update(dt);
    fruitSpawnTimer.update(dt);

    // Make game progressively harder
    _updateDifficulty();
  }

  void _updateDifficulty() {
    if (!gameStarted || gameOver) return;

    // Decrease spawn time based on score (minimum 0.5 seconds)
    final newSpawnTime = (1.5 - (score / 500)).clamp(0.5, 1.5);
    if (fruitSpawnTimer.limit != newSpawnTime) {
      fruitSpawnTimer.limit = newSpawnTime;
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);

    // Update UI element positions - keep lives safely on screen
    livesText?.position = Vector2(canvasSize.x - 80, 40);

    // Center dialog positions
    final centerX = canvasSize.x / 2;
    final centerY = canvasSize.y / 2;

    startDialog?.position = Vector2(centerX, centerY);
    startText?.position = Vector2(centerX, centerY);
    gameOverDialog?.position = Vector2(centerX, centerY);
    gameOverText?.position = Vector2(centerX, centerY);
    highScoreText?.position = Vector2(centerX, 80);
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (!gameStarted && !gameOver) {
      startGame();
      return;
    }

    if (gameOver) {
      startGame();
      return;
    }
  }
}

class FruitComponent extends SpriteComponent
    with HasGameRef<FruitNinjaGame>, TapCallbacks {
  final bool isBomb;
  final Vector2 velocity = Vector2(0, -200);
  final String imagePath;
  bool isSliced = false;

  FruitComponent(this.imagePath, this.isBomb, Vector2 startPosition) {
    position = startPosition;
    size = Vector2(80, 80);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite(imagePath);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    // Remove if off screen
    if (position.y < -100) {
      if (!isBomb && gameRef.gameStarted && !isSliced) {
        gameRef.lives--;
        // Update UI first to show correct lives count
        gameRef.updateUI();
        if (gameRef.lives <= 0) {
          gameRef.endGame();
        }
      }
      removeFromParent();
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (gameRef.gameStarted && !gameRef.gameOver && !isSliced) {
      isSliced = true;
      gameRef.onFruitTapped(this);
      return true;
    }
    return false;
  }
}

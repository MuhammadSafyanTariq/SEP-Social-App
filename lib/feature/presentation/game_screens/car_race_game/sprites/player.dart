import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:sep/feature/presentation/game_screens/car_race_game/car_race.dart';

enum PlayerState {
  left,
  right,
  center,
}

class Player extends SpriteGroupComponent<PlayerState>
    with HasGameRef<CarRace>, KeyboardHandler, CollisionCallbacks {
  Player({
    required this.character,
    this.moveLeftRightSpeed = 700,
  }) : super(
          size: Vector2(79, 109),
          anchor: Anchor.center,
          priority: 1,
        );
  double moveLeftRightSpeed;
  Character character;

  int _hAxisInput = 0;
  final int movingLeftInput = -1;
  final int movingRightInput = 1;
  Vector2 _velocity = Vector2.zero();

  static const String _assetPath = 'assets/car_race/images/game';

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    // Use a slightly smaller hitbox than the full sprite
    await add(
      CircleHitbox.relative(
        0.6, // 60% of the smallest side
        parentSize: size,
      ),
    );
    await _loadCharacterSprites();
    current = PlayerState.center;
  }

  @override
  void update(double dt) {
    if (gameRef.gameManager.isIntro || gameRef.gameManager.isGameOver) return;

    _velocity.x = _hAxisInput * moveLeftRightSpeed;

    final double marioHorizontalCenter = size.x / 2;

    if (position.x < marioHorizontalCenter) {
      position.x = gameRef.size.x - (marioHorizontalCenter);
    }
    if (position.x > gameRef.size.x - (marioHorizontalCenter)) {
      position.x = marioHorizontalCenter;
    }

    position += _velocity * dt;

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    gameRef.onLose();
    return;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hAxisInput = 0;

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      moveLeft();
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      moveRight();
    }

    return true;
  }

  void moveLeft() {
    _hAxisInput = 0;

    current = PlayerState.left;

    _hAxisInput += movingLeftInput;
  }

  void moveRight() {
    _hAxisInput = 0;

    current = PlayerState.right;

    _hAxisInput += movingRightInput;
  }

  void resetDirection() {
    _hAxisInput = 0;
  }

  void reset() {
    _velocity = Vector2.zero();
    current = PlayerState.center;
  }

  void resetPosition() {
    position = Vector2(
      (gameRef.size.x - size.x) / 2,
      (gameRef.size.y - size.y) / 2,
    );
  }

  Future<void> _loadCharacterSprites() async {
    final path = '$_assetPath/${character.name}.png';
    final left = await gameRef.loadSprite(path);
    final right = await gameRef.loadSprite(path);
    final center = await gameRef.loadSprite(path);

    sprites = <PlayerState, Sprite>{
      PlayerState.left: left,
      PlayerState.right: right,
      PlayerState.center: center,
    };
  }
}

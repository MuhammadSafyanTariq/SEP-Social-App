import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:sep/feature/presentation/game_screens/car_race_game/car_race.dart';

abstract class Competitor<T> extends SpriteGroupComponent<T>
    with HasGameRef<CarRace>, CollisionCallbacks {
  // Slightly smaller hitbox than the full enemy sprite
  late final RectangleHitbox hitbox;

  double direction = 1;
  final Vector2 _velocity = Vector2.zero();
  double speed = 150;

  static const String _assetPath = 'assets/car_race/images/game';

  Competitor({
    super.position,
  }) : super(
          size: Vector2.all(80),
          priority: 2,
        );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    hitbox = RectangleHitbox.relative(
      Vector2(0.7, 0.8), // 70% width, 80% height
      parentSize: size,
    );
    await add(hitbox);

    final points = getRandomPostionOfEnemy();

    position = Vector2(points.xPoint, points.yPoint);
  }

  void _move(double dt) {
    _velocity.y = direction * speed;

    position += _velocity * dt;
  }

  @override
  void update(double dt) {
    _move(dt);
    super.update(dt);
  }

  ({double xPoint, double yPoint}) getRandomPostionOfEnemy() {
    final random = Random();
    final randomXPoint =
        50 + random.nextInt((gameRef.size.x.toInt() - 100) - 50);

    final randomYPoint = 50 + random.nextInt(60 - 50);

    return (
      xPoint: randomXPoint.toDouble(),
      yPoint: randomYPoint.toDouble(),
    );
  }
}

enum EnemyPlatformState { only }

class EnemyPlatform extends Competitor<EnemyPlatformState> {
  EnemyPlatform({super.position});

  final List<String> enemy = [
    'enemy_1',
    'enemy_2',
    'enemy_3',
    'enemy_4',
    'enemy_5'
  ];

  @override
  Future<void>? onLoad() async {
    int enemyIndex = Random().nextInt(enemy.length);

    String enemySprite = enemy[enemyIndex];

    sprites = <EnemyPlatformState, Sprite>{
      EnemyPlatformState.only:
          await gameRef.loadSprite('${Competitor._assetPath}/$enemySprite.png'),
    };

    current = EnemyPlatformState.only;

    return super.onLoad();
  }
}

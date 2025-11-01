import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/throw_fruit.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';

class FlySpawner {
  final FruitGame game;
  final int maxSpawnInterval = 3000;
  final int minSpawnInterval = 250;
  final int intervalChange = 3;
  final int maxFruitsOnScreen = 7;
  late int currentInterval;
  late int nextSpawn;

  FlySpawner(this.game) {
    start();
    game.spawnFruit();
  }

  void start() {
    cutAll();
    currentInterval = maxSpawnInterval;
    nextSpawn = DateTime.now().millisecondsSinceEpoch + currentInterval;
  }

  void cutAll() {
    for (var fruit in game.fruits) {
      fruit.isDead = true;
    }
  }

  void update(double t) {
    int nowTimestamp = DateTime.now().millisecondsSinceEpoch;

    int fruitsSpawned = 0;
    for (var fruit in game.fruits) {
      if (!fruit.isDead) fruitsSpawned += 1;
    }

    if (nowTimestamp >= nextSpawn && fruitsSpawned < maxFruitsOnScreen) {
      game.spawnFruit();
      if (currentInterval > minSpawnInterval) {
        currentInterval -= intervalChange;
        currentInterval -= (currentInterval * .02).toInt();
      }
      nextSpawn = nowTimestamp + currentInterval;
    }
  }
}

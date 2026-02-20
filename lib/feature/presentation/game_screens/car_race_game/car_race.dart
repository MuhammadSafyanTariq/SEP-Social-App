// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:sep/feature/presentation/game_screens/car_race_game/background.dart';
import 'package:sep/feature/presentation/game_screens/car_race_game/managers/game_manager.dart';
import 'package:sep/feature/presentation/game_screens/car_race_game/managers/object_manager.dart';
import 'package:sep/feature/presentation/game_screens/car_race_game/sprites/player.dart';

enum Character {
  bmw,
  farari,
  lambo,
  tarzen,
  tata,
  tesla,
}

class CarRace extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  CarRace({
    super.children,
  });

  final BackGround _backGround = BackGround();
  final GameManager gameManager = GameManager();
  ObjectManager objectManager = ObjectManager();
  int screenBufferSpace = 300;

  late Player player;

  /// When set, Start button in main menu calls this instead of [startGame] (e.g. for token/dialog flow).
  Future<void> Function()? onStartRequest;

  late AudioPool pool;

  /// Full path; Car Race sets FlameAudio prefix to '' so this resolves correctly.
  static const String _audioPath = 'assets/car_race/audio/audi_sound.mp3';

  @override
  FutureOr<void> onLoad() async {
    // Flame defaults: images prefix "assets/images/", audio prefix "assets/audio/".
    // Use full paths for car_race assets (they live under assets/car_race/).
    images.prefix = '';
    FlameAudio.updatePrefix('');
    await add(_backGround);
    await add(gameManager);
    overlays.add('gameOverlay');
    pool = await FlameAudio.createPool(
      _audioPath,
      minPlayers: 3,
      maxPlayers: 4,
    );
  }

  void startBgmMusic() {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play(_audioPath, volume: 1);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameManager.isGameOver) {
      return;
    }
    if (gameManager.isIntro) {
      overlays.add('mainMenuOverlay');
      return;
    }
    if (gameManager.isPlaying) {
      final vf = camera.viewfinder;
      final worldBounds = Rectangle.fromLTRB(
        0,
        vf.position.y - screenBufferSpace,
        size.x,
        vf.position.y + _backGround.size.y,
      );
      camera.setBounds(worldBounds);
    }
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 241, 247, 249);
  }

  void setCharacter() {
    player = Player(
      character: gameManager.character,
      moveLeftRightSpeed: 600,
    );
    add(player);
  }

  Future<void> initializeGameStart() async {
    setCharacter();
    await player.loaded;

    gameManager.reset();

    if (children.contains(objectManager)) objectManager.removeFromParent();

    player.reset();
    camera.setBounds(Rectangle.fromLTRB(
      0,
      -_backGround.size.y,
      size.x,
      _backGround.size.y + screenBufferSpace,
    ));
    camera.follow(player);

    player.resetPosition();

    objectManager = ObjectManager();

    add(objectManager);
    startBgmMusic();
  }

  void onLose() {
    gameManager.state = GameState.gameOver;
    player.removeFromParent();
    FlameAudio.bgm.stop();
    overlays.add('gameOverOverlay');
  }

  void togglePauseState() {
    if (paused) {
      resumeEngine();
    } else {
      pauseEngine();
    }
  }

  void resetGame() {
    startGame(); // fire-and-forget; startGame is async
    overlays.remove('gameOverOverlay');
  }

  Future<void> startGame() async {
    await initializeGameStart();
    gameManager.state = GameState.playing;
    overlays.remove('mainMenuOverlay');
  }
}

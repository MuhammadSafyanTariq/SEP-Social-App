import 'dart:math';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/gestures.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/bgm.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/banana.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/background.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/bomb.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/throw_fruit.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/highscore_display.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/watermelon.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/pineapple.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/music_button.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/score_display.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/sound_button.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/start_button.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/components/lives_display.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/controllers/spawner.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/view.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/views/home_view.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/views/lost_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FruitGame extends Game {
  final SharedPreferences storage;
  Size screenSize = Size.zero;
  double tileSize = 0;
  Random rnd = Random();

  late BackgroundGame background;
  List<ThrowFruit> fruits = [];
  late StartButton startButton;
  late MusicButton musicButton;
  late SoundButton soundButton;
  late ScoreDisplay scoreDisplay;
  late HighscoreDisplay highscoreDisplay;
  late LivesDisplay livesDisplay;

  late FlySpawner spawner;

  View activeView = View.home;
  late HomeView homeView;
  late LostView lostView;

  int score = 0;
  int lives = 3;
  bool _initialized = false;

  // Callback for handling game start (with token logic)
  Function(FruitGame)? onStartGameCallback;

  FruitGame(this.storage);

  // Method called when start button is pressed
  void onStartButtonPressed() {
    if (onStartGameCallback != null) {
      onStartGameCallback!(this);
    } else {
      // Fallback if no callback is set
      startGamePlay();
    }
  }

  // Actually start the gameplay
  void startGamePlay() {
    score = 0;
    lives = 3;
    activeView = View.playing;
    spawner.start();
    BGM.play(BGMType.playing);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Preload all game images
    await images.loadAll([
      'backyard.png',
      'lose-splash.png',
      'title.png',
      'melancia.png',
      'melancia-cut-1.png',
      'melancia-cut-2.png',
      'melon_splash.png',
      'banana.png',
      'banana-cut-1.png',
      'banana-cut-2.png',
      'banana-splash.png',
      'pineapple.png',
      'pineapple-cut-1.png',
      'pineapple-cut-2.png',
      'bomb.png',
      'start-button.png',
      'icon-music-enabled.png',
      'icon-music-disabled.png',
      'icon-sound-enabled.png',
      'icon-sound-disabled.png',
    ]);

    await initialize();
  }

  Future<void> initialize() async {
    rnd = Random();
    fruits = [];
    score = 0;
    lives = 3;

    background = BackgroundGame(this);
    startButton = StartButton(this);
    musicButton = MusicButton(this);
    soundButton = SoundButton(this);
    scoreDisplay = ScoreDisplay(this);
    highscoreDisplay = HighscoreDisplay(this);
    livesDisplay = LivesDisplay(this);

    spawner = FlySpawner(this);
    homeView = HomeView(this);
    lostView = LostView(this);

    _initialized = true;

    // Resize all components now that they're initialized
    if (screenSize.width > 0 && screenSize.height > 0) {
      resize(screenSize);
    }

    BGM.play(BGMType.home);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (size.x > 0 && size.y > 0) {
      screenSize = Size(size.x, size.y);
      tileSize = screenSize.width / 9;

      // Only resize components if already initialized
      if (_initialized) {
        resize(Size(size.x, size.y));
      }
    }
  }

  void spawnFruit() {
    double x = rnd.nextDouble() * (screenSize.width - (tileSize * 2.025));
    double y = screenSize.height - (tileSize * 2.025);

    switch (rnd.nextInt(4)) {
      case 0:
        fruits.add(Watermelon(this, x, y));
        break;
      case 1:
        fruits.add(Bomb(this, x, y));
        break;
      case 2:
        fruits.add(Banana(this, x, y));
        break;
      case 3:
        fruits.add(Pineapple(this, x, y));
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_initialized) return;

    background.render(canvas);

    highscoreDisplay.render(canvas);
    if (activeView == View.playing || activeView == View.lost) {
      scoreDisplay.render(canvas);
      livesDisplay.render(canvas);
    }

    for (var fly in fruits) {
      fly.render(canvas);
    }

    if (activeView == View.home) homeView.render(canvas);
    if (activeView == View.lost) lostView.render(canvas);
    if (activeView == View.home || activeView == View.lost) {
      startButton.render(canvas);
    }
    musicButton.render(canvas);
    soundButton.render(canvas);
  }

  @override
  void update(double t) {
    if (!_initialized) return;

    spawner.update(t);
    for (var fly in fruits) {
      fly.update(t);
    }
    fruits.removeWhere((ThrowFruit fly) => fly.isOffScreen);
    if (activeView == View.playing) scoreDisplay.update(t);
  }

  void resize(Size size) {
    if (size.width == 0 || size.height == 0) return;

    screenSize = size;
    tileSize = screenSize.width / 9;

    if (!_initialized) return;

    background.resize();
    highscoreDisplay.resize();
    scoreDisplay.resize();
    livesDisplay.resize();

    for (var fly in fruits) {
      fly.resize();
    }

    homeView.resize();
    lostView.resize();
    startButton.resize();
    musicButton.resize();
    soundButton.resize();
  }

  void onTapDown(TapDownDetails d) {
    bool isHandled = false;

    // dialog boxes
    if (!isHandled) {
      if (activeView == View.help || activeView == View.credits) {
        activeView = View.home;
        isHandled = true;
      }
    }

    // music button
    if (!isHandled && musicButton.rect.contains(d.globalPosition)) {
      musicButton.onTapDown();
      isHandled = true;
    }

    // sound button
    if (!isHandled && soundButton.rect.contains(d.globalPosition)) {
      soundButton.onTapDown();
      isHandled = true;
    }

    // start button
    if (!isHandled && startButton.rect.contains(d.globalPosition)) {
      if (activeView == View.home || activeView == View.lost) {
        startButton.onTapDown();
        isHandled = true;
      }
    }

    // fruits
    if (!isHandled) {
      for (var fruit in fruits) {
        if (fruit.fruitRect.contains(d.globalPosition)) {
          fruit.onTapDown();
          isHandled = true;
          break;
        }
      }
    }
  }
}

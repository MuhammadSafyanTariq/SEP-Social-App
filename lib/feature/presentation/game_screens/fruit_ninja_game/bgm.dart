import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

class BGM {
  static AudioPlayer? homePlayer;
  static AudioPlayer? playingPlayer;
  static AudioPlayer? sfxPlayer; // Add dedicated SFX player
  static BGMType? current;
  static bool isPaused = false;
  static bool isInitialized = false;

  static Future<void> preload() async {
    print('BGM: Starting preload...');
    homePlayer = AudioPlayer();
    playingPlayer = AudioPlayer();
    sfxPlayer = AudioPlayer(); // Initialize SFX player

    await homePlayer?.setReleaseMode(ReleaseMode.loop);
    await playingPlayer?.setReleaseMode(ReleaseMode.loop);

    isInitialized = true;
    print('BGM: Preload complete');
  }

  static Future<void> playSFX(String path) async {
    if (!isInitialized) {
      print('BGM not initialized');
      return;
    }
    try {
      // Create a new player instance for each sound effect to allow overlapping sounds
      final player = AudioPlayer();
      await player.play(AssetSource(path), volume: 0.8);
      // Dispose after playing
      player.onPlayerComplete.listen((event) {
        player.dispose();
      });
    } catch (e) {
      print('Error playing SFX $path: $e');
    }
  }

  static Future<void> _update() async {
    if (!isInitialized) return;
    if (current == null) return;

    if (isPaused) {
      if (current == BGMType.home) await homePlayer?.pause();
      if (current == BGMType.playing) await playingPlayer?.pause();
    } else {
      if (current == BGMType.home) await homePlayer?.resume();
      if (current == BGMType.playing) await playingPlayer?.resume();
    }
  }

  static Future<void> play(BGMType what) async {
    if (!isInitialized) {
      print('BGM not initialized');
      return;
    }

    if (current != what) {
      try {
        if (what == BGMType.home) {
          current = BGMType.home;
          await playingPlayer?.stop();
          await homePlayer?.play(AssetSource('audio/home.mp3'), volume: 0.25);
        }
        if (what == BGMType.playing) {
          current = BGMType.playing;
          await homePlayer?.stop();
          await playingPlayer?.play(
            AssetSource('audio/playing.mp3'),
            volume: 0.25,
          );
        }
      } catch (e) {
        print('Error playing BGM: $e');
      }
    }
    _update();
  }

  static void pause() {
    isPaused = true;
    _update();
  }

  static void resume() {
    isPaused = false;
    _update();
  }

  static void stop() {
    isPaused = false;
    homePlayer?.stop();
    playingPlayer?.stop();
    sfxPlayer?.stop();
    current = null;
  }

  static void dispose() {
    homePlayer?.dispose();
    playingPlayer?.dispose();
    sfxPlayer?.dispose();
    homePlayer = null;
    playingPlayer = null;
    sfxPlayer = null;
    current = null;
    isInitialized = false;
  }
}

class BGMHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      BGM.resume();
    } else {
      BGM.pause();
    }
  }
}

enum BGMType { home, playing }

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

class BGM {
  static AudioPlayer? _homePlayer;
  static AudioPlayer? _playingPlayer;
  static BGMType? current;
  static bool isPaused = false;
  static bool isInitialized = false;

  static Future<void> preload() async {
    try {
      print('BGM: Starting preload...');
      _homePlayer = AudioPlayer();
      _playingPlayer = AudioPlayer();

      await _homePlayer!.setReleaseMode(ReleaseMode.loop);
      await _playingPlayer!.setReleaseMode(ReleaseMode.loop);

      // Set volume
      await _homePlayer!.setVolume(0.3);
      await _playingPlayer!.setVolume(0.3);

      isInitialized = true;
      print('BGM: Preload completed successfully');
    } catch (e) {
      print('Error preloading BGM: $e');
    }
  }

  static Future<void> _update() async {
    if (!isInitialized) return;
    if (current == null) return;

    try {
      if (isPaused) {
        if (current == BGMType.home && _homePlayer != null)
          await _homePlayer!.pause();
        if (current == BGMType.playing && _playingPlayer != null)
          await _playingPlayer!.pause();
      } else {
        if (current == BGMType.home && _homePlayer != null)
          await _homePlayer!.resume();
        if (current == BGMType.playing && _playingPlayer != null)
          await _playingPlayer!.resume();
      }
    } catch (e) {
      print('Error updating BGM: $e');
    }
  }

  static Future<void> play(BGMType what) async {
    if (!isInitialized) {
      print('BGM: Not initialized, initializing now...');
      await preload();
    }

    try {
      print('BGM: Playing ${what.toString()}');
      if (current != what) {
        if (what == BGMType.home && _homePlayer != null) {
          current = BGMType.home;
          if (_playingPlayer != null) await _playingPlayer!.stop();
          await _homePlayer!.play(AssetSource('home.mp3'));
          print('BGM: Home music started');
        }
        if (what == BGMType.playing && _playingPlayer != null) {
          current = BGMType.playing;
          if (_homePlayer != null) await _homePlayer!.stop();
          await _playingPlayer!.play(AssetSource('playing.mp3'));
          print('BGM: Playing music started');
        }
      }
      await _update();
    } catch (e) {
      print('Error playing BGM: $e');
    }
  }

  static void pause() {
    isPaused = true;
    _update();
  }

  static void resume() {
    isPaused = false;
    _update();
  }

  static Future<void> stop() async {
    try {
      if (_homePlayer != null) await _homePlayer!.stop();
      if (_playingPlayer != null) await _playingPlayer!.stop();
      current = null;
    } catch (e) {
      print('Error stopping BGM: $e');
    }
  }
}

class BGMHandler extends WidgetsBindingObserver {
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      BGM.resume();
    } else {
      BGM.pause();
    }
  }
}

enum BGMType { home, playing }

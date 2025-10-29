import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bgm.dart';
import 'fruit_ninja_game.dart';

class FruitNinjaScreen extends StatefulWidget {
  const FruitNinjaScreen({Key? key}) : super(key: key);

  @override
  _FruitNinjaScreenState createState() => _FruitNinjaScreenState();
}

class _FruitNinjaScreenState extends State<FruitNinjaScreen> {
  late FruitNinjaGame game;
  bool isInitialized = false;

  BGMHandler? _bgmHandler;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      // Get SharedPreferences
      SharedPreferences storage = await SharedPreferences.getInstance();

      // Preload background music
      await BGM.preload();

      // Create game instance
      game = FruitNinjaGame(storage);

      // Add background music observer
      _bgmHandler = BGMHandler();
      WidgetsBinding.instance.addObserver(_bgmHandler!);

      setState(() {
        isInitialized = true;
      });
    } catch (e) {
      print('Error initializing Fruit Ninja game: $e');
    }
  }

  @override
  void dispose() {
    // Clean up resources
    if (_bgmHandler != null) {
      WidgetsBinding.instance.removeObserver(_bgmHandler!);
    }
    BGM.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Fruit Ninja'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Fruit Ninja'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: GameWidget(game: game),
    );
  }
}

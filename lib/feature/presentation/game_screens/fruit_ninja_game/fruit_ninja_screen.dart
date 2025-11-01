import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/bgm.dart';

class FruitNinjaScreen extends StatefulWidget {
  const FruitNinjaScreen({Key? key}) : super(key: key);

  @override
  _FruitNinjaScreenState createState() => _FruitNinjaScreenState();
}

class _FruitNinjaScreenState extends State<FruitNinjaScreen> {
  late Future<FruitGame> _gameFuture;

  @override
  void initState() {
    super.initState();
    _gameFuture = _initializeGame();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  Future<FruitGame> _initializeGame() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await BGM.preload();
    final game = FruitGame(storage);
    return game;
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<FruitGame>(
        future: _gameFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'Loading Game...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading game: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final game = snapshot.data!;
          return GestureDetector(
            onTapDown: (details) {
              game.onTapDown(details);
            },
            child: GameWidget(game: game),
          );
        },
      ),
    );
  }
}

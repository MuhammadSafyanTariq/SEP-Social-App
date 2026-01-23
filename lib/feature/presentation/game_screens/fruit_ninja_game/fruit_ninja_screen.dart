import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sep/components/dialogs/game_start_dialog.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/bgm.dart';
import 'package:sep/feature/presentation/wallet/packages_screen.dart';
import 'package:sep/services/game/game_manager.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';

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
    // Set the start game callback
    game.onStartGameCallback = _handleGameStart;
    // Set the quit game callback
    game.onQuit = _handleQuit;
    return game;
  }

  void _handleQuit() {
    // Stop all music before exiting
    BGM.stop();
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleGameStart(FruitGame game) async {
    // Check if user can start the game
    final status = await GameManager.canStartGame(GameManager.FRUIT_NINJA_GAME);

    if (!status.canStart) {
      // Show insufficient tokens dialog
      if (!mounted) return;
      await InsufficientTokensDialog.show(
        context: context,
        tokensRequired: status.tokensRequired,
        onBuyTokens: () {
          Navigator.of(context).pop(); // Close dialog first
          context.pushNavigator(PackagesScreen());
        },
      );
      // Exit game screen after dialog is closed
      if (mounted) {
        BGM.stop();
        Navigator.of(context).pop();
      }
      return;
    }

    // Show confirmation dialog
    if (!mounted) return;
    final confirmed = await GameStartDialog.show(
      context: context,
      gameId: GameManager.FRUIT_NINJA_GAME,
      gameName: 'Fruit Ninja',
      isFree: status.isFree,
      tokensRequired: status.tokensRequired,
    );

    if (confirmed == true) {
      // Start the game and deduct tokens if needed
      final success = await GameManager.startGame(
        GameManager.FRUIT_NINJA_GAME,
        isFree: status.isFree,
      );

      if (success) {
        // Actually start the game
        game.startGamePlay();
      } else {
        AppUtils.toastError('Failed to start game. Please try again.');
      }
    }
  }

  @override
  void dispose() {
    // Stop all music when screen is disposed
    BGM.stop();
    
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
    return WillPopScope(
      onWillPop: () async {
        BGM.stop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            FutureBuilder<FruitGame>(
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
            // Floating exit button
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    BGM.stop();
                    Navigator.of(context).pop();
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

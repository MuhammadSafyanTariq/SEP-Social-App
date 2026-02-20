import 'package:flutter/material.dart';
import 'package:sep/components/dialogs/game_start_dialog.dart';
import 'package:sep/feature/presentation/wallet/packages_screen.dart';
import 'package:sep/services/game/game_manager.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';

import '../game/assets.dart';
import '../game/flappy_bird_game.dart';

class MainMenuScreen extends StatelessWidget {
  final FlappyBirdGame game;
  static const String id = 'mainMenu';

  const MainMenuScreen({Key? key, required this.game}) : super(key: key);

  Future<void> _handleGameStart(BuildContext context) async {
    // Check if user can start the game
    final status = await GameManager.canStartGame(GameManager.FLAPPY_BIRD_GAME);

    if (!status.canStart) {
      // Show insufficient tokens dialog
      await InsufficientTokensDialog.show(
        context: context,
        tokensRequired: status.tokensRequired,
        onBuyTokens: () {
          // Dialog closes itself; push packages on root navigator
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => PackagesScreen()),
          );
        },
      );
      // Exit game screen after dialog is closed
      game.pauseEngine();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }

    // Show confirmation dialog
    final confirmed = await GameStartDialog.show(
      context: context,
      gameId: GameManager.FLAPPY_BIRD_GAME,
      gameName: 'Flappy Bird',
      isFree: status.isFree,
      tokensRequired: status.tokensRequired,
    );

    if (confirmed == true) {
      // Start the game and deduct tokens if needed
      final success = await GameManager.startGame(
        GameManager.FLAPPY_BIRD_GAME,
        isFree: status.isFree,
      );

      if (success) {
        game.overlays.remove(MainMenuScreen.id);
        game.resumeEngine();
      } else {
        AppUtils.toastError('Failed to start game. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    game.pauseEngine();

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => _handleGameStart(context),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.menu),
                  fit: BoxFit.cover,
                ),
              ),
              child: Image.asset(Assets.message),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.black,
                size: 25,
              ),
              onPressed: () {
                // Pause game and exit
                game.pauseEngine();
                context.pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

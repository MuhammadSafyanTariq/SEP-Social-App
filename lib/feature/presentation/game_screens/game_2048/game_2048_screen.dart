import 'package:flutter/material.dart';
import 'package:sep/components/dialogs/game_start_dialog.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/services/game/game_manager.dart';
import 'package:sep/utils/appUtils.dart';
import 'home.dart';

/// Wrapper screen for 2048 game that integrates with the app's game management system
class Game2048Screen extends StatefulWidget {
  const Game2048Screen({Key? key}) : super(key: key);

  @override
  _Game2048ScreenState createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  bool _isInitialized = false;
  bool _canStart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGameStartDialog();
    });
  }

  Future<void> _showGameStartDialog() async {
    final status = await GameManager.canStartGame(GameManager.GAME_2048);

    if (!status.canStart) {
      // Show insufficient tokens dialog
      InsufficientTokensDialog.show(
        context: context,
        tokensRequired: GameManager.TOKEN_COST_PER_RETRY,
        onBuyTokens: () {
          // Navigate to token purchase screen or wallet
          AppUtils.toast('Token purchase coming soon!');
        },
      );
      // Go back after showing dialog
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }

    // Show game start confirmation dialog
    final confirmed = await GameStartDialog.show(
      context: context,
      gameId: GameManager.GAME_2048,
      gameName: '2048',
      isFree: status.isFree,
      tokensRequired: status.tokensRequired,
    );

    if (confirmed == true) {
      // Start the game
      final success = await GameManager.startGame(
        GameManager.GAME_2048,
        isFree: status.isFree,
      );

      if (success) {
        setState(() {
          _isInitialized = true;
          _canStart = true;
        });
      } else {
        AppUtils.toastError('Failed to start game');
        Navigator.of(context).pop();
      }
    } else {
      // User cancelled, go back
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || !_canStart) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog before leaving
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit Game?'),
            content: Text(
              'Are you sure you want to exit the game? Your progress will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Exit', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(child: HomePage()),
      ),
    );
  }
}

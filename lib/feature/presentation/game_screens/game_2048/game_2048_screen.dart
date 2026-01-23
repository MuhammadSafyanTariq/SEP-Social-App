import 'package:flutter/material.dart';
import 'package:sep/components/dialogs/game_start_dialog.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/presentation/wallet/packages_screen.dart';
import 'package:sep/services/game/game_manager.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
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
  bool _hasInsufficientFunds = false;
  String? _errorMessage;

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
      if (mounted) {
        await InsufficientTokensDialog.show(
          context: context,
          tokensRequired: status.tokensRequired,
          onBuyTokens: () {
            Navigator.of(context).pop(); // Close dialog
            context.pushNavigator(PackagesScreen());
          },
        );
        // Go back after dialog is closed
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
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
    if (_hasInsufficientFunds) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, 
                  color: Colors.red, 
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'Insufficient Tokens',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  _errorMessage ?? 'You need tokens to play this game.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.pushNavigator(PackagesScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Buy Tokens'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
            onPressed: () async {
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
              if (shouldPop == true && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: SafeArea(child: HomePage()),
      ),
    );
  }
}

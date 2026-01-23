import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/services/game/game_manager.dart';

/// Dialog to show game start confirmation with token cost info
class GameStartDialog extends StatelessWidget {
  final String gameId;
  final String gameName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isFree;
  final int tokensRequired;

  const GameStartDialog({
    Key? key,
    required this.gameId,
    required this.gameName,
    required this.onConfirm,
    required this.onCancel,
    required this.isFree,
    required this.tokensRequired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            isFree ? Icons.celebration : Icons.sports_esports,
            color: isFree ? Colors.green : AppColors.primaryColor,
            size: 30,
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextView(
              text: isFree ? 'Free Play!' : 'Play Again?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
            text: 'Game: $gameName',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          if (isFree) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextView(
                      text: 'Your first play today is FREE!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            TextView(
              text: 'Next plays will cost $tokensRequired tokens each.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextView(
                          text: 'Token Cost',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextView(
                    text: 'This game will cost $tokensRequired tokens to play.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  SizedBox(height: 4),
                  TextView(
                    text:
                        'Current Balance: ${GameManager.getCurrentTokenBalance()} tokens',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: TextView(
            text: 'Cancel',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: isFree ? Colors.green : AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: TextView(
            text: isFree ? 'Play Free' : 'Play ($tokensRequired Tokens)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Show the game start dialog
  static Future<bool?> show({
    required BuildContext context,
    required String gameId,
    required String gameName,
    required bool isFree,
    required int tokensRequired,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameStartDialog(
        gameId: gameId,
        gameName: gameName,
        isFree: isFree,
        tokensRequired: tokensRequired,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }
}

/// Dialog to show insufficient tokens error
class InsufficientTokensDialog extends StatelessWidget {
  final int tokensRequired;
  final VoidCallback onBuyTokens;

  const InsufficientTokensDialog({
    Key? key,
    required this.tokensRequired,
    required this.onBuyTokens,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
          SizedBox(width: 10),
          Expanded(
            child: TextView(
              text: 'Insufficient Tokens',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
            text: 'You need $tokensRequired tokens to play this game.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.red, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: TextView(
                    text:
                        'Current Balance: ${GameManager.getCurrentTokenBalance()} tokens',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          TextView(
            text: 'Purchase more tokens to continue playing!',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: TextView(
            text: 'Later',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onBuyTokens();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: TextView(
            text: 'Buy Tokens',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Show the insufficient tokens dialog
  static Future<void> show({
    required BuildContext context,
    required int tokensRequired,
    required VoidCallback onBuyTokens,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InsufficientTokensDialog(
        tokensRequired: tokensRequired,
        onBuyTokens: onBuyTokens,
      ),
    ).then((_) {});
  }
}

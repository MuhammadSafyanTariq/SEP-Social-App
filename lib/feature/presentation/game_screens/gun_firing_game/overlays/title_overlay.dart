import 'package:flutter/material.dart';
import 'package:sep/components/dialogs/game_start_dialog.dart';
import 'package:sep/feature/presentation/wallet/packages_screen.dart';
import 'package:sep/services/game/game_manager.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';

import '../my_game.dart';

class TitleOverlay extends StatefulWidget {
  final MyGame game;
  static const String id = 'title';
  const TitleOverlay({super.key, required this.game});

  @override
  State<TitleOverlay> createState() => _TitleOverlayState();
}

class _TitleOverlayState extends State<TitleOverlay> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(milliseconds: 0),
      () {
        setState(() {
          _opacity = 1.0;
        });
      },
    );
  }

  Future<void> _handleGameStart() async {
    // Check if user can start the game
    final status = await GameManager.canStartGame(GameManager.SHOOTING_GAME);

    if (!status.canStart) {
      // Show insufficient tokens dialog
      if (!mounted) return;
      InsufficientTokensDialog.show(
        context: context,
        tokensRequired: status.tokensRequired,
        onBuyTokens: () {
          context.pushNavigator(PackagesScreen());
        },
      );
      return;
    }

    // Show confirmation dialog
    if (!mounted) return;
    final confirmed = await GameStartDialog.show(
      context: context,
      gameId: GameManager.SHOOTING_GAME,
      gameName: 'Shooting Rush',
      isFree: status.isFree,
      tokensRequired: status.tokensRequired,
    );

    if (confirmed == true) {
      // Start the game and deduct tokens if needed
      final success = await GameManager.startGame(
        GameManager.SHOOTING_GAME,
        isFree: status.isFree,
      );

      if (success) {
        widget.game.audioManager.playSound('start');
        widget.game.startGame();
        setState(() {
          _opacity = 0.0;
        });
      } else {
        AppUtils.toastError('Failed to start game. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String playerColor =
        widget.game.playerColors[widget.game.playerColorIndex];

    return AnimatedOpacity(
      onEnd: () {
        if (_opacity == 0.0) {
          widget.game.overlays.remove('Title');
        }
      },
      opacity: _opacity,
      duration: const Duration(milliseconds: 500),
      child: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(height: 60),
            SizedBox(
              width: 270,
              child: Image.asset('assets/images/title.png'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    widget.game.audioManager.playSound('click');
                    setState(() {
                      widget.game.playerColorIndex--;
                      if (widget.game.playerColorIndex < 0) {
                        widget.game.playerColorIndex =
                            widget.game.playerColors.length - 1;
                      }
                    });
                  },
                  child: Transform.flip(
                    flipX: true,
                    child: SizedBox(
                      width: 30,
                      child: Image.asset('assets/images/arrow_button.png'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
                  child: SizedBox(
                    width: 100,
                    child: Image.asset(
                      'assets/images/player_${playerColor}_off.png',
                      gaplessPlayback: true,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.game.audioManager.playSound('click');
                    setState(() {
                      widget.game.playerColorIndex++;
                      if (widget.game.playerColorIndex ==
                          widget.game.playerColors.length) {
                        widget.game.playerColorIndex = 0;
                      }
                    });
                  },
                  child: SizedBox(
                    width: 30,
                    child: Image.asset('assets/images/arrow_button.png'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _handleGameStart,
              child: SizedBox(
                width: 200,
                child: Image.asset('assets/images/start_button.png'),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Material(   // <-- Add this
                    color: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              widget.game.audioManager.toggleMusic();
                            });
                          },
                          icon: Icon(
                            widget.game.audioManager.musicEnabled
                                ? Icons.music_note_rounded
                                : Icons.music_off_rounded,
                            color: widget.game.audioManager.musicEnabled
                                ? Colors.white
                                : Colors.grey,
                            size: 30,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              widget.game.audioManager.toggleSounds();
                            });
                          },
                          icon: Icon(
                            widget.game.audioManager.soundsEnabled
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            color: widget.game.audioManager.soundsEnabled
                                ? Colors.white
                                : Colors.grey,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
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

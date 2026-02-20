import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/components/btn.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/pages/pick.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/board.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/provider.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/sound.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/theme/theme.dart';

class StartPage extends StatelessWidget {
  final BoardService boardService = locator<BoardService>();
  final soundService = locator<SoundService>();

  StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [MyTheme.red, MyTheme.blue],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Tic Tac Toe",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 65,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'DancingScript',
                      ),
                    ),
                    Image.asset(
                      AppImages.ticTacToeImg,
                      width: 200,
                      height: 200,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.grid_3x3,
                        size: 120,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Btn(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => PickPage()),
                        );
                      },
                      height: 80,
                      width: 250,
                      borderRadius: 250,
                      color: Colors.white,
                      child: Text(
                        "Start Game".toUpperCase(),
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

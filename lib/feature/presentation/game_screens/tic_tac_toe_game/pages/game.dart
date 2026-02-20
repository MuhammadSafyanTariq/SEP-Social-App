import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/components/board.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/components/o.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/components/x.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/pages/pick.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/board.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/provider.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/theme/theme.dart';

class GamePage extends StatefulWidget {
  @override
  State<GamePage> createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  final boardService = locator<BoardService>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) boardService.newGame();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: StreamBuilder<MapEntry<int, int>>(
              stream: boardService.score$,
              builder: (context, AsyncSnapshot<MapEntry<int, int>> snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                final int xScore = snapshot.data!.key;
                final int oScore = snapshot.data!.value;
                // When player is X, key is player score; when player is O, value is player score.
                final int playerScore = groupValue == 'X' ? xScore : oScore;
                final int computerScore = groupValue == 'X' ? oScore : xScore;

                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              color: Colors.white,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Material(
                                      elevation: 5,
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Center(
                                          child: Text("$playerScore",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18))),
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                  groupValue == 'X'
                                      ? X(35, 10)
                                      : O(35, MyTheme.blue),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Text("Player",
                                        style: TextStyle(fontSize: 20)),
                                  )
                                ],
                              ),
                            ),
                            Container(
                                child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [Board()])),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              color: Colors.white,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  groupValue == 'X'
                                      ? O(35, MyTheme.blue)
                                      : X(35, 10),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text("Computer",
                                        style: TextStyle(fontSize: 20)),
                                  ),
                                  Expanded(child: Container()),
                                  SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Material(
                                      elevation: 5,
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Center(
                                          child: Text("$computerScore",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        height: 60,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(child: Container()),
                            IconButton(
                              icon: Icon(Icons.home),
                              onPressed: () {
                                boardService.newGame();
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                              color: Colors.black87,
                              iconSize: 40,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

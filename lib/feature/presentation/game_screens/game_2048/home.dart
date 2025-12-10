import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sep/components/dialogs/game_start_dialog.dart';
import 'package:sep/services/game/game_manager.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/game_messages.dart';
import 'mycolor.dart';
import 'tile.dart';
import 'grid.dart';
import 'game.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  List<List<int>> grid = [];
  List<List<int>> gridNew = [];
  SharedPreferences? sharedPreferences;
  int score = 0;
  bool isgameOver = false;
  bool isgameWon = false;
  bool _hasShownGameOverDialog = false;

  List<Widget> getGrid(double width, double height) {
    List<Widget> grids = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        int num = grid[i][j];
        String number;
        int color;
        if (num == 0) {
          color = MyColor.emptyGridBackground;
          number = "";
        } else if (num == 2 || num == 4) {
          color = MyColor.gridColorTwoFour;
          number = "${num}";
        } else if (num == 8 || num == 64 || num == 256) {
          color = MyColor.gridColorEightSixtyFourTwoFiftySix;
          number = "${num}";
        } else if (num == 16 || num == 32 || num == 1024) {
          color = MyColor.gridColorSixteenThirtyTwoOneZeroTwoFour;
          number = "${num}";
        } else if (num == 128 || num == 512) {
          color = MyColor.gridColorOneTwentyEightFiveOneTwo;
          number = "${num}";
        } else {
          color = MyColor.gridColorWin;
          number = "${num}";
        }
        double size = 40.0;
        String n = "${number}";
        switch (n.length) {
          case 1:
          case 2:
            size = 40.0;
            break;
          case 3:
            size = 30.0;
            break;
          case 4:
            size = 20.0;
            break;
        }
        grids.add(Tile(number, width, height, color, size));
      }
    }
    return grids;
  }

  void handleGesture(int direction) {
    /*
    
      0 = up
      1 = down
      2 = left
      3 = right

    */
    bool flipped = false;
    bool played = true;
    bool rotated = false;
    if (direction == 0) {
      setState(() {
        grid = transposeGrid(grid);
        grid = flipGrid(grid);
        rotated = true;
        flipped = true;
      });
    } else if (direction == 1) {
      setState(() {
        grid = transposeGrid(grid);
        rotated = true;
      });
    } else if (direction == 2) {
    } else if (direction == 3) {
      setState(() {
        grid = flipGrid(grid);
        flipped = true;
      });
    } else {
      played = false;
    }

    if (played) {
      print('playing');
      List<List<int>> past = copyGrid(grid);
      print('past ${past}');
      for (int i = 0; i < 4; i++) {
        setState(() {
          List result = operate(grid[i], score, sharedPreferences);
          score = result[0];
          print('score in set state ${score}');
          grid[i] = result[1];
        });
      }
      setState(() {
        grid = addNumber(grid, gridNew);
      });
      bool changed = compare(past, grid);
      print('changed ${changed}');
      if (flipped) {
        setState(() {
          grid = flipGrid(grid);
        });
      }

      if (rotated) {
        setState(() {
          grid = transposeGrid(grid);
        });
      }

      if (changed) {
        setState(() {
          grid = addNumber(grid, gridNew);
          print('is changed');
        });
      } else {
        print('not changed');
      }

      bool gameover = isGameOver(grid);
      if (gameover) {
        print('game over');
        setState(() {
          isgameOver = true;
        });
        if (!_hasShownGameOverDialog) {
          _hasShownGameOverDialog = true;
          _showGameOverDialog();
        }
      }

      bool gamewon = isGameWon(grid);
      if (gamewon) {
        print("GAME WON");
        setState(() {
          isgameWon = true;
        });
        if (!_hasShownGameOverDialog) {
          _hasShownGameOverDialog = true;
          _showGameWonDialog();
        }
      }
      print(grid);
      print(score);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    grid = blankGrid();
    gridNew = blankGrid();
    addNumber(grid, gridNew);
    addNumber(grid, gridNew);
    super.initState();
  }

  Future<String> getHighScore() async {
    sharedPreferences = await SharedPreferences.getInstance();
    int score = sharedPreferences?.getInt('high_score') ?? 0;
    return score.toString();
  }

  Future<void> _showGameOverDialog() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (!mounted) return;

    final status = await GameManager.canStartGame(GameManager.GAME_2048);

    if (!status.canStart) {
      // Show insufficient tokens
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Game Over!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your Score: $score'),
              SizedBox(height: 16),
              Text(
                'Insufficient tokens to play again.',
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 8),
              Text(
                'Current Balance: ${GameManager.getCurrentTokenBalance()} tokens',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit game
              },
              child: Text('Exit'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit to buy tokens
                AppUtils.toast('Token purchase coming soon!');
              },
              child: Text('Buy Tokens'),
            ),
          ],
        ),
      );
      return;
    }

    // Show play again dialog
    final playAgain = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.sports_esports, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Game Over!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $score',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200, width: 2),
              ),
              child: Text(
                GameMessages.get2048Message(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
            SizedBox(height: 16),
            if (!status.isFree) ...[
              Text(
                'Play again for ${status.tokensRequired} tokens?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Current Balance: ${GameManager.getCurrentTokenBalance()} tokens',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ] else ...[
              Text(
                'Play again for FREE!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(status.isFree ? 'Play Free' : 'Play Again'),
          ),
        ],
      ),
    );

    if (playAgain == true) {
      final success = await GameManager.startGame(
        GameManager.GAME_2048,
        isFree: status.isFree,
      );

      if (success) {
        _resetGame();
      } else {
        AppUtils.toastError('Failed to start game');
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop(); // Exit game
    }
  }

  Future<void> _showGameWonDialog() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (!mounted) return;

    final continueGame = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('🎉 You Won!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Congratulations!'),
            SizedBox(height: 8),
            Text('Your Score: $score'),
            SizedBox(height: 16),
            Text('Continue playing or start a new game?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('New Game'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Continue'),
          ),
        ],
      ),
    );

    if (continueGame == true) {
      setState(() {
        isgameWon = false;
        _hasShownGameOverDialog = false;
      });
    } else {
      _resetGame();
    }
  }

  void _resetGame() {
    setState(() {
      grid = blankGrid();
      gridNew = blankGrid();
      grid = addNumber(grid, gridNew);
      grid = addNumber(grid, gridNew);
      score = 0;
      isgameOver = false;
      isgameWon = false;
      _hasShownGameOverDialog = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double width = MediaQuery.of(context).size.width;
    double gridWidth = (width - 80) / 4;
    double gridHeight = gridWidth;
    double height = 30 + (gridHeight * 4) + 10;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '2048',
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  width: 200.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black,
                    border: Border.all(color: Color(0xFF0CD03D), width: 2),
                  ),
                  height: 82.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 2.0),
                        child: Text(
                          'Score',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          '${score}',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: height,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: GestureDetector(
                        child: GridView.count(
                          primary: false,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          crossAxisCount: 4,
                          children: getGrid(gridWidth, gridHeight),
                        ),
                        onVerticalDragEnd: (DragEndDetails details) {
                          //primaryVelocity -ve up +ve down
                          if ((details.primaryVelocity ?? 0) < 0) {
                            handleGesture(0);
                          } else if ((details.primaryVelocity ?? 0) > 0) {
                            handleGesture(1);
                          }
                        },
                        onHorizontalDragEnd: (details) {
                          //-ve right, +ve left
                          if ((details.primaryVelocity ?? 0) > 0) {
                            handleGesture(2);
                          } else if ((details.primaryVelocity ?? 0) < 0) {
                            handleGesture(3);
                          }
                        },
                      ),
                    ),
                    isgameOver
                        ? Container(
                            height: height,
                            color: Color(MyColor.transparentWhite),
                            child: Center(
                              child: Text(
                                'Game over!',
                                style: TextStyle(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(MyColor.gridBackground),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                    isgameWon
                        ? Container(
                            height: height,
                            color: Color(MyColor.transparentWhite),
                            child: Center(
                              child: Text(
                                'You Won!',
                                style: TextStyle(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(MyColor.gridBackground),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                color: Color(MyColor.gridBackground),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.black,
                        border: Border.all(color: Color(0xFF0CD03D), width: 2),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: IconButton(
                          iconSize: 35.0,
                          icon: Icon(Icons.refresh, color: Color(0xFF0CD03D)),
                          onPressed: () {
                            _resetGame();
                          },
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.black,
                        border: Border.all(color: Color(0xFF0CD03D), width: 2),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'High Score',
                              style: TextStyle(
                                color: Color(0xFF0CD03D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FutureBuilder<String>(
                              future: getHighScore(),
                              builder: (ctx, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    snapshot.data ?? '0',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else {
                                  return Text(
                                    '0',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
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

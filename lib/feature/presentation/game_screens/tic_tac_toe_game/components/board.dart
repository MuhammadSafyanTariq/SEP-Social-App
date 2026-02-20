import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/components/o.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/components/x.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/alert.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/board.dart' as board_svc;
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/provider.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/theme/theme.dart';

class Board extends StatefulWidget {
  const Board({Key? key}) : super(key: key);

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  final boardService = locator<board_svc.BoardService>();
  final alertService = locator<AlertService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        MapEntry<List<List<String>>, MapEntry<board_svc.BoardState, String?>>>(
      stream: Rx.combineLatest2(
          boardService.board$,
          boardService.boardState$,
          (List<List<String>> a, MapEntry<board_svc.BoardState, String?> b) =>
              MapEntry(a, b)),
      builder: (context,
          AsyncSnapshot<
                  MapEntry<List<List<String>>,
                      MapEntry<board_svc.BoardState, String?>>>
              snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final List<List<String>> board = snapshot.data!.key;
        final MapEntry<board_svc.BoardState, String?> state = snapshot.data!.value;

        if (state.key == board_svc.BoardState.Done) {
          boardService.resetBoard();

          String title = 'Winner';
          if (state.value == null) {
            title = "Draw";
          }

          Widget body = state.value == 'X'
              ? X(50, 20)
              : (state.value == "O"
                  ? O(50, MyTheme.blue)
                  : Row(
                      children: [X(50, 20), O(50, MyTheme.blue)],
                    ));

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Alert(
              context: context,
              title: title,
              style: alertService.resultAlertStyle,
              buttons: [],
              content: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [body]),
            ).show();
          });
        }

        return Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                blurRadius: 7.0,
                spreadRadius: 0.0,
                color: Color(0x1F000000),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: board
                .asMap()
                .entries
                .map(
                  (entry) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: entry.value
                        .asMap()
                        .entries
                        .map(
                          (cell) => GestureDetector(
                            onTap: () {
                              if (board[entry.key][cell.key] != ' ') return;
                              boardService.newMove(entry.key, cell.key);
                            },
                            child: _buildBox(
                                entry.key, cell.key, board[entry.key][cell.key]),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildBox(int i, int j, String item) {
    BoxBorder border = Border();
    BorderSide borderStyle = BorderSide(width: 1, color: Colors.black26);
    double height = 80;
    double width = 60;
    if (j == 1) {
      border = Border(right: borderStyle, left: borderStyle);
      height = width = 80;
    }
    if (i == 1) {
      border = Border(top: borderStyle, bottom: borderStyle);
    }
    if (i == 1 && j == 1) {
      border = Border(
          top: borderStyle,
          bottom: borderStyle,
          left: borderStyle,
          right: borderStyle);
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: border,
      ),
      height: height,
      width: width,
      child: Center(
        child: item == ' '
            ? null
            : item == 'X'
                ? X(50, 13)
                : O(50, MyTheme.blue),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/theme/theme.dart';

class X extends StatelessWidget {
  final double size;
  final double height;

  const X(this.size, this.height, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            top: size / 2 - height / 2,
            child: RotationTransition(
              turns: AlwaysStoppedAnimation(-45 / 360),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  color: MyTheme.red,
                ),
                height: height,
                width: size,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: size / 2 - height / 2,
            child: RotationTransition(
              turns: AlwaysStoppedAnimation(45 / 360),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  color: MyTheme.red,
                ),
                height: height,
                width: size,
              ),
            ),
          )
        ],
      ),
    );
  }
}

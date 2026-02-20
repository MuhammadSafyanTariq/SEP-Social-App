import 'package:flutter/material.dart';

class O extends StatelessWidget {
  final double size;
  final Color color;

  const O(this.size, this.color, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(
          color: color,
          width: size / 8,
        ),
      ),
    );
  }
}

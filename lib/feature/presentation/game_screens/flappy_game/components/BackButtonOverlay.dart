// import 'package:flutter/material.dart';
// import 'package:sep/utils/extensions/contextExtensions.dart';
// import '../game/flappy_bird_game.dart';
//
// class BackButtonOverlay extends StatelessWidget {
//   final FlappyBirdGame game;
//
//   const BackButtonOverlay({super.key, required this.game});
//
//   @override
//   Widget build(BuildContext context) {
//     return Material( // <-- This fixes the issue
//       color: Colors.transparent,
//       child: SafeArea(
//         child: Align(
//           alignment: Alignment.topLeft,
//           child: IconButton(
//             icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 25),
//             onPressed: () {
//               game.pauseEngine();
//              context.pop();
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

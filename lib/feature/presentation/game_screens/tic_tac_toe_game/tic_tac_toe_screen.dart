import 'package:flutter/material.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/pages/start.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/provider.dart';

/// Tic-Tac-Toe game screen (token flow handled before navigation).
class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  @override
  void initState() {
    super.initState();
    setupLocator();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Tic Tac Toe'),
      ),
      body: StartPage(),
    );
  }
}

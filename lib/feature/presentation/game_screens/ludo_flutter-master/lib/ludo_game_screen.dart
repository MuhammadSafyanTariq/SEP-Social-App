import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'ludo_provider.dart';
import 'main_screen.dart';

/// Ludo game screen (token flow handled before navigation).
class LudoGameScreen extends StatefulWidget {
  const LudoGameScreen({super.key});

  @override
  State<LudoGameScreen> createState() => _LudoGameScreenState();
}

class _LudoGameScreenState extends State<LudoGameScreen> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.wait([
        precacheImage(
          const AssetImage(
            'lib/feature/presentation/game_screens/ludo_flutter-master/assets/images/thankyou.gif',
          ),
          context,
        ),
        precacheImage(
          const AssetImage(
            'lib/feature/presentation/game_screens/ludo_flutter-master/assets/images/board.png',
          ),
          context,
        ),
        precacheImage(
          const AssetImage(
            'lib/feature/presentation/game_screens/ludo_flutter-master/assets/images/dice/1.png',
          ),
          context,
        ),
        precacheImage(
          const AssetImage(
            'lib/feature/presentation/game_screens/ludo_flutter-master/assets/images/dice/2.png',
          ),
          context,
        ),
        precacheImage(
          const AssetImage(
            'lib/feature/presentation/game_screens/ludo_flutter-master/assets/images/dice/3.png',
          ),
          context,
        ),
        precacheImage(
          const AssetImage(
            'lib/feature/presentation/game_screens/ludo_flutter-master/assets/images/dice/4.png',
          ),
          context,
        ),
        precacheImage(
          const AssetImage(
            'lib/feature/presentation/game_screens/ludo_flutter-master/assets/images/dice/5.png',
          ),
          context,
        ),
        precacheImage(
          const AssetImage(
            'lib/feature/presentation/game_screens/ludo_flutter-master/assets/images/dice/6.png',
          ),
          context,
        ),
        precacheImage(
          const AssetImage(
            'lib/feature/presentation/game_screens/ludo_flutter-master/assets/images/dice/draw.gif',
          ),
          context,
        ),
        precacheImage(
          const AssetImage(
            'lib/feature/presentation/game_screens/ludo_flutter-master/assets/images/crown/1st.png',
          ),
          context,
        ),
        precacheImage(
          const AssetImage(
            'lib/feature/presentation/game_screens/ludo_flutter-master/assets/images/crown/2nd.png',
          ),
          context,
        ),
        precacheImage(
          const AssetImage(
            'lib/feature/presentation/game_screens/ludo_flutter-master/assets/images/crown/3rd.png',
          ),
          context,
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Ludo'),
      ),
      body: ChangeNotifierProvider(
        create: (_) => LudoProvider()..startGame(),
        child: const SafeArea(
          child: MainScreen(),
        ),
      ),
    );
  }
}


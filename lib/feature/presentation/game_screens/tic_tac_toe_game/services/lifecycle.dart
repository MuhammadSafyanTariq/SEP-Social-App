import 'package:flutter/material.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/provider.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/sound.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/stoppable_service.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget child;
  LifeCycleManager({super.key, required this.child});

  @override
  State<LifeCycleManager> createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  List<StoppableService> servicesToManager = [
    locator<SoundService>(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    for (var service in servicesToManager) {
      if (state == AppLifecycleState.resumed) {
        service.start();
      } else {
        service.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

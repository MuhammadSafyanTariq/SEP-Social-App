import 'package:get_it/get_it.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/alert.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/board.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/sound.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  if (!locator.isRegistered<BoardService>()) {
    locator.registerSingleton(BoardService());
    locator.registerSingleton(SoundService());
    locator.registerSingleton(AlertService());
  }
}

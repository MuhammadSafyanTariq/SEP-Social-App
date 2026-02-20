import 'package:rxdart/rxdart.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/spotify_api.dart';
import 'package:sep/feature/presentation/game_screens/tic_tac_toe_game/services/stoppable_service.dart';

class SoundService extends StoppableService {
  final BehaviorSubject<bool> _enableSound$ = BehaviorSubject<bool>.seeded(true);
  BehaviorSubject<bool> get enableSound$ => _enableSound$;

  @override
  void start() {
    super.start();
    PlayMusic.resume();
  }

  @override
  void stop() {
    super.stop();
    PlayMusic.pause();
  }

  playSpotify() {
    PlayMusic().connectToSpotifyRemote();
  }

  pauseSpotify() {
    bool isSoundEnabled = _enableSound$.value;
    if (!isSoundEnabled) {
      PlayMusic.pause();
    } else {
      PlayMusic.resume();
    }
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/data/repository/iAuthRepository.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';

/// Manages game attempts and token deduction for daily free games.
/// Play state is scoped per user so each account gets its own "free today" state.
class GameManager {
  static const String _lastPlayDatePrefix = 'last_play_date_';
  static const String _hasPlayedTodayPrefix = 'has_played_today_';
  static const int TOKEN_COST_PER_RETRY = 2;

  static String get _userId => Preferences.uid ?? '';

  static String _lastPlayKey(String gameId) =>
      '${_lastPlayDatePrefix}${gameId}_$_userId';
  static String _hasPlayedKey(String gameId) =>
      '${_hasPlayedTodayPrefix}${gameId}_$_userId';

  static const String FLAPPY_BIRD_GAME = 'flappy_bird';
  static const String SHOOTING_GAME = 'shooting_rush';
  static const String FRUIT_NINJA_GAME = 'fruit_ninja';
  static const String GAME_2048 = 'game_2048';
  static const String TIC_TAC_TOE_GAME = 'tic_tac_toe';
  static const String CAR_RACE_GAME = 'car_race';

  static SharedPreferences? _prefs;

  /// Initialize the game manager
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get today's date as a string (YYYY-MM-DD format)
  static String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Check if the user has played this game today
  static Future<bool> hasPlayedToday(String gameId) async {
    await init();
    final lastPlayDate = _prefs?.getString(_lastPlayKey(gameId));
    final today = _getTodayDateString();
    return lastPlayDate == today;
  }

  /// Check if user can play for free (first time today)
  static Future<bool> canPlayForFree(String gameId) async {
    return !(await hasPlayedToday(gameId));
  }

  /// Check if user has enough tokens for retry
  static Future<bool> hasEnoughTokens() async {
    final profileCtrl = ProfileCtrl.find;
    final tokenBalance = profileCtrl.profileData.value.actualTokenBalance;
    return tokenBalance >= TOKEN_COST_PER_RETRY;
  }

  /// Get current token balance
  static int getCurrentTokenBalance() {
    final profileCtrl = ProfileCtrl.find;
    return profileCtrl.profileData.value.actualTokenBalance;
  }

  /// Check if user can start a game (either free or has tokens)
  static Future<GameStartStatus> canStartGame(String gameId) async {
    final isFree = await canPlayForFree(gameId);

    if (isFree) {
      return GameStartStatus(
        canStart: true,
        isFree: true,
        tokensRequired: 0,
        message: 'First play of the day is FREE!',
      );
    }

    final hasTokens = await hasEnoughTokens();
    if (hasTokens) {
      return GameStartStatus(
        canStart: true,
        isFree: false,
        tokensRequired: TOKEN_COST_PER_RETRY,
        message: 'Play again costs $TOKEN_COST_PER_RETRY tokens',
      );
    }

    return GameStartStatus(
      canStart: false,
      isFree: false,
      tokensRequired: TOKEN_COST_PER_RETRY,
      message:
          'Insufficient tokens. You need $TOKEN_COST_PER_RETRY tokens to play again.',
    );
  }

  /// Mark the game as played today and deduct tokens if needed
  static Future<bool> startGame(String gameId, {bool isFree = true}) async {
    await init();

    if (!isFree) {
      // Deduct tokens
      final success = await _deductTokens(TOKEN_COST_PER_RETRY);
      if (!success) {
        AppUtils.toastError('Failed to deduct tokens. Please try again.');
        return false;
      }
    }

    // Mark as played today (scoped to current user)
    final today = _getTodayDateString();
    await _prefs?.setString(_lastPlayKey(gameId), today);
    await _prefs?.setBool(_hasPlayedKey(gameId), true);

    AppUtils.log('Game $gameId started. Free: $isFree');
    return true;
  }

  /// Deduct tokens from user's balance (call backend API)
  static Future<bool> _deductTokens(int amount) async {
    try {
      final profileCtrl = ProfileCtrl.find;
      final currentBalance = profileCtrl.profileData.value.actualTokenBalance;

      if (currentBalance < amount) {
        AppUtils.toastError('Insufficient tokens');
        return false;
      }

      // Use the new simplified deduct tokens endpoint
      final repository = IAuthRepository();
      final response = await repository.deductGameTokens(amount: amount);

      if (!response.isSuccess) {
        AppUtils.toastError('Failed to deduct tokens');
        AppUtils.log('Token deduction failed: ${response.getError}');
        return false;
      }

      AppUtils.log('Tokens deducted: $amount. Refreshing profile...');

      // Refresh profile to get updated token balance
      await profileCtrl.getProfileDetails();

      final newBalance = profileCtrl.profileData.value.actualTokenBalance;
      AppUtils.log('Token balance updated: $currentBalance -> $newBalance');
      AppUtils.toast('$amount tokens deducted for game');

      return true;
    } catch (e) {
      AppUtils.log('Error deducting tokens: $e');
      AppUtils.toastError('Failed to deduct tokens. Please try again.');
      return false;
    }
  }

  /// Reset all game data for the current user (for testing purposes)
  static Future<void> resetAllGames() async {
    await init();
    await _prefs?.remove(_lastPlayKey(FLAPPY_BIRD_GAME));
    await _prefs?.remove(_lastPlayKey(SHOOTING_GAME));
    await _prefs?.remove(_lastPlayKey(FRUIT_NINJA_GAME));
    await _prefs?.remove(_lastPlayKey(GAME_2048));
    await _prefs?.remove(_lastPlayKey(TIC_TAC_TOE_GAME));
    await _prefs?.remove(_lastPlayKey(CAR_RACE_GAME));
    await _prefs?.remove(_hasPlayedKey(FLAPPY_BIRD_GAME));
    await _prefs?.remove(_hasPlayedKey(SHOOTING_GAME));
    await _prefs?.remove(_hasPlayedKey(FRUIT_NINJA_GAME));
    await _prefs?.remove(_hasPlayedKey(GAME_2048));
    await _prefs?.remove(_hasPlayedKey(TIC_TAC_TOE_GAME));
    await _prefs?.remove(_hasPlayedKey(CAR_RACE_GAME));
    AppUtils.log('All game data reset for current user');
  }

  /// Get game status info for display
  static Future<String> getGameStatusText(String gameId) async {
    final isFree = await canPlayForFree(gameId);
    if (isFree) {
      return 'FREE Today';
    }
    return '$TOKEN_COST_PER_RETRY Tokens';
  }
}

/// Status information for starting a game
class GameStartStatus {
  final bool canStart;
  final bool isFree;
  final int tokensRequired;
  final String message;

  GameStartStatus({
    required this.canStart,
    required this.isFree,
    required this.tokensRequired,
    required this.message,
  });
}

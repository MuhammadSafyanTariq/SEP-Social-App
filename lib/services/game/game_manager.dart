import 'package:shared_preferences/shared_preferences.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/data/repository/iAuthRepository.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/appUtils.dart';

/// Manages game attempts and token deduction for daily free games
class GameManager {
  static const String _lastPlayDatePrefix = 'last_play_date_';
  static const String _hasPlayedTodayPrefix = 'has_played_today_';
  static const int TOKEN_COST_PER_RETRY = 2;
  
  static const String FLAPPY_BIRD_GAME = 'flappy_bird';
  static const String SHOOTING_GAME = 'shooting_rush';
  static const String FRUIT_NINJA_GAME = 'fruit_ninja';

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
    final lastPlayDate = _prefs?.getString('$_lastPlayDatePrefix$gameId');
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
      message: 'Insufficient tokens. You need $TOKEN_COST_PER_RETRY tokens to play again.',
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

    // Mark as played today
    final today = _getTodayDateString();
    await _prefs?.setString('$_lastPlayDatePrefix$gameId', today);
    await _prefs?.setBool('$_hasPlayedTodayPrefix$gameId', true);

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

      // Call backend API to deduct tokens
      final repository = IAuthRepository();
      final response = await repository.deductGameTokens(amount: amount);
      
      if (!response.isSuccess) {
        AppUtils.toastError('Failed to deduct tokens');
        return false;
      }

      AppUtils.log('Tokens deducted: $amount. Refreshing profile...');
      
      // Refresh profile to get updated token balance
      await profileCtrl.getProfileDetails();

      final newBalance = profileCtrl.profileData.value.actualTokenBalance;
      AppUtils.log('Token balance updated: $currentBalance -> $newBalance');
      AppUtils.toast('$amount tokens deducted');

      return true;
    } catch (e) {
      AppUtils.log('Error deducting tokens: $e');
      AppUtils.toastError('Failed to deduct tokens. Please try again.');
      return false;
    }
  }

  /// Reset all game data (for testing purposes)
  static Future<void> resetAllGames() async {
    await init();
    await _prefs?.remove('$_lastPlayDatePrefix$FLAPPY_BIRD_GAME');
    await _prefs?.remove('$_lastPlayDatePrefix$SHOOTING_GAME');
    await _prefs?.remove('$_lastPlayDatePrefix$FRUIT_NINJA_GAME');
    await _prefs?.remove('$_hasPlayedTodayPrefix$FLAPPY_BIRD_GAME');
    await _prefs?.remove('$_hasPlayedTodayPrefix$SHOOTING_GAME');
    await _prefs?.remove('$_hasPlayedTodayPrefix$FRUIT_NINJA_GAME');
    AppUtils.log('All game data reset');
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

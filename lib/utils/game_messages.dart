import 'dart:math';

/// Motivating and challenging game over messages for different games
class GameMessages {
  static final Random _random = Random();

  // Flappy Bird Messages
  static final List<String> flappyBirdMessages = [
    "So close! Those pipes won't beat themselves! 🐦",
    "Gravity wins this round... Ready for revenge? 💪",
    "Your bird believes in you! One more try? 🚀",
    "That pipe had your name on it... Show it who's boss! 🔥",
    "Champions fall 7 times, stand up 8! Let's fly! 🏆",
    "The sky is calling! Are you answering? ☁️",
    "Every master was once a beginner. Keep flapping! 🌟",
    "You're getting warmer! Victory is just a tap away! 🎯",
    "Those pipes are scared now! One more round? 💥",
    "Failure is just success in progress! Try again? 🚁",
  ];

  // Shooting Game Messages
  static final List<String> shootingGameMessages = [
    "Your aim is improving! Ready to show them? 🎯",
    "The targets are getting nervous! Reload? 🔫",
    "Every sharpshooter started somewhere! Again? 💪",
    "That was practice! Now for the real deal? 🔥",
    "Your trigger finger needs more action! Continue? 🏹",
    "Legends aren't made by quitting! One more? 🏆",
    "The battlefield awaits your return, soldier! 🎖️",
    "Your enemies are celebrating too early! Rematch? ⚔️",
    "Winners never quit! Quitters never win! Ready? 💥",
    "Your weapon is calling for redemption! Load up? 🚀",
  ];

  // Fruit Ninja Messages
  static final List<String> fruitNinjaMessages = [
    "Those fruits are mocking you! Slice again? 🍉",
    "Your blade thirsts for more! One more try? ⚔️",
    "The fruit stand is restocked! Ready, ninja? 🥷",
    "Ninjas never surrender! Show them your skills! 🔥",
    "That was just a warm-up slash! Continue? 💪",
    "Your katana needs to prove itself! Again? 🗡️",
    "The dojo is calling you back, master! 🏯",
    "Fruit salad won't make itself! Keep slicing? 🍊",
    "Your honor demands another round! Accept? 🎌",
    "The way of the ninja is perseverance! Ready? 🥋",
  ];

  // 2048 Game Messages
  static final List<String> game2048Messages = [
    "You were so close to 2048! One more try? 🎯",
    "Numbers don't lie, but you can improve! Again? 🔢",
    "Your brain is just warming up! Continue? 🧠",
    "That tile is waiting to be conquered! Ready? 💪",
    "Math geniuses are made, not born! Try again? 🏆",
    "Every grand master started at 2! Keep going? 🔥",
    "The grid believes in you! One more round? 🎲",
    "2048 is closer than you think! Play again? 🚀",
    "Strategy requires practice! Ready for more? 🎯",
    "Your highest score is calling! Beat it? 💥",
  ];

  /// Get random message for Flappy Bird game
  static String getFlappyBirdMessage() {
    return flappyBirdMessages[_random.nextInt(flappyBirdMessages.length)];
  }

  /// Get random message for Shooting Game
  static String getShootingGameMessage() {
    return shootingGameMessages[_random.nextInt(shootingGameMessages.length)];
  }

  /// Get random message for Fruit Ninja game
  static String getFruitNinjaMessage() {
    return fruitNinjaMessages[_random.nextInt(fruitNinjaMessages.length)];
  }

  /// Get random message for 2048 game
  static String get2048Message() {
    return game2048Messages[_random.nextInt(game2048Messages.length)];
  }

  /// Get random message for any game by game ID
  static String getMessageForGame(String gameId) {
    switch (gameId) {
      case 'flappy_bird':
        return getFlappyBirdMessage();
      case 'shooting_rush':
        return getShootingGameMessage();
      case 'fruit_ninja':
        return getFruitNinjaMessage();
      case 'game_2048':
        return get2048Message();
      default:
        return "Ready for another challenge? 🎮";
    }
  }
}

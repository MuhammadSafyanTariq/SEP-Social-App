import 'dart:ui';
import 'package:flame/components.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_game.dart';

class SoundButton {
  final FruitGame game;
  late Rect rect;
  late Sprite enabledSprite;
  late Sprite disabledSprite;
  bool isEnabled = true;

  SoundButton(this.game) {
    resize();
    enabledSprite = Sprite(game.images.fromCache('icon-sound-enabled.png'));
    disabledSprite = Sprite(game.images.fromCache('icon-sound-disabled.png'));
  }

  void render(Canvas c) {
    final sprite = isEnabled ? enabledSprite : disabledSprite;
    sprite.render(
      c,
      size: Vector2(rect.width, rect.height),
      position: Vector2(rect.left, rect.top),
    );
  }

  void resize() {
    rect = Rect.fromLTWH(
      game.tileSize * 1.5,
      game.tileSize * .25,
      game.tileSize,
      game.tileSize,
    );
  }

  void onTapDown() {
    isEnabled = !isEnabled;
  }
}

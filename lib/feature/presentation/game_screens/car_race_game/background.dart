import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';
import 'package:sep/feature/presentation/game_screens/car_race_game/car_race.dart';

class BackGround extends ParallaxComponent<CarRace> with HasGameRef<CarRace> {
  double backgroundSpeed = 2;

  @override
  FutureOr<void> onLoad() async {
    parallax = await gameRef.loadParallax(
      [
        ParallaxImageData('assets/car_race/images/game/road1.png'),
        ParallaxImageData('assets/car_race/images/game/road1.png'),
      ],
      fill: LayerFill.width,
      repeat: ImageRepeat.repeat,
      baseVelocity: Vector2(0, -70 * backgroundSpeed),
      velocityMultiplierDelta: Vector2(0, 1.2 * backgroundSpeed),
    );
  }
}

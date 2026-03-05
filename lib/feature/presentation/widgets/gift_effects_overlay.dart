import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/gift_images.dart';
import 'package:sep/utils/appUtils.dart';

// Map each gift code to an animation duration that matches
// the product spec (approximate mid‑point of the allowed range).
Duration _giftAnimationDuration(String code) {
  switch (code) {
    case 'Applause_Hands':
      // Spec: 2–3 seconds
      return const Duration(seconds: 2);
    case 'Ascending_Smiling_Face_Heart_Eyes':
      // Spec: 3–4 seconds
      return const Duration(seconds: 4);
    case 'Beating_Heart':
      // Spec: 4–6 seconds
      return const Duration(seconds: 3);
    case 'Blooming_Flowers':
      // Spec: 5–7 seconds
      return const Duration(seconds: 3);
    case 'Popping_Champagne':
      // Spec: 5–6 seconds
      return const Duration(seconds: 3);
    case 'Birthday_Cake':
      // Spec: 6–8 seconds
      return const Duration(seconds: 3);
    case 'Falling_Gold_Coins':
      // Spec: 6–8 seconds
      return const Duration(seconds: 3);
    case 'Floating_Cash':
      // Spec: 8–10 seconds
      return const Duration(seconds: 3);
    case 'Soaring_Eagle':
      // Spec: 8–10 seconds
      return const Duration(seconds: 3);
    case 'Verde_Mantis_Lamborghini':
      // Spec: 8–12 seconds
      return const Duration(seconds: 3);
    case 'Boeing_747_8_VIP_Jet':
      // Spec: 10–12 seconds
      return const Duration(seconds: 3);
    default:
      return const Duration(seconds: 3);
  }
}

/// Public API: show a beautiful full‑screen gift effect overlay.
void showGiftEffectOverlay(
  BuildContext context, {
  required String giftCode,
  String? giftLabel,
  String? senderName,
}) {
  final duration = _giftAnimationDuration(giftCode);

  final entry = OverlayEntry(
    builder: (_) => GiftEffectsOverlay(
      giftCode: giftCode,
      giftLabel: giftLabel,
      senderName: senderName,
      duration: duration,
    ),
  );

  Overlay.of(context).insert(entry);

  // Remove shortly after animation finishes.
  Future.delayed(duration + const Duration(milliseconds: 400), () {
    entry.remove();
  });
}

class GiftEffectsOverlay extends StatefulWidget {
  final String giftCode;
  final String? giftLabel;
  final String? senderName;
  final Duration duration;

  const GiftEffectsOverlay({
    super.key,
    required this.giftCode,
    this.giftLabel,
    this.senderName,
    required this.duration,
  });

  @override
  State<GiftEffectsOverlay> createState() => _GiftEffectsOverlayState();
}

class _GiftEffectsOverlayState extends State<GiftEffectsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  AudioPlayer? _sfxPlayer;
  AudioPlayer? _musicPlayer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stopAudio();
      }
    });
    _playGiftAudio();
  }

  @override
  void dispose() {
    _stopAudio();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final value = Curves.easeOut.transform(_controller.value);

          Widget effect;
          switch (widget.giftCode) {
            case 'Applause_Hands':
              effect = _ApplauseHandsEffect(progress: value);
              break;
            case 'Ascending_Smiling_Face_Heart_Eyes':
              effect = _HeartEyesEffect(progress: value);
              break;
            case 'Beating_Heart':
              effect = _BeatingHeartsEffect(progress: value);
              break;
            case 'Blooming_Flowers':
              effect = _BloomingFlowersEffect(progress: value);
              break;
            case 'Popping_Champagne':
              effect = _ChampagneEffect(progress: value);
              break;
            case 'Birthday_Cake':
              effect = _BirthdayCakeEffect(progress: value);
              break;
            case 'Falling_Gold_Coins':
              effect = _FallingCoinsEffect(progress: value);
              break;
            case 'Floating_Cash':
              effect = _FloatingCashEffect(progress: value);
              break;
            case 'Soaring_Eagle':
              effect = _SoaringEagleEffect(progress: value);
              break;
            case 'Verde_Mantis_Lamborghini':
              effect = _LamboEffect(progress: value);
              break;
            case 'Boeing_747_8_VIP_Jet':
              effect = _JetEffect(progress: value);
              break;
            default:
              effect = _GenericGlowEffect(
                progress: value,
                giftCode: widget.giftCode,
              );
          }

          final hasText = widget.giftLabel != null || widget.senderName != null;
          final textOpacity = (value < 0.15)
              ? (value / 0.15)
              : (value > 0.85)
              ? (1 - value) / 0.15
              : 1.0;

          return Stack(
            children: [
              effect,
              if (hasText)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: Opacity(
                    opacity: textOpacity.clamp(0.0, 1.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.yellow.withOpacity(0.8),
                            width: 1,
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            children: [
                              if (widget.senderName != null) ...[
                                TextSpan(
                                  text: widget.senderName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' sent '),
                              ],
                              TextSpan(
                                text: widget.giftLabel ?? widget.giftCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amberAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Play per‑gift SFX plus background music from 2s into the track.
  Future<void> _playGiftAudio() async {
    try {
      AppUtils.log('🔊 _playGiftAudio for giftCode=${widget.giftCode}');
      final sfxSource = _giftSfxSource(widget.giftCode);
      if (sfxSource != null) {
        // Gift has its own dedicated sound: play ONLY that.
        AppUtils.log('🔊 Playing SFX source: $sfxSource');
        final player = AudioPlayer();
        _sfxPlayer = player;
        await player.play(sfxSource);
      } else {
        // No dedicated sound: play shared music.mp3 starting at 2s.
        AppUtils.log(
          '🔊 No SFX for ${widget.giftCode}, playing music.mp3 from 2s',
        );
        final music = AudioPlayer();
        _musicPlayer = music;
        await music.play(
          AssetSource('audio/gift_audio/music.mp3'),
          position: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      AppUtils.log('💥 _playGiftAudio error for ${widget.giftCode}: $e');
    }
  }

  void _stopAudio() {
    _sfxPlayer?.stop();
    _sfxPlayer?.dispose();
    _sfxPlayer = null;
    _musicPlayer?.stop();
    _musicPlayer?.dispose();
    _musicPlayer = null;
  }
}

/// Map gift codes to their specific audio assets in assets/audio/gift_audio;
/// null means "use only music".
Source? _giftSfxSource(String code) {
  // With `- assets/audio/` in pubspec, logical paths start at `audio/...`.
  // These files live under assets/audio/gift_audio/.
  const base = 'audio/gift_audio/';

  switch (code) {
    case 'Applause_Hands':
      return AssetSource('${base}applause.mp3');
    case 'Ascending_Smiling_Face_Heart_Eyes':
      return AssetSource('${base}smilingface.wav');
    case 'Popping_Champagne':
      return AssetSource('${base}champagne.mp3');
    case 'Falling_Gold_Coins':
      return AssetSource('${base}coins.wav');
    case 'Soaring_Eagle':
      return AssetSource('${base}eagle.mp3');
    case 'Verde_Mantis_Lamborghini':
      return AssetSource('${base}lamborghini.wav');
    case 'Boeing_747_8_VIP_Jet':
      return AssetSource('${base}Jet.wav');
    default:
      // For gifts without their own SFX, rely on background music only.
      return null;
  }
}

class _ApplauseHandsEffect extends StatelessWidget {
  final double progress;

  const _ApplauseHandsEffect({required this.progress});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    // Two rows of applause hands filling the width, similar feel to heart eyes.
    final hands = <Widget>[];
    const countPerRow = 6;

    for (int row = 0; row < 2; row++) {
      for (int i = 0; i < countPerRow; i++) {
        final baseIndex = row * countPerRow + i;
        final stagger = baseIndex * 0.035;
        final t = (progress - stagger).clamp(0.0, 1.0);
        if (t <= 0) continue;

        final fraction = (i + 0.5) / countPerRow;
        final dx = screen.width * fraction;
        final dy = screen.height * (0.9 - t * (row == 0 ? 1.0 : 1.3));
        final opacity = (1 - t).clamp(0.0, 1.0);

        hands.add(
          Positioned(
            left: dx - 40,
            top: dy,
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: 1.1 + t * 0.5,
                child: Image.asset(
                  GiftImages.forCode('Applause_Hands'),
                  width: 110,
                  height: 110,
                ),
              ),
            ),
          ),
        );
      }
    }

    return Stack(
      children: [
        // Soft radial glow at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: -screen.height * 0.1,
          child: Opacity(
            opacity: (progress * 1.2).clamp(0.0, 0.9),
            child: Container(
              height: screen.height * 0.4,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 1),
                  radius: 1.2,
                  colors: [
                    AppColors.yellow.withOpacity(0.9),
                    AppColors.yellow.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        ...hands,
      ],
    );
  }
}

class _HeartEyesEffect extends StatelessWidget {
  final double progress;

  const _HeartEyesEffect({required this.progress});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final random = Random(2);

    final emojis = List.generate(18, (i) {
      final stagger = i * 0.03;
      final t = (progress - stagger).clamp(0.0, 1.0);
      if (t <= 0) return const SizedBox.shrink();

      final startX = screen.width * (0.1 + random.nextDouble() * 0.8);
      final dx = startX + sin(i + t * pi) * 24;
      final dy = screen.height * (1.1 - t * 1.4);
      final size = 26.0 + (i % 4) * 4 + t * 8;
      final opacity = (1 - t).clamp(0.0, 1.0);

      return Positioned(
        left: dx,
        top: dy,
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: 1.2 + t * 0.6,
            child: Image.asset(
              GiftImages.forCode('Ascending_Smiling_Face_Heart_Eyes'),
              width: size * 1.5,
              height: size * 1.5,
            ),
          ),
        ),
      );
    });

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.purple.withOpacity(0.25 * progress),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        ...emojis,
      ],
    );
  }
}

class _BeatingHeartsEffect extends StatelessWidget {
  final double progress;

  const _BeatingHeartsEffect({required this.progress});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    // Central big heart beat
    final beatScale = 0.9 + sin(progress * pi * 2) * 0.12;
    final beatOpacity = (progress < 0.1 || progress > 0.9)
        ? (progress < 0.1 ? progress * 10 : (1 - progress) * 10)
        : 1.0;

    final smallHearts = List.generate(10, (i) {
      final t = (progress - i * 0.04).clamp(0.0, 1.0);
      if (t <= 0) return const SizedBox.shrink();
      final angle = (i / 10) * 2 * pi;
      final radius = 40.0 + t * 80;
      final dx = screen.width / 2 + cos(angle) * radius;
      final dy = screen.height / 2 + sin(angle) * radius * 0.6;

      return Positioned(
        left: dx,
        top: dy,
        child: Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Image.asset(
            GiftImages.forCode('Beating_Heart'),
            width: 34,
            height: 34,
          ),
        ),
      );
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.red.withOpacity(0.35), Colors.transparent],
              ),
            ),
          ),
        ),
        ...smallHearts,
        Opacity(
          opacity: beatOpacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: beatScale,
            child: Image.asset(
              GiftImages.forCode('Beating_Heart'),
              width: 200,
              height: 200,
            ),
          ),
        ),
      ],
    );
  }
}

class _BloomingFlowersEffect extends StatelessWidget {
  final double progress;

  const _BloomingFlowersEffect({required this.progress});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    final groundHeight = screen.height * 0.35;

    final bloomScale = Curves.easeOutBack.transform(progress.clamp(0.0, 1.0));

    return Stack(
      children: [
        // Fantasy garden glow at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: groundHeight,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.green.shade700.withOpacity(0.9),
                  Colors.green.shade400.withOpacity(0.4 * progress),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Main bouquet in center
        Align(
          alignment: const Alignment(0, 0.4),
          child: Transform.scale(
            scale: bloomScale,
            child: Image.asset(
              GiftImages.forCode('Blooming_Flowers'),
              width: 230,
              height: 230,
            ),
          ),
        ),
        // Floating petals
        ...List.generate(10, (i) {
          final t = (progress - i * 0.04).clamp(0.0, 1.0);
          if (t <= 0) return const SizedBox.shrink();
          final dx =
              screen.width * (0.2 + (i / 10) * 0.6) + sin(i + t * 4) * 14;
          final dy = screen.height * (0.9 - t * 0.9);
          return Positioned(
            left: dx,
            top: dy,
            child: Opacity(
              opacity: (1 - t).clamp(0.0, 1.0),
              child: Icon(
                Icons.local_florist,
                color: Colors.pinkAccent.shade100,
                size: 18,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ChampagneEffect extends StatelessWidget {
  final double progress;

  const _ChampagneEffect({required this.progress});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    final boxOpacity = (progress < 0.4)
        ? Curves.easeOut.transform((progress / 0.4).clamp(0.0, 1.0))
        : (1 - (progress - 0.4) / 0.4).clamp(0.0, 1.0);

    final bottleRise = (progress - 0.25).clamp(0.0, 1.0);

    final balloons = List.generate(10, (i) {
      final t = (progress - 0.3 - i * 0.03).clamp(0.0, 1.0);
      if (t <= 0) return const SizedBox.shrink();
      final dx = screen.width * (0.2 + (i / 10) * 0.6);
      final dy = screen.height * (0.7 - t * 0.8);
      final color = i.isEven
          ? Colors.white70
          : Colors.amberAccent.withOpacity(0.9);
      return Positioned(
        left: dx,
        top: dy,
        child: Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Icon(Icons.circle, color: color, size: 18),
        ),
      );
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        // Gift box base
        Opacity(
          opacity: boxOpacity,
          child: Align(
            alignment: const Alignment(0, 0.6),
            child: Container(
              width: screen.width * 0.5,
              height: screen.height * 0.16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Champagne bottle rising
        if (bottleRise > 0)
          Positioned(
            bottom: screen.height * (0.18 + bottleRise * 0.35),
            child: Transform.scale(
              scale: 1.0 + bottleRise * 0.4,
              child: Image.asset(
                GiftImages.forCode('Popping_Champagne'),
                width: 200,
                height: 200,
              ),
            ),
          ),
        ...balloons,
      ],
    );
  }
}

class _BirthdayCakeEffect extends StatelessWidget {
  final double progress;

  const _BirthdayCakeEffect({required this.progress});

  @override
  Widget build(BuildContext context) {
    final rotation = (1 - progress) * pi * 1.2;
    final scale = 0.9 + Curves.easeOutBack.transform(progress) * 0.5;

    final flameOpacity = progress < 0.7
        ? 1.0
        : (1 - (progress - 0.7) / 0.3).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.orangeAccent.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotation,
            child: Image.asset(
              GiftImages.forCode('Birthday_Cake'),
              width: 230,
              height: 230,
            ),
          ),
        ),
        // Flames glow
        Positioned(
          top: MediaQuery.of(context).size.height * 0.35,
          child: Opacity(
            opacity: flameOpacity,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.yellow.withOpacity(0.8),
                    Colors.red.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FallingCoinsEffect extends StatelessWidget {
  final double progress;

  const _FallingCoinsEffect({required this.progress});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final random = Random(3);

    final coins = List.generate(22, (i) {
      final t = (progress - i * 0.02).clamp(0.0, 1.0);
      if (t <= 0) return const SizedBox.shrink();
      final dx = screen.width * (0.05 + random.nextDouble() * 0.9);
      final dy = screen.height * (-0.2 + t * 1.3);
      final opacity = (1 - t).clamp(0.0, 1.0);

      return Positioned(
        left: dx,
        top: dy,
        child: Opacity(
          opacity: opacity,
          child: Icon(
            Icons.circle,
            color: Colors.amberAccent.shade200,
            size: 18,
          ),
        ),
      );
    });

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blueGrey.shade900.withOpacity(0.9),
                  Colors.blueGrey.shade800.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        ...coins,
      ],
    );
  }
}

class _FloatingCashEffect extends StatelessWidget {
  final double progress;

  const _FloatingCashEffect({required this.progress});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    final bills = List.generate(22, (i) {
      final t = (progress - i * 0.03).clamp(0.0, 1.0);
      if (t <= 0) return const SizedBox.shrink();
      final dx = screen.width * (1.1 - t * 1.6) + sin(i + t * 5) * 26;
      final dy = screen.height * (0.05 + (i / 22) * 0.9);
      final opacity = (1 - t).clamp(0.0, 1.0);

      return Positioned(
        left: dx,
        top: dy,
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: sin(i + t * 7) * 0.5,
            child: Container(
              width: 52,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [Colors.greenAccent.shade100, Colors.green.shade700],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.teal.shade900.withOpacity(0.9),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Large central cash gift image near center
        Align(
          alignment: const Alignment(0.2, 0.15),
          child: Opacity(
            opacity: (progress * 1.2).clamp(0.0, 1.0),
            child: Image.asset(
              GiftImages.forCode('Floating_Cash'),
              width: 220,
              height: 220,
            ),
          ),
        ),
        ...bills,
      ],
    );
  }
}

class _SoaringEagleEffect extends StatelessWidget {
  final double progress;

  const _SoaringEagleEffect({required this.progress});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    final dx = -screen.width * 0.3 + progress * screen.width * 1.6;
    final dy = screen.height * (0.2 - sin(progress * pi) * 0.08);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade900, Colors.blue.shade500],
              ),
            ),
          ),
        ),
        Positioned(
          left: dx,
          top: dy,
          child: Transform.rotate(
            angle: -0.1 + sin(progress * pi) * 0.1,
            child: Image.asset(
              GiftImages.forCode('Soaring_Eagle'),
              width: 220,
              height: 220,
            ),
          ),
        ),
      ],
    );
  }
}

class _LamboEffect extends StatelessWidget {
  final double progress;

  const _LamboEffect({required this.progress});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    final dx = -screen.width * 0.6 + progress * screen.width * 1.6;
    final glowOpacity = Curves.easeInOut.transform(
      (progress * 1.2).clamp(0.0, 1.0),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade600],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: screen.height * 0.08,
          child: Opacity(
            opacity: glowOpacity,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.cyanAccent.withOpacity(0.7),
                    Colors.cyanAccent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: dx,
          bottom: screen.height * 0.08,
          child: Image.asset(
            GiftImages.forCode('Verde_Mantis_Lamborghini'),
            width: 320,
            height: 160,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class _JetEffect extends StatelessWidget {
  final double progress;

  const _JetEffect({required this.progress});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    // Jet horizontal path from right → left, vertically around center.
    final dx = screen.width * (1.2 - progress * 1.8);
    final dyBase = screen.height * 0.5;
    final dy = dyBase + sin(progress * pi) * screen.height * 0.05;

    // Parallax clouds drift slower than the jet
    final cloudOffset = progress * 0.6;

    return Stack(
      children: [
        // Night sky with subtle gradient
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo.shade900, Colors.indigo.shade500],
              ),
            ),
          ),
        ),
        // Stars
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _StarFieldPainter(opacity: 0.35)),
          ),
        ),
        // Soft horizon glow
        Positioned(
          left: 0,
          right: 0,
          bottom: -screen.height * 0.15,
          child: Container(
            height: screen.height * 0.45,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.4,
                colors: [
                  Colors.blueGrey.shade300.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Parallax clouds
        Positioned(
          left: -screen.width * 0.3 + screen.width * cloudOffset,
          top: screen.height * 0.2,
          child: _cloudStrip(width: screen.width * 0.8, height: 80),
        ),
        Positioned(
          right: -screen.width * 0.4 + screen.width * cloudOffset * 1.2,
          top: screen.height * 0.32,
          child: _cloudStrip(width: screen.width * 0.9, height: 70),
        ),
        // Jet exhaust trail, following jet path
        Positioned(
          left: dx - screen.width * 0.15,
          top: dy + 30,
          child: Opacity(
            opacity: (1 - progress).clamp(0.0, 0.9),
            child: Container(
              width: screen.width * 0.5,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withOpacity(0.8),
                    Colors.lightBlueAccent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Jet flying across center
        Positioned(
          left: dx,
          top: dy,
          child: Transform.rotate(
            angle: -0.12,
            child: Image.asset(
              GiftImages.forCode('Boeing_747_8_VIP_Jet'),
              width: 320,
              height: 160,
            ),
          ),
        ),
      ],
    );
  }
}

/// Simple painter for a soft star field in the jet sky.
class _StarFieldPainter extends CustomPainter {
  final double opacity;

  _StarFieldPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(7);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6 * opacity)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 60; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height * 0.7;
      final radius = 0.8 + rand.nextDouble() * 1.6;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

Widget _cloudStrip({required double width, required double height}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(height / 2),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.35),
          Colors.white.withOpacity(0.0),
        ],
      ),
    ),
  );
}

class _GenericGlowEffect extends StatelessWidget {
  final double progress;
  final String giftCode;

  const _GenericGlowEffect({required this.progress, required this.giftCode});

  @override
  Widget build(BuildContext context) {
    final scale = 0.8 + Curves.easeOutBack.transform(progress) * 0.4;
    final opacity = progress < 0.2
        ? progress / 0.2
        : (1 - progress).clamp(0.0, 1.0);

    return Center(
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(42),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 6,
                ),
              ],
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Image.asset(
              GiftImages.forCode(giftCode),
              width: 110,
              height: 110,
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

/// Simple enhancement settings used across posts, stories and live.
class EnhancementSettings {
  final double brightness; // -1.0 to 1.0
  final double contrast; // -1.0 to 1.0
  final double tint; // used as saturation boost 0‑1
  final double hue; // -1.0 to 1.0 (small shifts look best)
  final Color border;

  const EnhancementSettings({
    this.brightness = 0,
    this.contrast = 0,
    this.tint = 0,
    this.hue = 0,
    this.border = Colors.transparent,
  });

  static const EnhancementSettings none = EnhancementSettings();
}

/// A small collection of preset filters that can be reused in
/// post preview, story creation, and live streaming.
class EnhancementPresets {
  static const List<String> names = <String>[
    'Original',
    'White',
    'Beauty',
    'Brown Tint',
    'Cool',
    'Vivid',
  ];

  static String? assetForIndex(int index) {
    switch (index) {
      case 0:
        return 'assets/filter_images/original.png';
      case 1:
        return 'assets/filter_images/white.png';
      case 2:
        return 'assets/filter_images/beauty.png';
      case 3:
        return 'assets/filter_images/brown tint.png';
      case 4:
        return 'assets/filter_images/cool.png';
      case 5:
        return 'assets/filter_images/vivid.png';
      default:
        return null;
    }
  }

  static EnhancementSettings byIndex(int index) {
    switch (index) {
      case 1: // White – slightly brighter, neutral
        return const EnhancementSettings(
          brightness: 0.15,
          contrast: 0.05,
          tint: 0.0,
          hue: 0.0,
        );
      case 2: // Beauty – bright and warm
        return const EnhancementSettings(
          brightness: 0.25,
          contrast: 0.1,
          tint: 0.15,
          hue: 0.06,
        );
      case 3: // Brown tint – warm, slightly desaturated
        return const EnhancementSettings(
          brightness: 0.05,
          contrast: 0.05,
          tint: 0.1,
          hue: 0.1,
        );
      case 4: // Cool – bluish, slightly darker
        return const EnhancementSettings(
          brightness: -0.05,
          contrast: 0.08,
          tint: 0.12,
          hue: -0.08,
        );
      case 5: // Vivid – more contrast & saturation
        return const EnhancementSettings(
          brightness: 0.08,
          contrast: 0.18,
          tint: 0.25,
          hue: 0.0,
        );
      case 0:
      default:
        return EnhancementSettings.none;
    }
  }
}

/// Wraps any child (image, video, live preview) in a color filter
/// based on [EnhancementSettings].
class SepImageFilter extends StatelessWidget {
  final EnhancementSettings settings;
  final Widget child;

  const SepImageFilter({
    super.key,
    required this.settings,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final matrix = _buildColorMatrix(settings);

    Widget result = ColorFiltered(
      colorFilter: ColorFilter.matrix(matrix),
      child: child,
    );

    if (settings.border != Colors.transparent) {
      result = Container(
        decoration: BoxDecoration(
          border: Border.all(color: settings.border, width: 4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: result,
        ),
      );
    }

    return result;
  }
}

List<double> _buildColorMatrix(EnhancementSettings s) {
  // Clamp inputs to safe ranges
  final double brightness = s.brightness.clamp(-1.0, 1.0);
  final double contrast = s.contrast.clamp(-1.0, 1.0);
  final double saturation = (s.tint).clamp(0.0, 1.0);
  final double hue = s.hue.clamp(-1.0, 1.0);

  // Start with identity matrix
  List<double> m = _identity();

  // Apply brightness
  if (brightness != 0) {
    m = _concat(m, _brightnessMatrix(brightness));
  }

  // Apply contrast
  if (contrast != 0) {
    m = _concat(m, _contrastMatrix(contrast));
  }

  // Apply saturation (tint)
  if (saturation != 0) {
    m = _concat(m, _saturationMatrix(1.0 + saturation));
  }

  // Apply small hue rotation
  if (hue != 0) {
    m = _concat(m, _hueRotateMatrix(hue * pi)); // scale to radians
  }

  return m;
}

List<double> _identity() => <double>[
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
    ];

List<double> _brightnessMatrix(double value) {
  final v = value * 255.0;
  return <double>[
    1, 0, 0, 0, v,
    0, 1, 0, 0, v,
    0, 0, 1, 0, v,
    0, 0, 0, 1, 0,
  ];
}

List<double> _contrastMatrix(double value) {
  final c = 1.0 + value;
  final t = 128.0 * (1.0 - c);
  return <double>[
    c, 0, 0, 0, t,
    0, c, 0, 0, t,
    0, 0, c, 0, t,
    0, 0, 0, 1, 0,
  ];
}

List<double> _saturationMatrix(double s) {
  const double lumR = 0.2126;
  const double lumG = 0.7152;
  const double lumB = 0.0722;

  final double sr = (1 - s) * lumR;
  final double sg = (1 - s) * lumG;
  final double sb = (1 - s) * lumB;

  return <double>[
    sr + s, sg, sb, 0, 0,
    sr, sg + s, sb, 0, 0,
    sr, sg, sb + s, 0, 0,
    0, 0, 0, 1, 0,
  ];
}

List<double> _hueRotateMatrix(double radians) {
  final cosVal = cos(radians);
  final sinVal = sin(radians);
  const double lumR = 0.213;
  const double lumG = 0.715;
  const double lumB = 0.072;

  return <double>[
    lumR + cosVal * (1 - lumR) + sinVal * (-lumR),
    lumG + cosVal * (-lumG) + sinVal * (-lumG),
    lumB + cosVal * (-lumB) + sinVal * (1 - lumB),
    0,
    0,
    lumR + cosVal * (-lumR) + sinVal * 0.143,
    lumG + cosVal * (1 - lumG) + sinVal * 0.14,
    lumB + cosVal * (-lumB) + sinVal * -0.283,
    0,
    0,
    lumR + cosVal * (-lumR) + sinVal * (-(1 - lumR)),
    lumG + cosVal * (-lumG) + sinVal * lumG,
    lumB + cosVal * (1 - lumB) + sinVal * lumB,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];
}

List<double> _concat(List<double> a, List<double> b) {
  final List<double> out = List<double>.filled(20, 0);
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 5; j++) {
      out[i * 5 + j] = a[i * 5 + 0] * b[0 * 5 + j] +
          a[i * 5 + 1] * b[1 * 5 + j] +
          a[i * 5 + 2] * b[2 * 5 + j] +
          a[i * 5 + 3] * b[3 * 5 + j];
      if (j == 4) {
        out[i * 5 + j] += a[i * 5 + 4];
      }
    }
  }
  return out;
}


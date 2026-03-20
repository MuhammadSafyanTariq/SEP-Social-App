import 'dart:io';
import 'dart:math';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:sep/components/coreComponents/sep_image_filter.dart';

/// Exports a new video file by burning the selected preset into the pixels.
///
/// Important: this only applies at export time (publish), not during preview.
class VideoFilterExporter {
  VideoFilterExporter._();

  static Future<File?> applyPresetToVideo({
    required File inputFile,
    required int presetIndex,
  }) async {
    if (presetIndex == 0) return inputFile;

    final EnhancementSettings settings = EnhancementPresets.byIndex(presetIndex);

    // Preview uses Flutter ColorFilter.matrix with our own preset math.
    // To make export match preview, we build the same 4x5 matrix and apply it
    // using FFmpeg's colorchannelmixer filter.
    final matrix = _buildColorMatrix(settings);

    // Flutter applies last-column offsets in 0..255 space.
    // FFmpeg's colorchannelmixer does not support per-channel bias terms directly.
    // We approximate offset effect using an extra eq brightness term.
    final double rOff = matrix[4] / 255.0;
    final double gOff = matrix[9] / 255.0;
    final double bOff = matrix[14] / 255.0;
    final double avgBrightnessOffset = (rOff + gOff + bOff) / 3.0;

    String m(double v) => v.toStringAsFixed(6);

    final vf = [
      'format=rgb24',
      'colorchannelmixer='
          // R' = rr*R + rg*G + rb*B + ra*A + r
          'rr=${m(matrix[0])}:rg=${m(matrix[1])}:rb=${m(matrix[2])}:ra=0:'
          // G' = gr*R + gg*G + gb*B + ga*A + g
          'gr=${m(matrix[5])}:gg=${m(matrix[6])}:gb=${m(matrix[7])}:ga=0:'
          // B' = br*R + bg*G + bb*B + ba*A + b
          'br=${m(matrix[10])}:bg=${m(matrix[11])}:bb=${m(matrix[12])}:ba=0',
      // Keep a small brightness compensation so presets still feel close.
      'eq=brightness=${m(avgBrightnessOffset)}',
      'format=yuv420p',
    ].join(',');

    final String outputPath =
        '${inputFile.parent.path}${Platform.pathSeparator}sep_filtered_${presetIndex}_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final outputFile = File(outputPath);

    // -map 0:a? makes audio optional.
    final matrixCommand =
        '-y -i "${inputFile.path}" -vf "${vf}" -c:v libx264 -preset veryfast -crf 23 -map 0:v:0 -map 0:a? -c:a copy "${outputFile.path}"';

    final session = await FFmpegKit.execute(matrixCommand);
    final returnCode = await session.getReturnCode();

    final isSuccess = returnCode != null && ReturnCode.isSuccess(returnCode);
    if (isSuccess && outputFile.existsSync()) return outputFile;

    // Retry with a simpler filter chain for broader device compatibility.
    final fallbackOutputPath =
        '${inputFile.parent.path}${Platform.pathSeparator}sep_filtered_fallback_${presetIndex}_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final fallbackOutputFile = File(fallbackOutputPath);

    final double saturation = 1.0 + settings.tint;
    final double brightness = settings.brightness;
    final double contrast = 1.0 + settings.contrast;
    final double hueDegrees = settings.hue * 180.0;

    String clamp(double v, double min, double max) =>
        v.clamp(min, max).toStringAsFixed(6);

    final fallbackVf = [
      'eq='
          'brightness=${clamp(brightness, -1.0, 1.0)}:'
          'contrast=${clamp(contrast, 0.0, 4.0)}:'
          'saturation=${clamp(saturation, 0.0, 4.0)}',
      if (hueDegrees.abs() > 0.01) 'hue=h=${hueDegrees.toStringAsFixed(4)}',
      'format=yuv420p',
    ].join(',');

    final fallbackCommand =
        '-y -i "${inputFile.path}" -vf "${fallbackVf}" -c:v libx264 -preset veryfast -crf 23 -map 0:v:0 -map 0:a? -c:a copy "${fallbackOutputFile.path}"';

    final fallbackSession = await FFmpegKit.execute(fallbackCommand);
    final fallbackCode = await fallbackSession.getReturnCode();
    final fallbackSuccess =
        fallbackCode != null && ReturnCode.isSuccess(fallbackCode);

    if (fallbackSuccess && fallbackOutputFile.existsSync()) {
      return fallbackOutputFile;
    }

    return null;
  }

  // Replicate the same math as `SepImageFilter` so the baked filter matches preview.
  static List<double> _buildColorMatrix(EnhancementSettings s) {
    final double brightness = s.brightness.clamp(-1.0, 1.0);
    final double contrast = s.contrast.clamp(-1.0, 1.0);
    final double saturation = (s.tint).clamp(0.0, 1.0);
    final double hue = s.hue.clamp(-1.0, 1.0);

    List<double> m = _identity();

    if (brightness != 0) {
      m = _concat(m, _brightnessMatrix(brightness));
    }

    if (contrast != 0) {
      m = _concat(m, _contrastMatrix(contrast));
    }

    if (saturation != 0) {
      m = _concat(m, _saturationMatrix(1.0 + saturation));
    }

    if (hue != 0) {
      m = _concat(m, _hueRotateMatrix(hue * pi));
    }

    return m;
  }

  static List<double> _identity() => <double>[
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ];

  static List<double> _brightnessMatrix(double value) {
    final v = value * 255.0;
    return <double>[
      1,
      0,
      0,
      0,
      v,
      0,
      1,
      0,
      0,
      v,
      0,
      0,
      1,
      0,
      v,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  static List<double> _contrastMatrix(double value) {
    final c = 1.0 + value;
    final t = 128.0 * (1.0 - c);
    return <double>[
      c,
      0,
      0,
      0,
      t,
      0,
      c,
      0,
      0,
      t,
      0,
      0,
      c,
      0,
      t,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  static List<double> _saturationMatrix(double s) {
    const double lumR = 0.2126;
    const double lumG = 0.7152;
    const double lumB = 0.0722;

    final double sr = (1 - s) * lumR;
    final double sg = (1 - s) * lumG;
    final double sb = (1 - s) * lumB;

    return <double>[
      sr + s,
      sg,
      sb,
      0,
      0,
      sr,
      sg + s,
      sb,
      0,
      0,
      sr,
      sg,
      sb + s,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  static List<double> _hueRotateMatrix(double radians) {
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
      lumB + cosVal * (-lumB) + sinVal * lumB,
      0,
      0,
      0,
      0,
      0,
      0,
      1,
    ];
  }

  static List<double> _concat(List<double> a, List<double> b) {
    final List<double> out = List<double>.filled(20, 0);
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 5; j++) {
        out[i * 5 + j] =
            a[i * 5 + 0] * b[0 * 5 + j] +
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
}


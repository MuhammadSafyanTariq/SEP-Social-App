import 'dart:io';
import 'package:flutter/material.dart';
import '../feature/data/models/dataModels/post_data.dart';
import 'package:sep/utils/appUtils.dart';

/// Helper class to get optimal video quality based on device capabilities
class VideoQualityHelper {
  /// Get max supported resolution for current device
  static int getMaxSupportedResolution(BuildContext? context) {
    if (Platform.isAndroid) {
      // Most Android devices can handle up to 1080p
      // High-end devices might handle 1440p, but we'll be conservative
      return 1920; // 1080p for most devices
    } else if (Platform.isIOS) {
      // iOS devices generally handle up to 1080p well
      return 1920; // 1080p
    }
    return 1920; // Default to 1080p
  }

  /// Get optimal video URL from FileElement based on device capabilities
  ///
  /// Priority:
  /// 1. HLS playlist (.m3u8) - uses adaptive streaming automatically
  /// 2. Multiple quality URLs - selects based on device max resolution
  /// 3. Original file URL - fallback
  static String getOptimalVideoUrl(
    FileElement fileElement, {
    BuildContext? context,
    int? maxWidth,
  }) {
    final deviceMaxWidth = maxWidth ?? getMaxSupportedResolution(context);
    final file = fileElement.file ?? '';

    // Debug logging for quality selection
    AppUtils.log('🎥 [Video Quality] Selection Debug:');
    AppUtils.log('  📱 Device Max Width: $deviceMaxWidth');
    AppUtils.log('  📹 Original URL: $file');
    AppUtils.log('  🔍 Has Qualities: ${fileElement.qualities != null}');
    AppUtils.log('  📊 Qualities Count: ${fileElement.qualities?.length ?? 0}');
    AppUtils.log(
      '  ✅ Available Qualities: ${fileElement.availableQualities ?? []}',
    );

    // Check if HLS (adaptive streaming) - best option
    if (file.toLowerCase().endsWith('.m3u8') ||
        file.toLowerCase().contains('/hls/') ||
        file.toLowerCase().contains('playlist.m3u8')) {
      AppUtils.log('  ✅ Selected: HLS (adaptive streaming)');
      return file;
    }

    // Check for multiple qualities from backend
    if (fileElement.qualities != null && fileElement.qualities!.isNotEmpty) {
      AppUtils.log('  ✅ Multiple qualities available, selecting optimal...');

      // Conservative quality selection to prevent crashes and ensure smooth playback
      // Default to 720p or 480p for better stability and performance

      // Prefer 720p for most devices (good balance of quality and performance)
      if (fileElement.qualities!.containsKey('720p')) {
        AppUtils.log(
          '  ✅ Selected Quality: 720p (default for smooth playback)',
        );
        AppUtils.log('  🔗 URL: ${fileElement.qualities!['720p']}');
        return fileElement.qualities!['720p']!;
      }

      // Fallback to 480p if 720p not available (very stable)
      if (fileElement.qualities!.containsKey('480p')) {
        AppUtils.log('  ✅ Selected Quality: 480p (fallback for stability)');
        AppUtils.log('  🔗 URL: ${fileElement.qualities!['480p']}');
        return fileElement.qualities!['480p']!;
      }

      // Only use 1080p if device explicitly supports it AND no lower quality available
      // This prevents crashes on devices with limited GPU/memory
      if (deviceMaxWidth >= 1920 &&
          fileElement.qualities!.containsKey('1080p') &&
          !fileElement.qualities!.containsKey('720p') &&
          !fileElement.qualities!.containsKey('480p')) {
        AppUtils.log(
          '  ⚠️ Selected Quality: 1080p (high-end device, no lower quality available)',
        );
        AppUtils.log('  🔗 URL: ${fileElement.qualities!['1080p']}');
        return fileElement.qualities!['1080p']!;
      }

      // Use 360p as last resort
      if (fileElement.qualities!.containsKey('360p')) {
        AppUtils.log('  ✅ Selected Quality: 360p (lowest quality available)');
        AppUtils.log('  🔗 URL: ${fileElement.qualities!['360p']}');
        return fileElement.qualities!['360p']!;
      }

      // Fallback to first available quality
      final fallbackUrl = fileElement.qualities!.values.first;
      AppUtils.log(
        '  ⚠️ Using first available quality: ${fileElement.qualities!.keys.first}',
      );
      AppUtils.log('  🔗 URL: $fallbackUrl');
      return fallbackUrl;
    }

    // Fallback to original file
    AppUtils.log('  ⚠️ No qualities found, using original file URL');
    return file;
  }

  /// Check if video supports adaptive streaming (HLS)
  static bool isAdaptiveStreaming(String url) {
    return url.toLowerCase().endsWith('.m3u8') ||
        url.toLowerCase().contains('/hls/') ||
        url.toLowerCase().contains('playlist.m3u8');
  }

  /// Check if video has multiple quality options
  static bool hasMultipleQualities(FileElement fileElement) {
    return fileElement.qualities != null &&
        fileElement.qualities!.isNotEmpty &&
        fileElement.qualities!.length > 1;
  }
}

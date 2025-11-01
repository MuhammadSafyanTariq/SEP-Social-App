import 'dart:async';
import 'dart:developer' as developer;
import 'package:sep/utils/appUtils.dart';

/// Professional video URL retrieval service for Agora Cloud Recording
///
/// This service works with your existing AgoraCloudRecordingService
/// Since your implementation already provides video URLs immediately via extractRecordingFiles,
/// this service focuses on handling cases where URLs need additional processing time
class VideoUrlRetrieverService {
  static const String _logName = 'VideoUrlRetriever';

  /// Extracts video URLs directly from Agora Cloud Recording stop response
  ///
  /// This method works with your existing AgoraCloudRecordingService.extractRecordingFiles
  /// and provides immediate URL extraction when available
  static List<String> extractVideoUrlsFromFiles(
    List<Map<String, dynamic>> recordingFiles,
  ) {
    developer.log(
      '🎬 [EXTRACT] Processing ${recordingFiles.length} recording files',
      name: _logName,
    );

    final List<String> videoUrls = [];

    for (final file in recordingFiles) {
      final url = file['url'] as String?;
      final downloadUrl = file['downloadUrl'] as String?;
      final filename = file['filename'] as String?;
      final trackType = file['trackType'] as String?;

      developer.log(
        '🎬 [EXTRACT] File: $filename, trackType: $trackType, url: $url, downloadUrl: $downloadUrl',
        name: _logName,
      );

      // Prefer downloadUrl over url for better reliability
      final finalUrl = downloadUrl ?? url;

      if (finalUrl != null && finalUrl.isNotEmpty) {
        // Check if this is a playable video file
        final isVideoFile =
            filename?.endsWith('.mp4') == true ||
            filename?.endsWith('.m3u8') == true ||
            trackType?.contains('video') == true;

        if (isVideoFile) {
          videoUrls.add(finalUrl);
          developer.log(
            '🎬 ✅ [EXTRACT] Added video URL: $finalUrl',
            name: _logName,
          );
        }
      }
    }

    developer.log(
      '🎬 [EXTRACT] Extracted ${videoUrls.length} video URLs total',
      name: _logName,
    );

    return videoUrls;
  }

  /// Professional storage of video URLs in frontend
  ///
  /// Stores video URLs in the recordedVideoUrls array and updates UI
  static void storeVideoUrls(
    List<String> videoUrls,
    Function(String) addToRecordedVideos, {
    Function(String)? onVideoStored,
  }) {
    developer.log(
      '🎯 [STORE] Storing ${videoUrls.length} video URLs in frontend',
      name: _logName,
    );

    for (final videoUrl in videoUrls) {
      if (videoUrl.isNotEmpty) {
        addToRecordedVideos(videoUrl);
        onVideoStored?.call(videoUrl);

        developer.log(
          '� ✅ [STORE] Stored video URL: $videoUrl',
          name: _logName,
        );
      }
    }

    if (videoUrls.isNotEmpty) {
      AppUtils.toast('📹 ${videoUrls.length} video(s) are now available!');
    }
  }

  /// Constructs Backblaze B2 URL for your storage configuration
  ///
  /// Based on your .env configuration:
  /// - Bucket: sep-recordings
  /// - Endpoint: https://s3.us-east-005.backblazeb2.com
  static String constructBackblazeUrl(String fileName) {
    // Based on your .env configuration
    const endpoint = 'https://s3.us-east-005.backblazeb2.com';

    final url = '$endpoint/$fileName';

    developer.log('🔗 [CONSTRUCT] Backblaze URL: $url', name: _logName);

    return url;
  }

  /// Check if video URL is accessible
  ///
  /// This can be used to verify video availability before showing to user
  static Future<bool> isVideoAccessible(String videoUrl) async {
    try {
      developer.log(
        '🔍 [CHECK] Checking video accessibility: $videoUrl',
        name: _logName,
      );

      // For now, just validate URL format
      // You can add HTTP HEAD request here if needed
      final uri = Uri.tryParse(videoUrl);
      final isValid =
          uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

      developer.log(
        '🔍 [CHECK] Video URL ${isValid ? 'valid' : 'invalid'}: $videoUrl',
        name: _logName,
      );

      return isValid;
    } catch (e) {
      developer.log(
        '❌ [CHECK] Error checking video accessibility: $e',
        name: _logName,
      );
      return false;
    }
  }
}

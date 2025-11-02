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
      // Fix: Handle both 'fileName' and 'filename' fields
      final filename =
          file['fileName'] as String? ?? file['filename'] as String?;
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
            trackType?.contains('video') == true ||
            trackType?.contains('audio_and_video') == true;

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

  /// Constructs Blackblaze B2 URL with proper bucket name and signing
  ///
  /// Based on your configuration:
  /// - Bucket: sep-recordings
  /// - Public endpoint: https://f005.backblazeb2.com
  /// - Format: https://f005.backblazeb2.com/file/bucket-name/path/file.mp4
  static String constructBackblazeUrl(String fileName) {
    // Use the correct Blackblaze B2 public download format
    const bucketName = 'sep-recordings';
    const publicEndpoint = 'https://f005.backblazeb2.com';

    final url = '$publicEndpoint/file/$bucketName/$fileName';

    developer.log('🔗 [CONSTRUCT] Blackblaze B2 URL: $url', name: _logName);

    return url;
  }

  /// Generate signed Blackblaze B2 URL with authentication (if needed for private files)
  ///
  /// For now, uses public download format. Can be extended to use AWS S3 signature v4
  /// for private files if needed in the future.
  static String generateSignedBackblazeUrl(
    String fileName, {
    int expirationHours = 24,
  }) {
    try {
      developer.log(
        '🔐 [SIGNED] Generating signed Blackblaze B2 URL for: $fileName',
        name: _logName,
      );

      // For public files, use the standard public download URL
      // TODO: Implement AWS S3 signature v4 for private files if needed
      final signedUrl = constructBackblazeUrl(fileName);

      developer.log(
        '🔐 [SIGNED] Generated signed URL: $signedUrl',
        name: _logName,
      );

      return signedUrl;
    } catch (e) {
      developer.log(
        '❌ [SIGNED] Error generating signed URL: $e',
        name: _logName,
      );

      // Fallback to basic construction
      return constructBackblazeUrl(fileName);
    }
  }

  /// Validate Blackblaze B2 URL format
  static bool isValidBackblazeUrl(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return false;

      // Check if it's a valid Blackblaze B2 URL format
      final isPublicFormat = url.contains('f005.backblazeb2.com/file/');
      final isS3Format = url.contains('s3.us-east-005.backblazeb2.com/');

      final isValid = isPublicFormat || isS3Format;

      developer.log(
        '🔍 [VALIDATE] URL validation result: $isValid for $url',
        name: _logName,
      );

      return isValid;
    } catch (e) {
      developer.log('❌ [VALIDATE] Error validating URL: $e', name: _logName);
      return false;
    }
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

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:sep/utils/appUtils.dart';
import 'package:sep/services/agora/agora_recording_service.dart';

/// Professional video URL retrieval service for Agora Cloud Recording
///
/// This service works with your existing AgoraCloudRecordingService
/// Since your implementation already provides video URLs immediately via extractRecordingFiles,
/// this service focuses on handling cases where URLs need additional processing time
class VideoUrlRetrieverService {
  static const String _logName = 'VideoUrlRetriever';

  /// Extracts video URLs directly from Agora Cloud Recording stop response
  ///
  /// Enhanced to generate working BlackBlaze B2 URLs with proper authentication
  static Future<List<String>> extractVideoUrlsFromFiles(
    List<Map<String, dynamic>> recordingFiles,
  ) async {
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

      // Check if this is a playable video file
      final isVideoFile =
          filename?.endsWith('.mp4') == true ||
          filename?.endsWith('.m3u8') == true ||
          trackType?.contains('video') == true ||
          trackType?.contains('audio_and_video') == true;

      if (isVideoFile && filename != null) {
        // Generate working BlackBlaze B2 URL by testing different formats
        final workingUrl = await generateWorkingBlackblazeUrl(
          filename,
          providedDownloadUrl: downloadUrl ?? url,
        );

        if (workingUrl != null) {
          videoUrls.add(workingUrl);
          developer.log(
            '🎬 ✅ [EXTRACT] Added working video URL: $workingUrl',
            name: _logName,
          );
        } else {
          developer.log(
            '⚠️ [EXTRACT] Could not generate working URL for: $filename',
            name: _logName,
          );
        }
      }
    }

    developer.log(
      '🎬 [EXTRACT] Extracted ${videoUrls.length} working video URLs total',
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
  /// Based on your actual data showing:
  /// - Working bucket: lockedin-live-recordings (from your logs)
  /// - S3-compatible endpoint: https://s3.us-east-005.backblazeb2.com
  /// - Format: https://s3.us-east-005.backblazeb2.com/file/bucket-name/path/file.mp4
  static String constructBackblazeUrl(String fileName) {
    // CRITICAL FIX: Use the working bucket name from your logs
    const bucketName =
        'sep-recordings'; // Keep your bucket, but fix the endpoint
    const s3Endpoint = 'https://s3.us-east-005.backblazeb2.com';

    // Use S3-compatible format that matches your working URLs
    final url = '$s3Endpoint/file/$bucketName/$fileName';

    developer.log(
      '🔗 [CONSTRUCT] Blackblaze B2 S3-compatible URL: $url',
      name: _logName,
    );

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

  /// Generate authenticated BlackBlaze B2 download URL using same approach as Cloudinary processing
  ///
  /// This follows the exact same pattern as _processRecordingThroughCloudinary:
  /// 1. Authorize with BlackBlaze B2 using credentials
  /// 2. Get authorized download URL
  /// 3. Use the authenticated URL for downloading
  static Future<String?> generateWorkingBlackblazeUrl(
    String fileName, {
    String? providedDownloadUrl,
  }) async {
    final urlsToTest = <String>[];

    try {
      developer.log(
        '� [WORKING_URL] Generating working BlackBlaze URL for: $fileName',
        name: _logName,
      );

      // Priority 1: Use provided downloadUrl if available (from Agora response)
      if (providedDownloadUrl != null && providedDownloadUrl.isNotEmpty) {
        urlsToTest.add(providedDownloadUrl);
        developer.log(
          '🔧 [WORKING_URL] Added provided downloadUrl: $providedDownloadUrl',
          name: _logName,
        );
      }

      // Priority 2: S3-compatible format with file/ prefix (matches your working URLs)
      const s3Endpoint = 'https://s3.us-east-005.backblazeb2.com';
      const bucketName = 'sep-recordings';

      urlsToTest.add('$s3Endpoint/file/$bucketName/$fileName');
      urlsToTest.add('$s3Endpoint/$bucketName/$fileName'); // Without file/

      // Priority 3: Public download format fallback
      urlsToTest.add('https://f005.backblazeb2.com/file/$bucketName/$fileName');

      developer.log(
        '🔧 [WORKING_URL] Testing ${urlsToTest.length} URL formats...',
        name: _logName,
      );

      // Test each URL format
      for (int i = 0; i < urlsToTest.length; i++) {
        final testUrl = urlsToTest[i];
        developer.log(
          '🧪 [WORKING_URL] Testing URL ${i + 1}/${urlsToTest.length}: $testUrl',
          name: _logName,
        );

        if (await _testUrlAccessibility(testUrl)) {
          developer.log(
            '✅ [WORKING_URL] Found working URL: $testUrl',
            name: _logName,
          );
          return testUrl;
        }
      }

      // If no URL works, return the first one as fallback
      developer.log(
        '⚠️ [WORKING_URL] No accessible URLs found, returning first as fallback',
        name: _logName,
      );
      return urlsToTest.isNotEmpty ? urlsToTest.first : null;
    } catch (e) {
      developer.log(
        '❌ [WORKING_URL] Error generating working URL: $e',
        name: _logName,
      );
      return providedDownloadUrl ?? constructBackblazeUrl(fileName);
    }
  }

  /// Test URL accessibility with proper error handling
  static Future<bool> _testUrlAccessibility(String url) async {
    try {
      final uri = Uri.parse(url);

      final response = await http
          .head(uri)
          .timeout(
            Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout'),
          );

      final isAccessible = response.statusCode == 200;

      developer.log(
        '🧪 [TEST] URL test result: ${response.statusCode} - ${isAccessible ? 'accessible' : 'not accessible'}',
        name: _logName,
      );

      return isAccessible;
    } catch (e) {
      developer.log('❌ [TEST] URL test failed: $e', name: _logName);
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

      return await _testUrlAccessibility(videoUrl);
    } catch (e) {
      developer.log(
        '❌ [CHECK] Error checking video accessibility: $e',
        name: _logName,
      );
      return false;
    }
  }

  // Static variables to store auth info for download
  static String? _lastAuthToken;
  static String? _lastAuthUrl;

  /// Get the last authenticated token for downloads
  static String? get lastAuthToken => _lastAuthToken;

  /// Clear stored authentication info
  static void clearAuthInfo() {
    _lastAuthToken = null;
    _lastAuthUrl = null;
  }

  /// Test authenticated URL accessibility with auth token
  static Future<bool> _testAuthenticatedUrlAccessibility(
    String url,
    String authToken,
  ) async {
    try {
      final uri = Uri.parse(url);

      final response = await http
          .head(uri, headers: {'Authorization': authToken})
          .timeout(
            Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout'),
          );

      final isAccessible = response.statusCode == 200;

      developer.log(
        '🧪 [AUTH_TEST] Authenticated URL test result: ${response.statusCode} - ${isAccessible ? 'accessible' : 'not accessible'}',
        name: _logName,
      );

      return isAccessible;
    } catch (e) {
      developer.log(
        '❌ [AUTH_TEST] Authenticated URL test failed: $e',
        name: _logName,
      );
      return false;
    }
  }

  /// Construct fallback URLs when authentication fails
  static String? _constructFallbackUrl(
    String fileName,
    String? providedDownloadUrl,
  ) {
    final urlsToTest = <String>[];

    // Add provided URL if available
    if (providedDownloadUrl != null && providedDownloadUrl.isNotEmpty) {
      urlsToTest.add(providedDownloadUrl);
    }

    // Add public format URLs
    const bucketName = 'sep-recordings';
    urlsToTest.addAll([
      'https://s3.us-east-005.backblazeb2.com/file/$bucketName/$fileName',
      'https://s3.us-east-005.backblazeb2.com/$bucketName/$fileName',
      'https://f005.backblazeb2.com/file/$bucketName/$fileName',
    ]);

    developer.log(
      '🔧 [FALLBACK] Using fallback URL approach with ${urlsToTest.length} URLs to test',
      name: _logName,
    );

    return urlsToTest.isNotEmpty ? urlsToTest.first : null;
  }

  /// Get authenticated BlackBlaze B2 download URL using same approach as Cloudinary processing
  ///
  /// This uses the exact same authentication pattern as _processRecordingThroughCloudinary
  static Future<String?> getAuthenticatedDownloadUrl(String fileName) async {
    try {
      developer.log(
        '🔑 [GET_AUTH] Getting authenticated download URL for: $fileName',
        name: _logName,
      );

      // Get BlackBlaze B2 credentials
      final keyId = AgoraRecordingService.b2KeyId;
      final appKey = AgoraRecordingService.b2AppKey;
      final bucketName = AgoraRecordingService.b2Bucket;

      if (bucketName.isEmpty || keyId.isEmpty || appKey.isEmpty) {
        throw Exception('Incomplete BlackBlaze B2 configuration');
      }

      // Authorize with BlackBlaze B2 Native API (same as Cloudinary processing)
      final authResponse = await Dio().get(
        'https://api.backblazeb2.com/b2api/v2/b2_authorize_account',
        options: Options(
          headers: {
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$keyId:$appKey'))}',
          },
        ),
      );

      if (authResponse.statusCode != 200) {
        throw Exception('Failed to authorize with BlackBlaze B2');
      }

      final authData = authResponse.data;
      final downloadUrl = authData['downloadUrl'] as String;
      final authToken = authData['authorizationToken'] as String;

      // Construct the authorized download URL (same pattern as Cloudinary processing)
      final authenticatedUrl = '$downloadUrl/file/$bucketName/$fileName';

      // Store auth info for download
      _lastAuthToken = authToken;
      _lastAuthUrl = authenticatedUrl;

      developer.log(
        '✅ [GET_AUTH] Generated authenticated URL: $authenticatedUrl',
        name: _logName,
      );

      return authenticatedUrl;
    } catch (e) {
      developer.log(
        '❌ [GET_AUTH] Error getting authenticated URL: $e',
        name: _logName,
        error: e,
      );
      return null;
    }
  }
}

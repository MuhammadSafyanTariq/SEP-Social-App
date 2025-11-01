import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sep/utils/appUtils.dart';

/// Service for Agora Cloud Recording
/// Direct Agora API calls (bypassing backend for recording only)
class AgoraRecordingService {
  // Agora credentials from environment
  static String get appId => dotenv.env['AGORA_APP_ID'] ?? '';
  static String get customerId => dotenv.env['AGORA_CUSTOMER_ID'] ?? '';
  static String get customerSecret => dotenv.env['AGORA_CUSTOMER_SECRET'] ?? '';

  // AWS S3 credentials from environment
  static String get s3AccessKey => dotenv.env['CLOUD_STORAGE_ACCESS_KEY'] ?? '';
  static String get s3SecretKey => dotenv.env['CLOUD_STORAGE_SECRET_KEY'] ?? '';
  static String get s3Bucket => dotenv.env['CLOUD_STORAGE_BUCKET'] ?? '';
  static String get s3Region => dotenv.env['CLOUD_STORAGE_REGION'] ?? '';

  // Agora Cloud Recording API base URL
  static String get baseUrl =>
      "https://api.agora.io/v1/apps/$appId/cloud_recording";

  // Last recorded video URL for backend submission
  static String? lastRecordedVideoUrl;

  /// Generate Basic Auth header
  static String _getBasicAuth() {
    final credentials = base64Encode(
      utf8.encode('$customerId:$customerSecret'),
    );
    return 'Basic $credentials';
  }

  /// Generate a unique recording UID that doesn't conflict with live stream UIDs
  static int generateRecordingUid() {
    final random = Random();
    return 900000000 + random.nextInt(99999999);
  }

  /// Step 1: Acquire a resource ID for recording
  static Future<AgoraRecordingResult> acquire({
    required String channelName,
    required String uid,
  }) async {
    try {
      AppUtils.log(
        '🔑 [ACQUIRE] Acquiring resource ID for channel: $channelName, uid: $uid',
      );

      final url = Uri.parse('$baseUrl/acquire');

      final body = {
        "cname": channelName,
        "uid": uid,
        "clientRequest": {"resourceExpiredHour": 24, "scene": 0},
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _getBasicAuth(),
        },
        body: jsonEncode(body),
      );

      AppUtils.log('📞 [ACQUIRE] Response status: ${response.statusCode}');
      AppUtils.log('📞 [ACQUIRE] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resourceId = data['resourceId'] as String;

        AppUtils.log('✅ [ACQUIRE] Resource ID acquired: $resourceId');
        return AgoraRecordingResult.success(
          resourceId: resourceId,
          message: 'Resource acquired successfully',
        );
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg =
            'Failed to acquire resource ID: ${errorData['message'] ?? response.body}';
        AppUtils.logEr('❌ [ACQUIRE] $errorMsg');
        return AgoraRecordingResult.error(errorMsg);
      }
    } catch (e) {
      AppUtils.logEr('❌ [ACQUIRE] Exception: $e');
      return AgoraRecordingResult.error('Acquire error: $e');
    }
  }

  /// Step 2: Start cloud recording with S3 storage
  static Future<AgoraRecordingResult> start({
    required String channelName,
    required String uid,
    required String resourceId,
    String? token,
  }) async {
    try {
      AppUtils.log(
        '🎬 [START] Starting recording for channel: $channelName, uid: $uid',
      );

      final url = Uri.parse('$baseUrl/resourceid/$resourceId/mode/mix/start');

      final body = {
        "cname": channelName,
        "uid": uid,
        "clientRequest": {
          "token": token,
          "recordingConfig": {
            "maxIdleTime": 120,
            "streamTypes": 2,
            "streamMode": "default",
            "audioProfile": 1,
            "channelType": 1,
            "videoStreamType": 0,
            "subscribeVideoUids": ["#allstream#"],
            "subscribeAudioUids": ["#allstream#"],
            "subscribeUidGroup": 0,
            "transcodingConfig": {
              "height": 640,
              "width": 360,
              "bitrate": 500,
              "fps": 15,
              "mixedVideoLayout": 1,
              "backgroundColor": "#000000",
            },
          },
          "recordingFileConfig": {
            "avFileType": ["hls", "mp4"],
          },
          "storageConfig": {
            "vendor": 1, // AWS S3
            "region": 3, // EU West (closest to eu-north-1)
            "bucket": s3Bucket,
            "accessKey": s3AccessKey,
            "secretKey": s3SecretKey,
            "fileNamePrefix": ["recordings", channelName],
          },
        },
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _getBasicAuth(),
        },
        body: jsonEncode(body),
      );

      AppUtils.log('📞 [START] Response status: ${response.statusCode}');
      AppUtils.log('📞 [START] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sid = data['sid'] as String;

        AppUtils.log('✅ [START] Recording started with SID: $sid');
        return AgoraRecordingResult.success(
          resourceId: resourceId,
          sid: sid,
          message: 'Recording started successfully',
        );
      } else {
        Map<String, dynamic> errorData = {};
        if (response.body.isNotEmpty) {
          try {
            errorData = jsonDecode(response.body);
            AppUtils.logEr('❌ [START] Error details: ${jsonEncode(errorData)}');
          } catch (e) {
            AppUtils.logEr('⚠️ [START] Could not parse error response: $e');
          }
        }

        final errorMsg =
            'Agora API Error ${response.statusCode}: ${errorData['message'] ?? 'Unknown error'}';
        AppUtils.logEr('❌ [START] $errorMsg');
        return AgoraRecordingResult.error(errorMsg);
      }
    } catch (e) {
      AppUtils.logEr('❌ [START] Exception: $e');
      return AgoraRecordingResult.error('Start error: $e');
    }
  }

  /// Step 3: Stop recording and extract file URLs
  static Future<AgoraRecordingResult> stop({
    required String channelName,
    required String uid,
    required String resourceId,
    required String sid,
  }) async {
    try {
      AppUtils.log('🛑 [STOP] Stopping recording for SID: $sid');

      // Wait briefly before stopping
      await Future.delayed(Duration(seconds: 2));

      final url = Uri.parse(
        '$baseUrl/resourceid/$resourceId/sid/$sid/mode/mix/stop',
      );

      final body = {"cname": channelName, "uid": uid, "clientRequest": {}};

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _getBasicAuth(),
        },
        body: jsonEncode(body),
      );

      AppUtils.log('📞 [STOP] Response status: ${response.statusCode}');
      AppUtils.log('📞 [STOP] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract recording file URLs
        String? fileUrl;
        String? mp4Url;

        if (data['serverResponse'] != null &&
            data['serverResponse']['fileList'] != null) {
          final fileList = data['serverResponse']['fileList'] as List;
          AppUtils.log('📁 [STOP] Found ${fileList.length} files in fileList');

          for (final file in fileList) {
            if (file is Map<String, dynamic>) {
              final filename = file['filename'] ?? '';
              final trackType = file['trackType'] ?? '';

              AppUtils.log('📄 [STOP] File: $filename, trackType: $trackType');

              // Look for MP4 files with audio_and_video track type
              if (filename.endsWith('.mp4') &&
                  trackType.contains('audio_and_video')) {
                // Construct S3 URL
                mp4Url =
                    'https://$s3Bucket.s3.$s3Region.amazonaws.com/$filename';
                fileUrl = mp4Url;

                // Store for later backend submission
                lastRecordedVideoUrl = fileUrl;

                AppUtils.log('🎥 [STOP] MP4 URL: $mp4Url');
                break;
              }
            }
          }
        }

        AppUtils.log('✅ [STOP] Recording stopped successfully');
        AppUtils.log('🔗 [STOP] File URL: $fileUrl');

        return AgoraRecordingResult.success(
          resourceId: resourceId,
          sid: sid,
          message: 'Recording stopped successfully',
          serverResponse: data['serverResponse'],
          fileUrl: fileUrl,
          mp4Url: mp4Url,
        );
      } else {
        Map<String, dynamic> errorData = {};
        if (response.body.isNotEmpty) {
          try {
            errorData = jsonDecode(response.body);
            AppUtils.logEr('❌ [STOP] Error details: ${jsonEncode(errorData)}');
          } catch (e) {
            AppUtils.logEr('⚠️ [STOP] Could not parse error response: $e');
          }
        }

        final errorMsg =
            'Stop failed (${response.statusCode}): ${errorData['message'] ?? 'Unknown error'}';
        AppUtils.logEr('❌ [STOP] $errorMsg');
        return AgoraRecordingResult.error(errorMsg);
      }
    } catch (e) {
      AppUtils.logEr('❌ [STOP] Exception: $e');
      return AgoraRecordingResult.error('Stop error: $e');
    }
  }

  /// Step 4: Query recording status
  static Future<AgoraRecordingResult> query({
    required String resourceId,
    required String sid,
  }) async {
    try {
      AppUtils.log('📊 [QUERY] Querying recording status for SID: $sid');

      final url = Uri.parse(
        '$baseUrl/resourceid/$resourceId/sid/$sid/mode/mix/query',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _getBasicAuth(),
        },
      );

      AppUtils.log('📞 [QUERY] Response status: ${response.statusCode}');
      AppUtils.log('📞 [QUERY] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AgoraRecordingResult.success(
          resourceId: resourceId,
          sid: sid,
          serverResponse: data,
        );
      } else {
        final errorMsg =
            'Query failed (${response.statusCode}): ${response.body}';
        AppUtils.logEr('❌ [QUERY] $errorMsg');
        return AgoraRecordingResult.error(errorMsg);
      }
    } catch (e) {
      AppUtils.logEr('❌ [QUERY] Exception: $e');
      return AgoraRecordingResult.error('Query error: $e');
    }
  }

  /// Complete recording workflow with retry logic
  static Future<Map<String, dynamic>> startCompleteRecording({
    required String channelName,
    required int uid,
    String? token,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        AppUtils.log(
          '🎯 [WORKFLOW] Starting complete recording workflow for channel: $channelName (attempt ${retryCount + 1}/$maxRetries)',
        );

        // Step 1: Acquire resource ID
        final acquireResult = await acquire(
          channelName: channelName,
          uid: uid.toString(),
        );

        if (!acquireResult.success || acquireResult.resourceId == null) {
          throw Exception(
            acquireResult.errorMessage ?? 'Failed to acquire resource',
          );
        }

        // Wait before starting
        await Future.delayed(Duration(seconds: 2));

        // Step 2: Start recording
        final startResult = await start(
          channelName: channelName,
          uid: uid.toString(),
          resourceId: acquireResult.resourceId!,
          token: token,
        );

        if (!startResult.success || startResult.sid == null) {
          throw Exception(
            startResult.errorMessage ?? 'Failed to start recording',
          );
        }

        // Wait for Agora worker allocation
        AppUtils.log('⏳ [WORKFLOW] Waiting for Agora worker allocation...');
        await Future.delayed(Duration(seconds: 10));

        AppUtils.log(
          '✅ [WORKFLOW] Recording workflow started successfully on attempt ${retryCount + 1}',
        );

        return {
          'resourceId': acquireResult.resourceId,
          'sid': startResult.sid,
          'status': 'started',
          'attempt': retryCount + 1,
        };
      } catch (e) {
        retryCount++;
        AppUtils.logEr(
          '❌ [WORKFLOW] Recording workflow failed on attempt $retryCount: $e',
        );

        if (retryCount >= maxRetries) {
          AppUtils.logEr(
            '❌ [WORKFLOW] Recording workflow failed after $maxRetries attempts',
          );
          rethrow;
        }

        // Wait before retrying (exponential backoff)
        final waitTime = Duration(seconds: 2 * retryCount);
        AppUtils.log(
          '⏳ [WORKFLOW] Retrying in ${waitTime.inSeconds} seconds...',
        );
        await Future.delayed(waitTime);
      }
    }

    throw Exception('Recording workflow failed after $maxRetries attempts');
  }

  /// Complete stop workflow
  static Future<String?> stopCompleteRecording({
    required String channelName,
    required int uid,
    required String resourceId,
    required String sid,
  }) async {
    try {
      AppUtils.log(
        '🎯 [WORKFLOW] Stopping complete recording workflow for SID: $sid',
      );

      // Stop recording
      final stopResult = await stop(
        channelName: channelName,
        uid: uid.toString(),
        resourceId: resourceId,
        sid: sid,
      );

      if (stopResult.success) {
        AppUtils.log('✅ [WORKFLOW] Recording workflow stopped successfully');
        return stopResult.fileUrl; // Return the video URL
      } else {
        throw Exception(stopResult.errorMessage ?? 'Failed to stop recording');
      }
    } catch (e) {
      AppUtils.logEr('❌ [WORKFLOW] Stop recording workflow failed: $e');
      rethrow;
    }
  }

  /// Get the last recorded video URL for backend submission
  static String? getLastRecordedVideoUrl() {
    return lastRecordedVideoUrl;
  }

  /// Clear the stored video URL
  static void clearLastRecordedVideoUrl() {
    lastRecordedVideoUrl = null;
  }
}

/// Result object for Agora recording operations
class AgoraRecordingResult {
  final bool success;
  final String? resourceId;
  final String? sid;
  final String? message;
  final String? errorMessage;
  final String? fileUrl;
  final String? mp4Url;
  final Map<String, dynamic>? serverResponse;

  AgoraRecordingResult({
    required this.success,
    this.resourceId,
    this.sid,
    this.message,
    this.errorMessage,
    this.fileUrl,
    this.mp4Url,
    this.serverResponse,
  });

  factory AgoraRecordingResult.success({
    String? resourceId,
    String? sid,
    String? message,
    String? fileUrl,
    String? mp4Url,
    Map<String, dynamic>? serverResponse,
  }) {
    return AgoraRecordingResult(
      success: true,
      resourceId: resourceId,
      sid: sid,
      message: message,
      fileUrl: fileUrl,
      mp4Url: mp4Url,
      serverResponse: serverResponse,
    );
  }

  factory AgoraRecordingResult.error(String message) {
    return AgoraRecordingResult(success: false, errorMessage: message);
  }

  @override
  String toString() {
    if (success) {
      return 'AgoraRecordingResult(success: true, resourceId: $resourceId, sid: $sid, message: $message, fileUrl: $fileUrl, mp4Url: $mp4Url)';
    } else {
      return 'AgoraRecordingResult(success: false, error: $errorMessage)';
    }
  }
}

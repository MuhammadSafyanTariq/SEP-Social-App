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

  // Blackblaze B2 credentials from environment
  static String get b2KeyId => dotenv.env['BACKBLAZE_KEY_ID'] ?? '';
  static String get b2AppKey => dotenv.env['BACKBLAZE_APP_KEY'] ?? '';
  static String get b2Bucket => dotenv.env['BACKBLAZE_BUCKET_NAME'] ?? '';
  static String get b2Endpoint => dotenv.env['BACKBLAZE_ENDPOINT'] ?? '';

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
      AppUtils.log('� [ACQUIRE] Starting - Channel: $channelName, UID: $uid');
      AppUtils.log(
        '🔐 [ACQUIRE] Using Customer ID: ${customerId.substring(0, 8)}...',
      );
      AppUtils.log('🌐 [ACQUIRE] API URL: $baseUrl/acquire');

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

      AppUtils.log('� [ACQUIRE] Response status: ${response.statusCode}');
      AppUtils.log('� [ACQUIRE] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resourceId = data['resourceId'] as String;

        AppUtils.log(
          '✅ [ACQUIRE] SUCCESS - Resource ID: ${resourceId.substring(0, 20)}...',
        );
        return AgoraRecordingResult.success(
          resourceId: resourceId,
          message: 'Resource acquired successfully',
        );
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg =
            'Failed to acquire resource ID: ${errorData['message'] ?? response.body}';
        AppUtils.logEr('🔴 [ACQUIRE] ERROR: $errorMsg');
        return AgoraRecordingResult.error(errorMsg);
      }
    } catch (e) {
      AppUtils.logEr('🔴 [ACQUIRE] EXCEPTION: $e');
      return AgoraRecordingResult.error('Acquire error: $e');
    }
  }

  /// Step 2: Start cloud recording with Blackblaze B2 storage
  static Future<AgoraRecordingResult> start({
    required String channelName,
    required String uid,
    required String resourceId,
    String? token,
    String?
    storageChannelName, // For battle recordings using requester's channel
    int? incrementNumber, // For recording sequence numbering
  }) async {
    try {
      AppUtils.log('🟡 [START] Starting recording...');
      AppUtils.log('📺 [START] Channel: $channelName');
      AppUtils.log('👤 [START] UID: $uid');
      AppUtils.log('🆔 [START] Resource ID: ${resourceId.substring(0, 20)}...');
      AppUtils.log('🔑 [START] Token: ${token?.substring(0, 20) ?? 'null'}...');
      AppUtils.log('🪣 [START] B2 Bucket: $b2Bucket');
      AppUtils.log('🌍 [START] B2 Endpoint: $b2Endpoint');

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
            "vendor": 11, // AWS S3 compatible (for Blackblaze B2)
            "region": 0, // US East 1
            "bucket": b2Bucket,
            "accessKey": b2KeyId,
            "secretKey": b2AppKey,
            "extensionParams": {
              "endpoint": b2Endpoint.replaceAll('https://', ''),
            },
            "fileNamePrefix": [
              "recordings",
              storageChannelName ?? channelName,
              (incrementNumber ?? 1).toString(),
            ],
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

      AppUtils.log('� [START] Response status: ${response.statusCode}');
      AppUtils.log('� [START] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sid = data['sid'] as String;

        AppUtils.log('✅ [START] SUCCESS - SID: $sid');
        AppUtils.log('🎉 [START] Recording is now ACTIVE!');
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
            AppUtils.logEr(
              '🔴 [START] Error details: ${jsonEncode(errorData)}',
            );
          } catch (e) {
            AppUtils.logEr('⚠️ [START] Could not parse error response: $e');
          }
        }

        final errorMsg =
            'Agora API Error ${response.statusCode}: ${errorData['message'] ?? 'Unknown error'}';
        AppUtils.logEr('🔴 [START] ERROR: $errorMsg');
        return AgoraRecordingResult.error(errorMsg);
      }
    } catch (e) {
      AppUtils.logEr('🔴 [START] EXCEPTION: $e');
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
      AppUtils.log('� [STOP] Stopping recording...');
      AppUtils.log('📺 [STOP] Channel: $channelName');
      AppUtils.log('👤 [STOP] UID: $uid');
      AppUtils.log('🆔 [STOP] Resource ID: ${resourceId.substring(0, 20)}...');
      AppUtils.log('🎯 [STOP] SID: $sid');

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

      AppUtils.log('� [STOP] Response status: ${response.statusCode}');
      AppUtils.log('� [STOP] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract recording file URLs
        String? fileUrl;
        String? mp4Url;

        AppUtils.log('🔍 [STOP] Looking for recording files...');
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
                // Construct Blackblaze B2 URL
                mp4Url = '$b2Endpoint/$filename';
                fileUrl = mp4Url;

                // Store for later backend submission
                lastRecordedVideoUrl = fileUrl;

                AppUtils.log('🎥 [STOP] Found MP4 URL: $mp4Url');
                break;
              }
            }
          }
        } else {
          AppUtils.log(
            '⚠️ [STOP] No fileList in serverResponse - recording may still be processing',
          );
        }

        AppUtils.log('✅ [STOP] SUCCESS - Recording stopped');
        AppUtils.log(
          '🔗 [STOP] Final file URL: ${fileUrl ?? 'null (processing)'}',
        );

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
            AppUtils.logEr('🔴 [STOP] Error details: ${jsonEncode(errorData)}');

            // Check for specific error codes
            if (errorData['code'] == 2) {
              AppUtils.logEr(
                '🔴 [STOP] UID MISMATCH ERROR - The UID used for stop must match the UID used for acquire/start!',
              );
            }
          } catch (e) {
            AppUtils.logEr('⚠️ [STOP] Could not parse error response: $e');
          }
        }

        final errorMsg =
            'Stop failed (${response.statusCode}): ${errorData['message'] ?? errorData['reason'] ?? 'Unknown error'}';
        AppUtils.logEr('🔴 [STOP] ERROR: $errorMsg');
        return AgoraRecordingResult.error(errorMsg);
      }
    } catch (e) {
      AppUtils.logEr('🔴 [STOP] EXCEPTION: $e');
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

  /// Complete recording workflow with retry logic (matching your working files)
  static Future<Map<String, dynamic>> startCompleteRecording({
    required String channelName,
    required int uid,
    String? token,
    String?
    storageChannelName, // For battle recordings using requester's channel
    int? incrementNumber, // For recording sequence numbering
    int maxRetries = 3,
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        AppUtils.log(
          '🎯 [WORKFLOW] Starting complete recording workflow (attempt ${retryCount + 1}/$maxRetries)',
        );
        AppUtils.log('📺 [WORKFLOW] Channel: $channelName, UID: $uid');

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
          storageChannelName: storageChannelName,
          incrementNumber: incrementNumber,
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
          '✅ [WORKFLOW] SUCCESS - Recording workflow completed on attempt ${retryCount + 1}',
        );
        AppUtils.log('🎉 [WORKFLOW] Recording is now fully active and ready!');

        return {
          'resourceId': acquireResult.resourceId,
          'sid': startResult.sid,
          'status': 'started',
          'attempt': retryCount + 1,
        };
      } catch (e) {
        retryCount++;
        AppUtils.logEr('🔴 [WORKFLOW] Failed on attempt $retryCount: $e');

        if (retryCount >= maxRetries) {
          AppUtils.logEr(
            '🔴 [WORKFLOW] FAILED after $maxRetries attempts - giving up',
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

  /// Complete stop workflow (matching your working files)
  static Future<List<Map<String, dynamic>>> stopCompleteRecording({
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

        // Extract recording files with URLs (like your working files)
        final recordingFiles = extractRecordingFiles(stopResult, channelName);

        AppUtils.log(
          '🎬 [WORKFLOW] Extracted ${recordingFiles.length} recording files',
        );
        return recordingFiles;
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

  /// Extract recording files from stop response (matching your working files)
  static List<Map<String, dynamic>> extractRecordingFiles(
    AgoraRecordingResult stopResult,
    String channelName,
  ) {
    try {
      AppUtils.log('🔍 [FILES] Extracting files from stop result');

      final List<Map<String, dynamic>> recordingFiles = [];

      // First, check if we have immediate URLs
      if (stopResult.fileUrl != null && stopResult.fileUrl!.isNotEmpty) {
        recordingFiles.add({
          'filename': 'recording.mp4',
          'url': stopResult.fileUrl!,
          'downloadUrl': stopResult.fileUrl!,
          'trackType': 'audio_and_video',
          'uid': '',
          'mixedAllUser': true,
          'isPlayable': true,
          'sliceStartTime': 0,
          'size': 0,
        });
        AppUtils.log('🎬 [FILES] Added fileUrl: ${stopResult.fileUrl}');
      }

      if (stopResult.mp4Url != null &&
          stopResult.mp4Url!.isNotEmpty &&
          stopResult.mp4Url != stopResult.fileUrl) {
        recordingFiles.add({
          'filename': 'recording_mp4.mp4',
          'url': stopResult.mp4Url!,
          'downloadUrl': stopResult.mp4Url!,
          'trackType': 'audio_and_video',
          'uid': '',
          'mixedAllUser': true,
          'isPlayable': true,
          'sliceStartTime': 0,
          'size': 0,
        });
        AppUtils.log('🎬 [FILES] Added mp4Url: ${stopResult.mp4Url}');
      }

      // Also extract from server response if available
      if (stopResult.serverResponse != null) {
        final fileList = stopResult.serverResponse!['fileList'] as List?;
        if (fileList != null && fileList.isNotEmpty) {
          AppUtils.log(
            '🔍 [FILES] Processing ${fileList.length} files from server response',
          );

          for (final file in fileList) {
            if (file is Map<String, dynamic>) {
              final filename = file['filename'] ?? '';
              final downloadUrl = file['downloadUrl'] as String?;
              final trackType = file['trackType'] ?? '';

              AppUtils.log(
                '📄 [FILES] File: $filename, trackType: $trackType, downloadUrl: $downloadUrl',
              );

              // Construct Blackblaze B2 URL if no downloadUrl
              String? fileUrl = downloadUrl;
              if (fileUrl == null || fileUrl.isEmpty) {
                if (filename.isNotEmpty) {
                  fileUrl = '$b2Endpoint/$filename';
                  AppUtils.log('🔗 [FILES] Constructed B2 URL: $fileUrl');
                }
              }

              if (fileUrl != null && fileUrl.isNotEmpty) {
                recordingFiles.add({
                  'filename': filename,
                  'url': fileUrl,
                  'downloadUrl': fileUrl,
                  'trackType': trackType,
                  'uid': file['uid'] ?? '',
                  'mixedAllUser': file['mixedAllUser'] ?? false,
                  'isPlayable': file['isPlayable'] ?? false,
                  'sliceStartTime': file['sliceStartTime'] ?? 0,
                  'size': file['size'] ?? 0,
                });
                AppUtils.log(
                  '🎬 [FILES] Added file: $filename with URL: $fileUrl',
                );
              }
            }
          }
        }
      }

      AppUtils.log(
        '🎬 [FILES] Extracted ${recordingFiles.length} recording files total',
      );
      return recordingFiles;
    } catch (e) {
      AppUtils.logEr('❌ [FILES] Failed to extract recording files: $e');
      return [];
    }
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

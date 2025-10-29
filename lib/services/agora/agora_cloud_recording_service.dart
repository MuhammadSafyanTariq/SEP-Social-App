import 'dart:convert';
import 'package:http/http.dart' as http;
import 'agora_cloud_recording_config.dart';

/// Service for Agora Cloud Recording REST API
/// Direct implementation without backend proxy
class AgoraCloudRecordingService {
  static const String _baseUrl = 'https://api.agora.io/v1/apps';

  /// Acquire a resource ID for cloud recording
  /// This must be called before starting recording
  ///
  /// Returns: resourceId (valid for 5 minutes)
  static Future<AgoraRecordingResult> acquire({
    required String channelName,
    required String uid,
  }) async {
    if (!AgoraCloudRecordingConfig.isConfigured) {
      return AgoraRecordingResult.error(
        'Agora Cloud Recording not configured. Please update credentials in agora_cloud_recording_config.dart',
      );
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/${AgoraCloudRecordingConfig.appId}/cloud_recording/acquire',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AgoraCloudRecordingConfig.basicAuth,
        },
        body: json.encode({
          'cname': channelName,
          'uid': uid,
          'clientRequest': {
            'resourceExpiredHour': 24,
            'scene': 0, // 0 for real-time, 1 for live streaming
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AgoraRecordingResult.success(resourceId: data['resourceId']);
      } else {
        final error = json.decode(response.body);
        return AgoraRecordingResult.error(
          'Acquire failed: ${error['message'] ?? response.body}',
        );
      }
    } catch (e) {
      return AgoraRecordingResult.error('Acquire error: $e');
    }
  }

  /// Start cloud recording
  ///
  /// Requires: resourceId from acquire()
  /// Returns: sid (session ID) and resourceId
  static Future<AgoraRecordingResult> start({
    required String channelName,
    required String uid,
    required String resourceId,
    required String token, // Agora RTC token for the channel
  }) async {
    if (!AgoraCloudRecordingConfig.isConfigured) {
      return AgoraRecordingResult.error('Agora Cloud Recording not configured');
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/${AgoraCloudRecordingConfig.appId}/cloud_recording/resourceid/$resourceId/mode/mix/start',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AgoraCloudRecordingConfig.basicAuth,
        },
        body: json.encode({
          'cname': channelName,
          'uid': uid,
          'clientRequest': {
            'token': token,
            'recordingConfig': {
              'maxIdleTime': 30,
              'streamTypes': 2, // 0=audio, 1=video, 2=both
              'channelType': 0, // 0=communication, 1=live
              'videoStreamType': 0,
              'subscribeVideoUids': [],
              'subscribeAudioUids': [],
              'subscribeUidGroup': 0,
            },
            'recordingFileConfig': {
              'avFileType': ['hls', 'mp4'],
            },
            'storageConfig': AgoraCloudRecordingConfig.storageConfig.toJson(),
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AgoraRecordingResult.success(
          resourceId: data['resourceId'],
          sid: data['sid'],
        );
      } else {
        final error = json.decode(response.body);
        return AgoraRecordingResult.error(
          'Start failed: ${error['message'] ?? response.body}',
        );
      }
    } catch (e) {
      return AgoraRecordingResult.error('Start error: $e');
    }
  }

  /// Stop cloud recording
  ///
  /// Requires: resourceId and sid from start()
  /// Returns: file information and URLs
  static Future<AgoraRecordingResult> stop({
    required String channelName,
    required String uid,
    required String resourceId,
    required String sid,
  }) async {
    if (!AgoraCloudRecordingConfig.isConfigured) {
      return AgoraRecordingResult.error('Agora Cloud Recording not configured');
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/${AgoraCloudRecordingConfig.appId}/cloud_recording/resourceid/$resourceId/sid/$sid/mode/mix/stop',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AgoraCloudRecordingConfig.basicAuth,
        },
        body: json.encode({
          'cname': channelName,
          'uid': uid,
          'clientRequest': {},
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final serverResponse = data['serverResponse'] as Map<String, dynamic>?;
        final fileList = serverResponse?['fileList'] as List?;

        String? fileUrl;
        if (fileList != null && fileList.isNotEmpty) {
          final fileName = fileList[0]['fileName'];
          // Generate public URL based on your storage configuration
          fileUrl = _generatePublicUrl(fileName);
        }

        return AgoraRecordingResult.success(
          resourceId: data['resourceId'],
          sid: data['sid'],
          fileUrl: fileUrl,
          fileList: fileList,
        );
      } else {
        final error = json.decode(response.body);
        return AgoraRecordingResult.error(
          'Stop failed: ${error['message'] ?? response.body}',
        );
      }
    } catch (e) {
      return AgoraRecordingResult.error('Stop error: $e');
    }
  }

  /// Query recording status
  static Future<AgoraRecordingResult> query({
    required String resourceId,
    required String sid,
  }) async {
    if (!AgoraCloudRecordingConfig.isConfigured) {
      return AgoraRecordingResult.error('Agora Cloud Recording not configured');
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/${AgoraCloudRecordingConfig.appId}/cloud_recording/resourceid/$resourceId/sid/$sid/mode/mix/query',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AgoraCloudRecordingConfig.basicAuth,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AgoraRecordingResult.success(
          resourceId: data['resourceId'],
          sid: data['sid'],
          serverResponse: data['serverResponse'],
        );
      } else {
        final error = json.decode(response.body);
        return AgoraRecordingResult.error(
          'Query failed: ${error['message'] ?? response.body}',
        );
      }
    } catch (e) {
      return AgoraRecordingResult.error('Query error: $e');
    }
  }

  /// Generate public URL based on storage configuration
  static String _generatePublicUrl(String fileName) {
    final config = AgoraCloudRecordingConfig.storageConfig;

    switch (config.vendor) {
      case CloudStorageVendor.aws:
        // AWS S3 URL format
        return 'https://${config.bucket}.s3.amazonaws.com/$fileName';
      case CloudStorageVendor.googleCloud:
        // Google Cloud Storage URL format
        return 'https://storage.googleapis.com/${config.bucket}/$fileName';
      case CloudStorageVendor.azure:
        // Azure Blob Storage URL format
        return 'https://${config.bucket}.blob.core.windows.net/$fileName';
      default:
        // Generic format
        return 'https://${config.bucket}/$fileName';
    }
  }
}

/// Result wrapper for Agora Cloud Recording operations
class AgoraRecordingResult {
  final bool success;
  final String? errorMessage;
  final String? resourceId;
  final String? sid;
  final String? fileUrl;
  final List? fileList;
  final Map<String, dynamic>? serverResponse;

  AgoraRecordingResult({
    required this.success,
    this.errorMessage,
    this.resourceId,
    this.sid,
    this.fileUrl,
    this.fileList,
    this.serverResponse,
  });

  factory AgoraRecordingResult.success({
    String? resourceId,
    String? sid,
    String? fileUrl,
    List? fileList,
    Map<String, dynamic>? serverResponse,
  }) {
    return AgoraRecordingResult(
      success: true,
      resourceId: resourceId,
      sid: sid,
      fileUrl: fileUrl,
      fileList: fileList,
      serverResponse: serverResponse,
    );
  }

  factory AgoraRecordingResult.error(String message) {
    return AgoraRecordingResult(success: false, errorMessage: message);
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sep/services/networking/urls.dart';
import 'package:sep/utils/appUtils.dart';

/// Service for Agora Cloud Recording
/// Communicates with backend API endpoints for recording management
class AgoraRecordingService {
  /// Acquire a resource ID for cloud recording
  /// Must be called before starting recording
  ///
  /// Request body:
  /// {
  ///   "channelName": "testchannel123",
  ///   "uid": "12345"
  /// }
  ///
  /// Response:
  /// {
  ///   "success": true,
  ///   "resourceId": "83MkRBjGCfhnIFLGvKeB-yLv8Ucl6IPs2cGvzVAGKfefz-kMxzIrdk5dUKAuw-WEjY4pMviB..."
  /// }
  static Future<AgoraRecordingResult> acquire({
    required String channelName,
    required String uid,
  }) async {
    try {
      AppUtils.log(
        'Agora Recording - Acquire started for channel: $channelName, uid: $uid',
      );

      final url = Uri.parse('${baseUrl}${Urls.agoraRecordingAcquire}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'channelName': channelName, 'uid': uid}),
      );

      AppUtils.log(
        'Agora Recording - Acquire response: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['resourceId'] != null) {
          AppUtils.log(
            'Agora Recording - Acquire successful: ${data['resourceId']}',
          );
          return AgoraRecordingResult.success(
            resourceId: data['resourceId'],
            message: data['message'],
          );
        } else {
          return AgoraRecordingResult.error(
            'Acquire failed: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        final error = json.decode(response.body);
        return AgoraRecordingResult.error(
          'Acquire failed (${response.statusCode}): ${error['message'] ?? response.body}',
        );
      }
    } catch (e) {
      AppUtils.logEr('Agora Recording - Acquire error: $e');
      return AgoraRecordingResult.error('Acquire error: $e');
    }
  }

  /// Start cloud recording
  ///
  /// Request body:
  /// {
  ///   "channelName": "testchannel123",
  ///   "uid": "12345",
  ///   "resourceId": "83MkRBjGCfhnIFLGvKeB-yLv8Ucl6IPs2cGvzVAGKfefz-kMxzIrdk5dUKAuw-WEjY4pMviB..."
  /// }
  ///
  /// Response:
  /// {
  ///   "success": true,
  ///   "resourceId": "83MkRBjGCfhnIFLGvKeB-yLv8Ucl6IPs2cGvzVAGKfefz-kMxzIrdk5dUKAuw-WEjY4pMviB...",
  ///   "sid": "pXbJNBsw75YMA",
  ///   "message": "Recording started successfully"
  /// }
  static Future<AgoraRecordingResult> start({
    required String channelName,
    required String uid,
    required String resourceId,
  }) async {
    try {
      AppUtils.log(
        'Agora Recording - Start recording for channel: $channelName, resourceId: $resourceId',
      );

      final url = Uri.parse('${baseUrl}${Urls.agoraRecordingStart}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'channelName': channelName,
          'uid': uid,
          'resourceId': resourceId,
        }),
      );

      AppUtils.log('Agora Recording - Start response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['sid'] != null) {
          AppUtils.log(
            'Agora Recording - Started successfully. SID: ${data['sid']}',
          );
          return AgoraRecordingResult.success(
            resourceId: data['resourceId'],
            sid: data['sid'],
            message: data['message'],
          );
        } else {
          return AgoraRecordingResult.error(
            'Start failed: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        final error = json.decode(response.body);
        return AgoraRecordingResult.error(
          'Start failed (${response.statusCode}): ${error['message'] ?? response.body}',
        );
      }
    } catch (e) {
      AppUtils.logEr('Agora Recording - Start error: $e');
      return AgoraRecordingResult.error('Start error: $e');
    }
  }

  /// Stop cloud recording
  ///
  /// Request body:
  /// {
  ///   "channelName": "testchannel123",
  ///   "uid": "12345",
  ///   "resourceId": "83MkRBjGCfhnIFLGvKeB-yLv8Ucl6IPs2cGvzVAGKfefz-kMxzIrdk5dUKAuw-WEjY4pMviB...",
  ///   "sid": "pXbJNBsw75YMA"
  /// }
  ///
  /// Response:
  /// {
  ///   "success": true,
  ///   "resourceId": "83MkRBjGCfhnIFLGvKeB-yLv8Ucl6IPs2cGvzVAGKfefz-kMxzIrdk5dUKAuw-WEjY4pMviB...",
  ///   "sid": "pXbJNBsw75YMA",
  ///   "message": "Recording stopped successfully",
  ///   "serverResponse": {...}
  /// }
  static Future<AgoraRecordingResult> stop({
    required String channelName,
    required String uid,
    required String resourceId,
    required String sid,
  }) async {
    try {
      AppUtils.log(
        'Agora Recording - Stop recording for channel: $channelName, sid: $sid',
      );

      final url = Uri.parse('${baseUrl}${Urls.agoraRecordingStop}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'channelName': channelName,
          'uid': uid,
          'resourceId': resourceId,
          'sid': sid,
        }),
      );

      AppUtils.log('Agora Recording - Stop response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          AppUtils.log('Agora Recording - Stopped successfully');
          return AgoraRecordingResult.success(
            resourceId: data['resourceId'],
            sid: data['sid'],
            message: data['message'],
            serverResponse: data['serverResponse'],
            fileUrl: data['fileUrl'],
          );
        } else {
          return AgoraRecordingResult.error(
            'Stop failed: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        final error = json.decode(response.body);
        return AgoraRecordingResult.error(
          'Stop failed (${response.statusCode}): ${error['message'] ?? response.body}',
        );
      }
    } catch (e) {
      AppUtils.logEr('Agora Recording - Stop error: $e');
      return AgoraRecordingResult.error('Stop error: $e');
    }
  }

  /// Query recording status (optional - if backend supports it)
  static Future<AgoraRecordingResult> query({
    required String resourceId,
    required String sid,
  }) async {
    try {
      final url = Uri.parse('${baseUrl}/api/agora/recording/query');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'resourceId': resourceId, 'sid': sid}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AgoraRecordingResult.success(
          resourceId: data['resourceId'],
          sid: data['sid'],
          serverResponse: data['serverResponse'],
        );
      } else {
        return AgoraRecordingResult.error('Query failed: ${response.body}');
      }
    } catch (e) {
      return AgoraRecordingResult.error('Query error: $e');
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
  final Map<String, dynamic>? serverResponse;

  AgoraRecordingResult({
    required this.success,
    this.resourceId,
    this.sid,
    this.message,
    this.errorMessage,
    this.fileUrl,
    this.serverResponse,
  });

  factory AgoraRecordingResult.success({
    String? resourceId,
    String? sid,
    String? message,
    String? fileUrl,
    Map<String, dynamic>? serverResponse,
  }) {
    return AgoraRecordingResult(
      success: true,
      resourceId: resourceId,
      sid: sid,
      message: message,
      fileUrl: fileUrl,
      serverResponse: serverResponse,
    );
  }

  factory AgoraRecordingResult.error(String message) {
    return AgoraRecordingResult(success: false, errorMessage: message);
  }

  @override
  String toString() {
    if (success) {
      return 'AgoraRecordingResult(success: true, resourceId: $resourceId, sid: $sid, message: $message)';
    } else {
      return 'AgoraRecordingResult(success: false, error: $errorMessage)';
    }
  }
}

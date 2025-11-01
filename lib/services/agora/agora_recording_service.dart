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

      final requestBody = {'channelName': channelName, 'uid': uid};

      AppUtils.log('Agora Recording - Acquire request body: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      AppUtils.log(
        'Agora Recording - Acquire response status: ${response.statusCode}',
      );
      AppUtils.log('Agora Recording - Acquire response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Print complete server response
        AppUtils.log('acquireRecording:response');
        AppUtils.log('${DateTime.now()}');
        AppUtils.log(jsonEncode(data));

        if (data['success'] == true && data['resourceId'] != null) {
          AppUtils.log(
            'Agora Recording - Acquire successful: ${data['resourceId']}',
          );
          return AgoraRecordingResult.success(
            resourceId: data['resourceId'],
            message: data['message'],
          );
        } else {
          final errorMsg =
              'Acquire failed: ${data['message'] ?? 'Unknown error'}';
          AppUtils.logEr('Agora Recording - $errorMsg');
          return AgoraRecordingResult.error(errorMsg);
        }
      } else {
        try {
          final error = json.decode(response.body);
          final errorMsg =
              'Acquire failed (${response.statusCode}): ${error['message'] ?? response.body}';
          AppUtils.logEr('Agora Recording - $errorMsg');
          return AgoraRecordingResult.error(errorMsg);
        } catch (e) {
          final errorMsg =
              'Acquire failed (${response.statusCode}): ${response.body}';
          AppUtils.logEr('Agora Recording - $errorMsg');
          return AgoraRecordingResult.error(errorMsg);
        }
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
        'Agora Recording - Start recording for channel: $channelName, uid: $uid, resourceId: $resourceId',
      );

      final url = Uri.parse('${baseUrl}${Urls.agoraRecordingStart}');

      final requestBody = {
        'channelName': channelName,
        'uid': uid,
        'resourceId': resourceId,
      };

      AppUtils.log('Agora Recording - Start request body: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      AppUtils.log(
        'Agora Recording - Start response status: ${response.statusCode}',
      );
      AppUtils.log('Agora Recording - Start response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Print complete server response
        AppUtils.log('startRecording:response');
        AppUtils.log('${DateTime.now()}');
        AppUtils.log(jsonEncode(data));

        if (data['success'] == true && data['sid'] != null) {
          AppUtils.log(
            'Agora Recording - Started successfully. SID: ${data['sid']}',
          );
          AppUtils.log('Agora Recording - ResourceId: ${data['resourceId']}');

          return AgoraRecordingResult.success(
            resourceId: data['resourceId'],
            sid: data['sid'],
            message: data['message'],
          );
        } else {
          final errorMsg =
              'Start failed: ${data['message'] ?? 'Unknown error'}';
          AppUtils.logEr('Agora Recording - $errorMsg');
          AppUtils.logEr(
            'Agora Recording - Full response: ${jsonEncode(data)}',
          );
          return AgoraRecordingResult.error(errorMsg);
        }
      } else {
        try {
          final error = json.decode(response.body);
          final errorMsg =
              'Start failed (${response.statusCode}): ${error['message'] ?? response.body}';
          AppUtils.logEr('Agora Recording - $errorMsg');
          AppUtils.logEr('Agora Recording - Error response: ${response.body}');
          return AgoraRecordingResult.error(errorMsg);
        } catch (e) {
          final errorMsg =
              'Start failed (${response.statusCode}): ${response.body}';
          AppUtils.logEr('Agora Recording - $errorMsg');
          return AgoraRecordingResult.error(errorMsg);
        }
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
        'Agora Recording - Stop recording for channel: $channelName, uid: $uid, sid: $sid, resourceId: $resourceId',
      );

      final url = Uri.parse('${baseUrl}${Urls.agoraRecordingStop}');

      final requestBody = {
        'channelName': channelName,
        'uid': uid,
        'resourceId': resourceId,
        'sid': sid,
      };

      AppUtils.log('Agora Recording - Request URL: $url');
      AppUtils.log('Agora Recording - Request body: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      AppUtils.log(
        'Agora Recording - Stop response status: ${response.statusCode}',
      );
      AppUtils.log('Agora Recording - Stop response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Print complete server response
        AppUtils.log('stopRecording:response');
        AppUtils.log('${DateTime.now()}');
        AppUtils.log(jsonEncode(data));

        if (data['success'] == true) {
          AppUtils.log('Agora Recording - Stopped successfully');
          AppUtils.log('Agora Recording - File URL: ${data['fileUrl']}');

          // Extract MP4 URL from fileList if available
          String? mp4Url;
          if (data['serverResponse'] != null &&
              data['serverResponse']['fileList'] != null) {
            final fileList = data['serverResponse']['fileList'] as List;
            // Find the first MP4 file in the list
            final mp4File = fileList.firstWhere(
              (file) => file['fileName']?.toString().endsWith('.mp4') ?? false,
              orElse: () => null,
            );
            if (mp4File != null) {
              mp4Url = mp4File['fileName'];
              AppUtils.log('Agora Recording - MP4 file: $mp4Url');
            }
          }

          return AgoraRecordingResult.success(
            resourceId: data['resourceId'],
            sid: data['sid'],
            message: data['message'],
            serverResponse: data['serverResponse'],
            fileUrl: data['fileUrl'],
            mp4Url: mp4Url,
          );
        } else {
          final errorMsg = 'Stop failed: ${data['message'] ?? 'Unknown error'}';
          AppUtils.logEr('Agora Recording - $errorMsg');
          return AgoraRecordingResult.error(errorMsg);
        }
      } else {
        try {
          final error = json.decode(response.body);
          final errorMsg =
              'Stop failed (${response.statusCode}): ${error['message'] ?? response.body}';
          AppUtils.logEr('Agora Recording - $errorMsg');
          return AgoraRecordingResult.error(errorMsg);
        } catch (e) {
          final errorMsg =
              'Stop failed (${response.statusCode}): ${response.body}';
          AppUtils.logEr('Agora Recording - $errorMsg');
          return AgoraRecordingResult.error(errorMsg);
        }
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

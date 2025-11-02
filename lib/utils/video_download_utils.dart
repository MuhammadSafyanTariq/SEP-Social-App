import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:saver_gallery/saver_gallery.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sep/utils/appUtils.dart';

/// Utility class for downloading and saving videos to gallery
class VideoDownloadUtils {
  /// Downloads a video from URL and saves it to the device gallery
  static Future<bool> downloadVideoToGallery(
    String videoUrl, {
    String? fileName,
  }) async {
    try {
      // Print the URL in green color to debug console
      _printVideoUrlInGreen(videoUrl);

      // Test URL accessibility first to prevent 400 errors
      AppUtils.log('🧪 Testing video URL accessibility before download...');
      final isAccessible = await testVideoUrlAccessibility(videoUrl);
      if (!isAccessible) {
        AppUtils.logEr('❌ Video URL is not accessible: $videoUrl');
        return false;
      }

      // Request permissions
      final permissionsGranted = await _requestPermissions();
      if (!permissionsGranted) {
        throw Exception('Storage permissions are required to save videos');
      }

      // Generate filename if not provided
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalFileName = fileName ?? 'SEP_Recording_$timestamp.mp4';

      AppUtils.log('🔄 Starting video download from: $videoUrl');
      AppUtils.log('💾 Saving as: $finalFileName');

      // Download video data with timeout
      final response = await http
          .get(Uri.parse(videoUrl))
          .timeout(
            const Duration(minutes: 5),
            onTimeout: () {
              throw Exception('Download timeout after 5 minutes');
            },
          );

      if (response.statusCode == 200) {
        final Uint8List videoBytes = response.bodyBytes;
        AppUtils.log(
          '✅ Video downloaded successfully (${videoBytes.length} bytes)',
        );

        // Create temporary file first
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$finalFileName');
        await tempFile.writeAsBytes(videoBytes);

        AppUtils.log('📝 Temporary file created: ${tempFile.path}');

        // Save to gallery using saver_gallery with correct parameters
        final result = await SaverGallery.saveFile(
          filePath: tempFile.path,
          fileName: finalFileName,
          skipIfExists: false, // Allow overwrite
        );

        // Clean up temporary file
        try {
          await tempFile.delete();
          AppUtils.log('🗑️ Temporary file cleaned up');
        } catch (e) {
          AppUtils.log('⚠️ Could not delete temporary file: $e');
        }

        if (result.isSuccess) {
          AppUtils.log('🎉 Video saved to gallery successfully!');
          AppUtils.log('📁 Save result: ${result.toString()}');
          return true;
        } else {
          AppUtils.logEr(
            '❌ Failed to save video to gallery: ${result.errorMessage}',
          );
          return false;
        }
      } else {
        AppUtils.logEr(
          '❌ Failed to download video. Status code: ${response.statusCode}',
        );
        return false;
      }
    } catch (e, stackTrace) {
      AppUtils.logEr('❌ Error downloading/saving video: $e');
      AppUtils.logEr('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Downloads multiple videos to gallery
  static Future<Map<String, bool>> downloadMultipleVideosToGallery(
    List<String> videoUrls,
  ) async {
    final Map<String, bool> results = {};

    AppUtils.log('🎬 Starting download of ${videoUrls.length} videos...');

    for (int i = 0; i < videoUrls.length; i++) {
      final url = videoUrls[i];
      final fileName =
          'SEP_Recording_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.mp4';

      AppUtils.log('📥 Downloading video ${i + 1}/${videoUrls.length}...');
      final success = await downloadVideoToGallery(url, fileName: fileName);
      results[url] = success;

      // Small delay between downloads to prevent overwhelming the system
      if (i < videoUrls.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    final successCount = results.values.where((success) => success).length;
    AppUtils.log(
      '🎯 Download complete: $successCount/${videoUrls.length} videos saved successfully',
    );

    return results;
  }

  /// Print video URL in green color to debug console
  static void _printVideoUrlInGreen(String videoUrl) {
    // ANSI escape codes for green text
    const String greenStart = '\x1B[32m';
    const String colorEnd = '\x1B[0m';

    // ignore: avoid_print
    print('$greenStart🎥 VIDEO URL: $videoUrl$colorEnd');

    // Also log with AppUtils for consistency
    AppUtils.log('🎥 VIDEO URL: $videoUrl');
  }

  /// Print multiple video URLs in green color
  static void printVideoUrlsInGreen(List<String> videoUrls) {
    const String greenStart = '\x1B[32m';
    const String colorEnd = '\x1B[0m';

    // ignore: avoid_print
    print('$greenStart🎬 === RECORDED VIDEO URLS ===$colorEnd');
    for (int i = 0; i < videoUrls.length; i++) {
      // ignore: avoid_print
      print('$greenStart🎥 Video ${i + 1}: ${videoUrls[i]}$colorEnd');
    }
    // ignore: avoid_print
    print('$greenStart🎬 === END VIDEO URLS ===$colorEnd');

    // Also log with AppUtils
    AppUtils.log('🎬 === RECORDED VIDEO URLS ===');
    for (int i = 0; i < videoUrls.length; i++) {
      AppUtils.log('🎥 Video ${i + 1}: ${videoUrls[i]}');
    }
    AppUtils.log('🎬 === END VIDEO URLS ===');
  }

  /// Request necessary permissions for saving to gallery
  static Future<bool> _requestPermissions() async {
    try {
      AppUtils.log('🔐 Requesting gallery permissions...');

      if (Platform.isAndroid) {
        // Get Android version for proper permission handling
        final androidInfo = await _getAndroidVersion();
        AppUtils.log('📱 Android API level: $androidInfo');

        if (androidInfo >= 33) {
          // Android 13+ (API 33+) uses granular media permissions
          AppUtils.log('🔄 Requesting Android 13+ media permissions...');

          final videoPermission = await Permission.videos.request();
          final photoPermission = await Permission.photos.request();

          AppUtils.log('📹 Video permission: $videoPermission');
          AppUtils.log('🖼️ Photo permission: $photoPermission');

          if (videoPermission.isDenied && photoPermission.isDenied) {
            AppUtils.logEr('❌ Media permissions denied');
            throw Exception(
              'Storage permissions denied. Please grant video and photo permissions in Settings.',
            );
          } else if (videoPermission.isPermanentlyDenied ||
              photoPermission.isPermanentlyDenied) {
            AppUtils.logEr('❌ Media permissions permanently denied');
            throw Exception(
              'Storage permissions permanently denied. Please enable them in Settings.',
            );
          } else {
            AppUtils.log('✅ Media permissions granted');
          }
        } else if (androidInfo >= 30) {
          // Android 11-12 (API 30-32)
          AppUtils.log('🔄 Requesting Android 11-12 storage permissions...');

          final storageStatus = await Permission.storage.request();
          final manageStorageStatus = await Permission.manageExternalStorage
              .request();

          AppUtils.log('📁 Storage permission: $storageStatus');
          AppUtils.log('🗂️ Manage storage permission: $manageStorageStatus');

          if (storageStatus.isDenied) {
            AppUtils.logEr('❌ Storage permission denied');
            throw Exception(
              'Storage permission denied. Please grant storage access in Settings.',
            );
          } else if (storageStatus.isPermanentlyDenied) {
            AppUtils.logEr('❌ Storage permission permanently denied');
            throw Exception(
              'Storage permission permanently denied. Please enable it in Settings.',
            );
          }
        } else {
          // Android 10 and below (API 29 and below)
          AppUtils.log('🔄 Requesting legacy storage permissions...');

          final storageStatus = await Permission.storage.request();
          AppUtils.log('📁 Storage permission: $storageStatus');

          if (storageStatus.isDenied) {
            AppUtils.logEr('❌ Storage permission denied');
            throw Exception(
              'Storage permission denied. Please grant storage access in Settings.',
            );
          } else if (storageStatus.isPermanentlyDenied) {
            AppUtils.logEr('❌ Storage permission permanently denied');
            throw Exception(
              'Storage permission permanently denied. Please enable it in Settings.',
            );
          }
        }
      } else if (Platform.isIOS) {
        // iOS permissions
        AppUtils.log('🔄 Requesting iOS photo library permissions...');

        final status = await Permission.photos.request();
        AppUtils.log('📸 iOS Photos permission: $status');

        if (status.isDenied) {
          AppUtils.logEr('❌ iOS Photos permission denied');
          throw Exception(
            'Photo library access denied. Please grant access in Settings.',
          );
        } else if (status.isPermanentlyDenied) {
          AppUtils.logEr('❌ iOS Photos permission permanently denied');
          throw Exception(
            'Photo library access permanently denied. Please enable it in Settings.',
          );
        } else {
          AppUtils.log('✅ iOS Photos permission granted');
        }
      }

      return true; // Permissions granted successfully
    } catch (e) {
      AppUtils.logEr('❌ Error requesting permissions: $e');
      return false; // Permissions failed
    }
  }

  /// Get Android SDK version using device_info_plus
  static Future<int> _getAndroidVersion() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.version.sdkInt;
      }
      return 30; // Default for non-Android
    } catch (e) {
      AppUtils.logEr('Error getting Android version: $e');
      return 30; // Default fallback
    }
  }

  /// Test if a video URL is accessible by making a HEAD request
  static Future<bool> testVideoUrlAccessibility(String url) async {
    try {
      AppUtils.log('🧪 [TEST] Testing URL accessibility: $url');

      final uri = Uri.parse(url);
      final client = http.Client();

      // Make a HEAD request to check if the URL is accessible without downloading
      final response = await client
          .head(uri)
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              AppUtils.logEr('🧪 [TEST] Timeout testing URL: $url');
              throw Exception('Request timeout');
            },
          );

      AppUtils.log('🧪 [TEST] Response status: ${response.statusCode}');
      AppUtils.log('🧪 [TEST] Response headers: ${response.headers}');

      client.close();

      if (response.statusCode == 200) {
        AppUtils.log('✅ [TEST] URL is accessible: $url');
        return true;
      } else {
        AppUtils.logEr('❌ [TEST] URL returned ${response.statusCode}: $url');
        return false;
      }
    } catch (e) {
      AppUtils.logEr('❌ [TEST] Error testing URL accessibility: $e');
      return false;
    }
  }

  /// Test multiple video URLs and return the first accessible one
  static Future<String?> findAccessibleVideoUrl(List<String> urls) async {
    AppUtils.log('🧪 [TEST] Testing ${urls.length} URLs for accessibility...');

    for (int i = 0; i < urls.length; i++) {
      final url = urls[i];
      AppUtils.log('🧪 [TEST] Testing URL ${i + 1}/${urls.length}: $url');

      final isAccessible = await testVideoUrlAccessibility(url);
      if (isAccessible) {
        AppUtils.log('✅ [TEST] Found accessible URL: $url');
        return url;
      }
    }

    AppUtils.logEr('❌ [TEST] No accessible URLs found');
    return null;
  }
}

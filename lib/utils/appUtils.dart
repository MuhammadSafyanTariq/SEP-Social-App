import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../core/core/error.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';


class AppUtils {
  static final ImagePicker _imagePicker = ImagePicker();
  static final Logger _log = Logger();

  static dynamic _userId;

  /// Logs a debug message
  static void log(var msg, {bool show = true}) =>
      show ? _log.d(msg) :
      null;
  static void logg(var msg, {bool show = true}) =>_log.d(msg);

  /// Logs an error message
  static void logEr(var msg, {bool show = true}) => show ?_log.e(msg) : null;

  /// Getter for the user ID
  static dynamic get userId => _userId;

  /// Sets the user ID dynamically
  static void setUserId(dynamic id) {
    _userId = id;
    log("User ID set to: $id");
  }

  static Future<String?> imagePicker() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  static String get deviceType {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isLinux) {
      return 'linux';
    } else {
      return 'unknown';
    }
  }


  static Future<Uint8List?> fetchVideoBytes(String videoUrl) async {
    try {
      final response = await http.get(Uri.parse(videoUrl));

      if (response.statusCode == 200) {
        return response.bodyBytes; // Convert response to Uint8List
      } else {
        print("Failed to load video, Status Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching video: $e");
      return null;
    }
  }


  static Future<Uint8List?> getVideoThumbnail(String url) async {
    log(url);

    final isSupportedFormat = url.toLowerCase().endsWith('.mp4') ||
        url.toLowerCase().endsWith('.mov') ||
        url.toLowerCase().endsWith('.avi');

    if (!isSupportedFormat) {
      log("Unsupported video format");
      return null;
    }
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: url,
        maxWidth: 200,
        quality: 75,
      );
      return uint8list;
    } catch (e) {
      log("Error generating thumbnail: $e");
      return null;
    }
  }


  static Future<String?> videoPicker() async {
    final XFile? galleryVideo =
    await _imagePicker.pickVideo(source: ImageSource.gallery);
    return galleryVideo?.path;
  }

  static void toast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: AppColors.btnColor,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 16.0,
      webPosition: "center",
    );


  }
  static void toastError(dynamic error) {
    var msg = '';

    if (error is Failure) {
      if (error is InternetFailure) {
        msg = 'Please check your internet';
      } else if (error is ErrorFailure) {
        msg = error.error;
      } else {
        msg = '$error';
      }
    } else if (error is String) {
      msg = error; // Directly assign if it's a string
    } else {
      msg = '$error';
    }

    // Handle special cases
    final errorValue = msg.contains('Connection closed before full header was received') ||
        msg.contains('FormatException: Unexpected character (at character 1)')
        ? 'Something went wrong! Please try again.'
        : msg.contains('Exception:')
        ? msg.replaceAll('Exception:', '').trim()
        : (msg.isEmpty ? 'An unknown error occurred' : msg);

    Fluttertoast.showToast(
      msg: errorValue,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }


  static String configImageUrl(String url, {bool userImage = false}){
    String value = '';
    if(url.isNotNullEmpty){
      if(url.startsWith('http')){
        value = url;
      }else {
        value = '$baseUrl$url';
      }
    }else{
      value = '';
    }
    // log(value);
    return value;
  }


}



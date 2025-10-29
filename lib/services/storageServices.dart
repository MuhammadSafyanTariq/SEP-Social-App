import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fl_downloader/fl_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/core/error.dart';
import '../utils/appUtils.dart';

class StorageServices{

  static Future<int> androidSdkValue() async{
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final build = await deviceInfoPlugin.androidInfo;
    return build.version.sdkInt;
  }

  static Future<bool> hasPermission() async{
    final status = await Permission.storage.status;
    return status.isGranted || status.isLimited || status.isProvisional;
  }

  static Future<bool> requestStoragePermission() async {

    final permission = await Permission.storage.request();
    if (permission.isGranted || permission.isLimited || permission.isProvisional) {
      return true;
    } else if(permission.isDenied){
      return false;
    }else if(permission.isPermanentlyDenied){
      openAppSettings();
    }
    return false;
  }

  static Future<bool> grantPermission() async{
    if(await hasPermission()){
      return true;
    }
    return requestStoragePermission();
  }

  static Future<String> pdfSavePath(String fileName) async{
    bool dirDownloadExists = true;
    Directory? directory;
    if (Platform.isIOS) {
      directory = await getDownloadsDirectory();
    } else {
      String downloadPath = "/storage/emulated/0/Download";
      dirDownloadExists = await Directory(downloadPath).exists();
      if(dirDownloadExists){
        directory = Directory(downloadPath);
      }else{
        directory = Directory(downloadPath);
      }
    }

    String savePath = "${directory?.path}/$fileName";
    AppUtils.log(savePath);
    return savePath;
  }


  static Future<String?> saveFile(Uint8List fileData, String fileName) async {
    try {
      final params = SaveFileDialogParams(
        data: fileData,
        fileName: fileName,
        mimeTypesFilter: ["application/pdf"],
      );

      final savePath = await FlutterFileDialog.saveFile(params: params,);

      if (savePath != null) {
        return savePath;
      } else {
        throw const ErrorFailure(error: 'Failed to download file');
      }
    } catch (e) {
      throw const ErrorFailure(error: 'Failed to download file');
    }
  }


 static Future<String> downloadFile(String url, String fileName) =>  _DownloaderPdf().download(url,fileName);

  static void launchPdf(String path)=> FlDownloader.openFile(filePath: path);

}

class _DownloaderPdf{
  Future<String> download(String url, String fileName) async{
      AppUtils.log(url);
      await FlDownloader.initialize();
      await FlDownloader.requestPermission();
      final completer = Completer<String>();

      FlDownloader.progressStream.handleError((error){
        print('progess error: ${error.toString()}');
      });


      FlDownloader.progressStream.listen((event) {
        AppUtils.log(event.status);
        if (event.status == DownloadStatus.successful) {
          completer.complete(event.filePath);
        } else if (event.status == DownloadStatus.failed) {

          completer.completeError('Download failed');

        } else if (event.status == DownloadStatus.paused) {
          Future.delayed(
            const Duration(milliseconds: 250),
                () => FlDownloader.attachDownloadProgress(event.downloadId),
          );
        }
        debugPrint('event: $event');
      });

      try {
        await FlDownloader.download(url,fileName: fileName);
        AppUtils.log('progress');
      } catch (e) {
        AppUtils.log('progress error ..... $e');
        completer.completeError('Download initiation failed: $e');
      }
      return completer.future;
  }
}
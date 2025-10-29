import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sep/utils/appUtils.dart';

import '../styles/appImages.dart';

Future<ImageProvider> loadOptimizedImage(String? image, String baseUrl) async {
  if (image == null) return AssetImage(AppImages.editProfileImg);

  bool isNetworkImage = image.startsWith("http");
  bool isServerImage = image.startsWith("/public/uploads/");
  bool isFileImage = image.startsWith("/") && !isNetworkImage && !isServerImage;

  if (isNetworkImage || isServerImage) {
    String finalImage = isServerImage ? "$baseUrl$image" : image;
    AppUtils.log('finalImage');
    AppUtils.log('$baseUrl$image');

    return NetworkImage(finalImage);
  } else if (isFileImage) {
    File file = File(image);
    Uint8List? compressedBytes = await compressImage(file);
    return MemoryImage(compressedBytes ?? await file.readAsBytes());
  } else {
    return AssetImage(AppImages.editProfileImg);
  }
}

Future<Uint8List?> compressImage(File file) async {
  var result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minWidth: 300,
    minHeight: 300,
    quality: 70,
    format: CompressFormat.jpeg,
  );

  return result;
}

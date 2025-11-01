import 'dart:ui' as ui;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/utils/appUtils.dart';
import 'dart:typed_data';

import 'package:video_thumbnail/video_thumbnail.dart';

final _manager = DefaultCacheManager();

Future<ui.Size> getNetworkImageSize(String url) async {
  try {
    final file = await _manager.getSingleFile(url);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    _manager.removeFile(url);
    return ui.Size(image.width.toDouble(), image.height.toDouble());
  } catch (e) {
    AppUtils.log(url);
    throw 'issuee with image....';
  }
}

class SizedImage extends StatelessWidget {
  final String url;
  final ui.Size size; // original image size
  final double maxWidth; // screen width
  final double maxHeight; // screen height

  const SizedImage({
    super.key,
    required this.url,
    required this.size,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Always fit to width first to use full available width
    double finalWidth = maxWidth;
    double finalHeight = (size.height / size.width) * maxWidth;

    // Only constrain height if it's excessively tall (more than maxHeight)
    // This allows long images to display properly
    if (finalHeight > maxHeight) {
      finalHeight = maxHeight;
      finalWidth = (size.width / size.height) * maxHeight;
    }

    return Center(
      child: ImageView(
        url: url,
        width: finalWidth,
        height: finalHeight,
        fit: BoxFit.contain,
        imageType: ImageType.network,
      ),
    );

    //   Image.network(
    //   url,
    //   width: finalWidth,
    //   height: finalHeight,
    //   fit: BoxFit.fill,
    // );
  }
}

Future<Uint8List?> getThumbnail(
  String file,
  // , double height, double width
) async {
  final uint8list = await VideoThumbnail.thumbnailData(
    video: file,
    quality: 100,
    imageFormat: ImageFormat.JPEG,
  );
  return uint8list;
}

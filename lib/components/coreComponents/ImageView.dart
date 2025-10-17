import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sep/utils/extensions/extensions.dart';
// import 'package:video_thumbnail_imageview/video_thumbnail_imageview.dart';
import '../styles/appColors.dart';
import 'TapWidget.dart';
import 'TextView.dart';

enum ImageType { asset, file, network, thumbnail}

class ImageView extends FormField<String> {
  ImageView(
      {Key? key,
      super.validator,
      required String url,
      ImageType? imageType,
      double? size,
      double? height,
      double? width,
      EdgeInsets? imagePadding,
      BoxFit? fit,
      dynamic Function()? onTap,
      double? radius,
      Color? tintColor,
      EdgeInsets? margin,
      bool hasBorder = false,
      Color? bgColor,
      double? radiusWidth,
      Color? borderColor,
      EdgeInsets? padding,
      String? defaultImage,
      bool hasGradient = false,
      bool fastLoading = false})
      : super(
          key: key,
          builder: (FormFieldState<String> state) {
            return ImageViewContent(
              url: url,
              imageType: imageType,
              size: size,
              height: height,
              width: width,
              imagePadding: imagePadding,
              fit: fit,
              onTap: onTap,
              radius: radius,
              tintColor: tintColor,
              margin: margin,
              hasBorder: hasBorder,
              borderColor: borderColor,
              bgColor: bgColor,
              radiusWidth: radiusWidth,
              padding: padding,
              hasGradient: hasGradient,
              defaultImage: defaultImage,
              fastLoading: fastLoading,
              error: state.errorText,
            );
          },
        );
}

class ImageViewContent extends StatelessWidget {
  final String url;
  final ImageType? imageType;
  final double? size;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double? radius;
  final Color? tintColor;
  final Color? borderColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Function()? onTap;
  final bool hasBorder;
  final bool hasGradient;
  final Color? bgColor;
  final double? radiusWidth;
  final String? defaultImage;
  final EdgeInsets? imagePadding;
  final String? error;
  final bool fastLoading;

  const ImageViewContent(
      {super.key,
      required this.url,
      this.imageType,
      this.size,
      this.height,
      this.width,
      this.imagePadding,
      this.fit,
      this.onTap,
      this.radius,
      this.tintColor,
      this.margin,
      this.hasBorder = false,
      this.borderColor,
      this.bgColor,
      this.radiusWidth,
      this.padding,
      this.fastLoading = false,
      this.hasGradient = false,
      this.defaultImage,
      this.error});

  ImageProvider image() {
    switch (imageType) {
      case ImageType.network:
        return url.trim().isEmpty && defaultImage != null
            ? AssetImage(defaultImage!)
            : CachedNetworkImageProvider(url, cacheKey: url,)
        // fastLoading
        //         ? CachedNetworkImageProvider(url, cacheKey: url)
        //         : NetworkImage(url)
        ;
      case ImageType.file:
        return FileImage(File(url));
      default:
        return AssetImage(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius ?? 10),
                    gradient: hasGradient ? AppColors.gradientBtn : null),
                // padding: const EdgeInsets.all(4),
                child: Container(
                  height: size ?? height,
                  width: size ?? width,
                  decoration: BoxDecoration(
                      color: bgColor
                      // ?? Colors.white
                      ,
                      borderRadius: BorderRadius.circular(radius ?? 0),
                      border: hasBorder
                          ? Border.all(
                              color: borderColor ?? AppColors.grey,
                              width: radiusWidth ?? 1.0)
                          : null),
                  padding: imagePadding,
                  clipBehavior: Clip.hardEdge,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius ?? 0),
                    ),
                    padding: padding,
                    // color: imageType == ImageType.network
                    //     ?
                    //     // AppColors.greyLightBorder
                    //     // AppColors.white
                    //     null
                    //     : null,







                    child:
    // imageType == ImageType.thumbnail
                    //     ? VTImageView(
                    //         videoUrl: url,
                    //         height: size ?? height,
                    //         width: size ?? width,
                    //         fit: fit,
                    //         color: tintColor,
                    //         errorBuilder: (context, error, stack) {
                    //           return Container(
                    //             width: 200.0,
                    //             height: 200.0,
                    //             color: Colors.blue,
                    //             child: Center(
                    //               child: Text("Image Loading Error"),
                    //             ),
                    //           );
                    //         },
                    //         assetPlaceHolder: '',
                    //       )


                    Image(
                            image: image(),
                            height: size ?? height,
                            width: size ?? width,
                            fit: fit,
                            color: tintColor,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(),
                          ),
                  ),
                ),
              ),
              Positioned.fill(
                  child: TapWidget(
                onTap: onTap,
              ))
            ],
          ),
          Visibility(
              visible: error.isNotNullEmpty,
              child: TextView(
                text: error ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ))
        ],
      ),
    );
  }
}

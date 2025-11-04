import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/auto_play_video_player.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_card_header.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/read_more_text.dart';
import 'package:sep/main.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../utils/image_utils.dart';
import '../../../data/models/dataModels/post_data.dart';
import 'dart:ui' as ui;

List<String> videoExtensions = [
  "mp4",
  "mkv",
  "mov",
  "avi",
  "wmv",
  "flv",
  "webm",
  "mpeg",
  "mpg",
  "3gp",
  "ogv",
  "ogg",
  "ts",
  "m2ts",
  "m4v",
  "asf",
  "rm",
  "rmvb",
  "divx",
  "vob",
  "f4v",
  "mxf",
  "prores",
];

String getFileExtn(String? data) {
  if (data.isNotNullEmpty) {
    final array = data!.split('.');
    if (array.length > 1) {
      AppUtils.log(array.last);
      return array.last.toLowerCase();
    } else {
      return '';
    }
  } else {
    return '';
  }
}

class PostCard extends StatelessWidget {
  final String caption;
  final List<FileElement> imageUrls;
  final String likes;
  final String comments;
  final VoidCallback? onTap;
  final PostCardHeader header;
  final Widget footer;
  final String postId;

  PostCard({
    Key? key,
    required this.caption,
    required this.imageUrls,
    required this.likes,
    required this.comments,
    this.onTap,
    required this.header,
    required this.footer,
    required this.postId,
  }) : super(key: key);

  final PageController _pageController = PageController();

  bool isVideo(FileElement file) {
    // First check the type field if available
    if (file.type != null && file.type!.toLowerCase() == 'video') {
      return true;
    }

    // Fallback: check file extension
    final fileUrl = file.file ?? '';
    if (fileUrl.isNotEmpty) {
      final extension = getFileExtn(fileUrl).toLowerCase();
      return videoExtensions.contains(extension);
    }

    return false;
  }

  /// Calculate precise aspect ratio with safety checks
  double calculateAspectRatio(
    double? width,
    double? height, {
    double fallback = 16 / 9,
  }) {
    if (width == null || height == null || width <= 0 || height <= 0) {
      return fallback;
    }

    final ratio = width / height;

    // Clamp extreme aspect ratios to prevent UI issues
    const minRatio = 0.2; // Very tall images (1:5)
    const maxRatio = 5.0; // Very wide images (5:1)

    return ratio.clamp(minRatio, maxRatio);
  }

  /// Calculate optimal aspect ratio for multi-image carousel
  double calculateCarouselAspectRatio(List<FileElement> images) {
    if (images.isEmpty) return 1.0;

    double totalRatio = 0;
    int validRatios = 0;

    for (final image in images) {
      if (image.x != null && image.y != null && image.x! > 0 && image.y! > 0) {
        totalRatio += calculateAspectRatio(image.x, image.y);
        validRatios++;
      }
    }

    if (validRatios == 0) return 1.0;

    final averageRatio = totalRatio / validRatios;

    // For carousel, prefer slightly square ratios for consistency
    // but still respect the content
    if (averageRatio > 1.5) return 1.5; // Limit wide ratios
    if (averageRatio < 0.75) return 0.75; // Limit tall ratios

    return averageRatio;
  }

  Widget buildMediaItem(FileElement file, BuildContext context) {
    if (isVideo(file)) {
      final videoUrl = file.file ?? '';
      final preciseAspectRatio = calculateAspectRatio(
        file.x,
        file.y,
        fallback: 16 / 9,
      );

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AutoPlayVideoPlayer(
          videoUrl: videoUrl,
          postId: postId,
          aspectRatio: preciseAspectRatio,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageView(
          file.file!,
          context: context,
          height: file.y,
          width: file.x,
        ),
      );
    }
  }

  /// Build media item specifically for carousel to prevent overflow
  Widget buildMediaItemForCarousel(FileElement file, BuildContext context) {
    if (isVideo(file)) {
      final videoUrl = file.file ?? '';
      final preciseAspectRatio = calculateAspectRatio(
        file.x,
        file.y,
        fallback: 16 / 9,
      );

      return AutoPlayVideoPlayer(
        videoUrl: videoUrl,
        postId: postId,
        aspectRatio: preciseAspectRatio,
      );
    } else {
      return imageViewForCarousel(
        file.file!,
        context: context,
        height: file.y,
        width: file.x,
      );
    }
  }

  Widget imageView(
    String url, {
    double? height,
    double? width,
    BuildContext? context,
  }) {
    // Calculate responsive sizing
    final screenHeight = MediaQuery.of(navState.currentContext!).size.height;
    final screenWidth = MediaQuery.of(navState.currentContext!).size.width;
    final maxHeight = screenHeight * 0.65; // Max 65% of screen height

    // For images with known dimensions, calculate optimal size
    if (height != null && width != null && height > 0 && width > 0) {
      // Calculate display dimensions while respecting aspect ratio
      double displayHeight = height;
      double displayWidth = width;

      // More precise scaling calculation
      final scaleForHeight = maxHeight / height;
      final scaleForWidth = screenWidth / width;
      final optimalScale = (scaleForHeight < scaleForWidth)
          ? scaleForHeight
          : scaleForWidth;

      // Apply scaling only if needed (image is larger than constraints)
      if (optimalScale < 1.0) {
        displayHeight = height * optimalScale;
        displayWidth = width * optimalScale;
      }

      // Final safety check to ensure we don't exceed screen bounds
      if (displayHeight > maxHeight) {
        final heightScale = maxHeight / displayHeight;
        displayHeight = maxHeight;
        displayWidth = displayWidth * heightScale;
      }

      if (displayWidth > screenWidth) {
        final widthScale = screenWidth / displayWidth;
        displayWidth = screenWidth;
        displayHeight = displayHeight * widthScale;
      }

      // Use Container with flexible constraints to adjust to image dimensions
      return Container(
        constraints: BoxConstraints(
          maxHeight: displayHeight,
          maxWidth: displayWidth,
          minHeight: 100,
          minWidth: 100,
        ),
        child: _PinchGestureHandler(
          child: SizedImage(
            maxHeight: displayHeight,
            maxWidth: displayWidth,
            size: ui.Size(displayWidth, displayHeight),
            url: url.fileUrl ?? '',
          ),
        ),
      );
    }

    // For images without known dimensions, use flexible sizing with constraints
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        maxWidth: screenWidth,
        minHeight: 100, // Minimum height for unknown dimension images
      ),
      child: _PinchGestureHandler(
        child: Image.network(
          url.fileUrl ?? '',
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                color: Colors.white,
                width: double.infinity,
                height: 200,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 150,
              child: Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Image view specifically designed for carousel to prevent overflow
  Widget imageViewForCarousel(
    String url, {
    double? height,
    double? width,
    BuildContext? context,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: _PinchGestureHandler(
        child: Image.network(
          url.fileUrl ?? '',
          fit: BoxFit
              .cover, // Use cover to fill the container and prevent overflow
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSingleImage = imageUrls.isNotEmpty && imageUrls.length == 1;
    final screenHeight = MediaQuery.of(context).size.height;

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            Visibility(
              visible: caption.isNotNullEmpty,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: ReadMoreText(text: caption),
              ),
            ),

            if (imageUrls.isNotEmpty)
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.7,
                    minHeight:
                        100, // Minimum height to prevent too small images
                  ),
                  child: isSingleImage
                      ? buildMediaItem(imageUrls[0], context)
                      : Container(
                          height:
                              screenHeight *
                              0.5, // Fixed height for carousel to prevent overflow
                          child: PageView.builder(
                            scrollDirection: Axis.horizontal,
                            controller: _pageController,
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2.0,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: buildMediaItemForCarousel(
                                    imageUrls[index],
                                    context,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),

            SizedBox(height: 10),
            if (imageUrls.length > 1)
              Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: imageUrls.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.btnColor,
                    dotColor: AppColors.Grey,
                    dotHeight: 4,
                    dotWidth: 10,
                  ),
                ),
              ),

            footer,
          ],
        ),
      ),
    );
  }
}

class _PinchGestureHandler extends StatefulWidget {
  final Widget child;
  const _PinchGestureHandler({required this.child});

  @override
  State<_PinchGestureHandler> createState() => _PinchGestureHandlerState();
}

class _PinchGestureHandlerState extends State<_PinchGestureHandler> {
  @override
  Widget build(BuildContext context) {
    return PinchZoom(maxScale: 3.5, child: widget.child);
  }
}

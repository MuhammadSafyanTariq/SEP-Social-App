import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/auto_play_video_player.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_card_header.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/read_more_text.dart';
import 'package:sep/main.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../utils/image_utils.dart';
import '../../../data/models/dataModels/post_data.dart';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';

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

  Widget buildMediaItem(FileElement file, BuildContext context) {
    if (isVideo(file)) {
      final videoUrl = file.file ?? '';

      return AutoPlayVideoPlayer(
        videoUrl: videoUrl,
        postId: postId,
        aspectRatio: (file.x != null && file.y != null)
            ? file.x! / file.y!
            : 16 / 9,
      );
    } else {
      return imageView(
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
    // Allow images to be taller - use 80% of screen height as max
    final defaultHeight =
        MediaQuery.of(navState.currentContext!).size.height * 0.8;

    return false
        ? InteractiveViewer(
            panEnabled: true,
            minScale: 1,
            maxScale: 4,
            child: height != null && width != null
                ? SizedImage(
                    maxHeight: context!.getHeight,
                    maxWidth: context.getWidth,
                    size: ui.Size(width, height),
                    url: url.fileUrl ?? '',
                  )
                : Image.network(
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
                          height: MediaQuery.of(context).size.height * 0.4,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
          )
        : true
        ? _PinchGestureHandler(
            child: height != null && width != null
                ? SizedImage(
                    // maxHeight: height,
                    maxHeight: height < defaultHeight ? height : defaultHeight,
                    // maxHeight: context!.getWidth,
                    maxWidth: context!.getWidth,
                    size: ui.Size(width, height),
                    url: url.fileUrl ?? '',
                  )
                : Image.network(
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
                          height: defaultHeight,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
          )
        : GestureDetector(
            behavior: HitTestBehavior.translucent, // lets touches pass through
            // onVerticalDragUpdate: (_) {},
            child: PinchZoom(
              maxScale: 3.5,

              child: height != null && width != null
                  ? SizedImage(
                      maxHeight: context!.getHeight,
                      maxWidth: context.getWidth,
                      size: ui.Size(width, height),
                      url: url.fileUrl ?? '',
                    )
                  : Image.network(
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
                            height: MediaQuery.of(context).size.height * 0.4,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              isSingleImage
                  ? buildMediaItem(imageUrls[0], context)
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: _pageController,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return buildMediaItem(imageUrls[index], context);
                        },
                      ),
                    ),

            10.height,
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
  const _PinchGestureHandler({super.key, required this.child});

  @override
  State<_PinchGestureHandler> createState() => _PinchGestureHandlerState();
}

class _PinchGestureHandlerState extends State<_PinchGestureHandler> {
  RxBool canPinch = RxBool(false);

  @override
  Widget build(BuildContext context) {
    return true
        ? PinchZoom(maxScale: 3.5, child: widget.child)
        : true
        ? RawGestureDetector(
            gestures: {
              ScaleGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
                    () => ScaleGestureRecognizer(),
                    (instance) {
                      instance.onStart = (details) {
                        print("Scale Start");
                      };
                      instance.onUpdate = (details) {
                        print("Scale Update: scale=${details.scale}");
                      };
                      instance.onEnd = (details) {
                        print("Scale End");
                      };
                    },
                  ),
            },
            child: Obx(
              () => PinchZoom(
                zoomEnabled: canPinch.value,
                maxScale: 3.5,
                child: widget.child,
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              AppUtils.log('callling here', show: true);
            },
            onScaleStart: (value) {},
            onScaleEnd: (value) {},
            onScaleUpdate: (details) {
              if (details.scale > 1.0 || details.scale < 1.0) {
                print("Pinch Out (Zoom In)");
                canPinch.value = true;
              } else if (details.scale < 1.0) {
                print("Pinch In (Zoom Out)");
              }

              // Detect linear move (no pinch, just drag)
              if (details.scale == 1.0 &&
                  details.focalPointDelta.distance > 0) {
                print("Linear pan/scroll");

                canPinch.value = false;
              }

              AppUtils.log('callling here.....', show: true);
            },
            child: Obx(
              () => PinchZoom(
                zoomEnabled: canPinch.value,
                maxScale: 3.5,
                child: widget.child,
              ),
            ),
          );
  }
}

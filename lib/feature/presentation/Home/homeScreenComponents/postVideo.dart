import 'package:flutter/material.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/auto_play_video_player.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_card_header.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/read_more_text.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/videoPlayerScreen.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';

class PostVideo extends StatelessWidget {
  final PostCardHeader header;
  final Widget footer;
  final VoidCallback? view;
  final PostData data;
  const PostVideo({
    super.key,
    required this.header,
    required this.footer,
    this.view,
    required this.data,
  });

  FileElement? get file => data.files.first;
  String? get caption => data.content;
  String? get videoUrl => data.files.first.file;
  String? get postId => data.id;

  @override
  Widget build(BuildContext context) {
    AppUtils.log(file?.thumbnail.fileUrl ?? '');

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Card(
        margin: 10.all,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            10.height,
            Visibility(
              visible: data.content.isNotNullEmpty,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 8),
                child: ReadMoreText(text: data.content ?? ''),
              ),
            ),
            10.height,
            SizedBox(
              width: context.getWidth,
              child: GestureDetector(
                onTap: () async {
                  // Navigate to full screen video player
                  final result = await context.pushNavigator(
                    VideoPlayerScreen(
                      videoUrl: videoUrl!.fileUrl!,
                      postId: postId,
                    ),
                  );
                  if (result == true && view != null) {
                    view!();
                  }
                },
                child: AutoPlayVideoPlayer(
                  videoUrl: videoUrl?.fileUrl ?? '',
                  postId: postId ?? '',
                  aspectRatio: (file?.x != null && file?.y != null)
                      ? file!.x! / file!.y!
                      : 16 / 9,
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

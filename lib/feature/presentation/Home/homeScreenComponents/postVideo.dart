import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/auto_play_video_player.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_card_header.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/read_more_text.dart';
import 'package:sep/feature/presentation/Home/reels_video_screen.dart';
import 'package:sep/feature/presentation/profileScreens/setting/fullScreenVideoPlayer.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
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
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () async {
                      // Get all video posts from global post list
                      final allVideoPosts = ProfileCtrl.find.globalPostList
                          .where(
                            (post) =>
                                post.files.isNotEmpty &&
                                post.files.first.type == 'video' &&
                                post.files.first.file?.isNotEmpty == true,
                          )
                          .toList();

                      if (allVideoPosts.isNotEmpty) {
                        // Find the index of current video post
                        final clickedIndex = allVideoPosts.indexWhere(
                          (post) => post.id == data.id,
                        );

                        // Navigate to Instagram-like reels screen
                        final result = await context.pushNavigator(
                          ReelsVideoScreen(
                            initialPosts: allVideoPosts,
                            initialIndex: clickedIndex >= 0 ? clickedIndex : 0,
                          ),
                        );

                        if (result == true && view != null) {
                          view!();
                        }
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

                  // Full screen icon button in bottom right corner
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () async {
                        // Get all video URLs from video posts
                        final allVideoUrls = ProfileCtrl.find.globalPostList
                            .where(
                              (post) =>
                                  post.files.isNotEmpty &&
                                  post.files.first.type == 'video' &&
                                  post.files.first.file?.isNotEmpty == true,
                            )
                            .map(
                              (post) => AppUtils.configImageUrl(
                                post.files.first.file!.fileUrl ?? '',
                              ),
                            )
                            .where((url) => url.isNotEmpty)
                            .toList();

                        if (allVideoUrls.isNotEmpty &&
                            videoUrl?.fileUrl != null) {
                          final currentVideoUrl = AppUtils.configImageUrl(
                            videoUrl!.fileUrl!,
                          );
                          final clickedIndex = allVideoUrls.indexOf(
                            currentVideoUrl,
                          );

                          // Navigate to full screen video player
                          await context.pushNavigator(
                            FullScreenVideoPlayer(
                              videoUrls: allVideoUrls,
                              initialIndex: clickedIndex >= 0
                                  ? clickedIndex
                                  : 0,
                            ),
                          );

                          if (view != null) {
                            view!();
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            footer,
          ],
        ),
      ),
    );
  }
}

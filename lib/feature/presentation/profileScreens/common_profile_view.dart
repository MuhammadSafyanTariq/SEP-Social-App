import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/presentation/widgets/profile_image.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../../../components/coreComponents/AppButton.dart';
import '../../../components/coreComponents/TextView.dart';
import '../../../components/coreComponents/editProfileImage.dart';
import '../../../components/styles/appColors.dart';
import '../../../core/core/model/imageDataModel.dart';
import '../../../services/networking/urls.dart';
import '../../data/models/dataModels/post_data.dart';
import '../Home/homeScreenComponents/pollCard.dart';
import '../Home/homeScreenComponents/post_components.dart';
import '../chatScreens/Messages_Screen.dart';
import '../controller/auth_Controller/profileCtrl.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class CommonProfileView extends StatefulWidget {
  final List<String> tabsss;
  final RxDouble collapseHeight;
  final TabController tabController;
  final GlobalKey dynamicContentKey;
  final ProfileDataModel userData;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final ImageDataModel imageData;
  final Future Function()? getFollowers;
  final Future Function()? getFollowing;
  final RxList<PostData>? imagePosts;
  final RxList<PostData>? videoPosts;
  final List<PostData> polls;
  final PreferredSizeWidget? appBar;
  final Function(int) onImagePostTap;
  final Function(List<String>, int) onVideoPostTap;
  final Function(String, int) pollLikeAction;
  final Function(String, int?) onUpdatePollAction;
  final Function(int) onRemovePollAction;
  final Function(PostData, String) onPollAction;
  final VoidCallback? onLiveStreamingOnTap;
  final VoidCallback? onViewFriendStream;
  final bool? isFriend;
  final Function()? followAction;
  final bool isMyProfile;

  const CommonProfileView(
      {super.key,
      required this.tabsss,
      required this.collapseHeight,
      required this.tabController,
      required this.dynamicContentKey,
      required this.userData,
      required this.followersCount,
      required this.followingCount,
      required this.postsCount,
      required this.imageData,
       this.getFollowers,
       this.getFollowing,
       this.imagePosts,
       this.videoPosts,
      required this.polls,
      this.appBar,
      required this.onImagePostTap,
      required this.onVideoPostTap,
      required this.pollLikeAction,
      required this.onUpdatePollAction,
      required this.onRemovePollAction,
      required this.onPollAction,
      this.isFriend,
      this.followAction,
      required this.isMyProfile, this.onLiveStreamingOnTap, this.onViewFriendStream});

  @override
  State<CommonProfileView> createState() => _CommonProfileViewState();
}

final ProfileCtrl profileCtrl = ProfileCtrl.find;

String _formatTimeAgo(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '';
  try {
    final dateTime = DateTime.parse(dateString);
    return 'Joined ${timeago.format(dateTime)}';
  } catch (e) {
    return '';
  }
}

class _CommonProfileViewState extends State<CommonProfileView> {

  bool socketConnectionFlag = false;

  Widget profileInfo() {
    return Container(
      key: widget.dynamicContentKey,
      child: Padding(
        padding: 15.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Visibility(
                visible: widget.isMyProfile == true,
                child: GestureDetector(
                  onTap: widget.onLiveStreamingOnTap,
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        ImageView(url: AppImages.getLiveBtn,size: 25,),
                        TextView(text: ' GO LIVE', style: 14.txtBoldBtncolor,)
                      ],
                    ),
                  ),
                )



              // AppButton(
              //   padding: 7.top + 7.bottom,
              //   prefix: ImageView(url: AppImages.getLiveBtn,size: 30,),
              //   radius: 10.sdp,
              //   buttonColor: AppColors.white,
              //   buttonBorderColor: AppColors.btnColor,
              //   label: "Start Live Streaming",
              //   labelStyle: 14.txtBoldBtncolor,
              //   margin: 10.top,
              //   onTap: widget.onLiveStreamingOnTap,
              // ),
            ),
            // SizedBox(height: 10,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.sdp),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Column(
                    children: [

                      GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierColor: Colors.transparent,
                              barrierDismissible: true,
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    color: Colors.black,
                                    alignment: Alignment.center,
                                    child: InteractiveViewer(
                                      panEnabled: true,
                                      minScale: 1.0,
                                      maxScale: 3.5,
                                      child: _buildZoomableImage(widget.imageData),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: 12.left + 10.top,
                            child: ProfileImage(
                              image: widget.userData.image.fileUrl,
                              uid: widget.userData.id,
                              socketConnection: socketConnectionFlag,
                              onTap: (){
                                if(widget.userData.image.fileUrl.isNotNullEmpty){
                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.black87,
                                    builder: (context) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: EdgeInsets.all(10),
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: PhotoView(
                                              imageProvider: NetworkImage(widget.userData.image.fileUrl!),
                                              backgroundDecoration: BoxDecoration(color: Colors.transparent),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }

                              },
                            )






                            // widget.userData.image.fileUrl != null
                            //     ? InkWell(
                            //   onTap: () {
                            //     showDialog(
                            //       context: context,
                            //       barrierColor: Colors.black87,
                            //       builder: (context) {
                            //         return Dialog(
                            //           backgroundColor: Colors.transparent,
                            //           insetPadding: EdgeInsets.all(10),
                            //           child: GestureDetector(
                            //             onTap: () => Navigator.pop(context),
                            //             child: ClipRRect(
                            //               borderRadius: BorderRadius.circular(8),
                            //               child: PhotoView(
                            //                 imageProvider: NetworkImage(widget.userData.image.fileUrl!),
                            //                 backgroundDecoration: BoxDecoration(color: Colors.transparent),
                            //               ),
                            //             ),
                            //           ),
                            //         );
                            //       },
                            //     );
                            //   },
                            //   child: ClipOval(
                            //     child: widget.userData.image.fileUrl != null &&
                            //         widget.userData.image.fileUrl!.isNotNullEmpty
                            //         ? ImageView(
                            //       url: widget.userData.image.fileUrl ?? '',
                            //       defaultImage: AppImages.dummyProfile,
                            //       size: 80.sdp,
                            //       imageType: ImageType.network,
                            //       fit: BoxFit.cover,
                            //     )
                            //         : Shimmer.fromColors(
                            //       baseColor: Colors.grey.shade300,
                            //       highlightColor: Colors.grey.shade100,
                            //       child: Container(
                            //         width: 80.sdp,
                            //         height: 80.sdp,
                            //         decoration: BoxDecoration(
                            //           shape: BoxShape.circle,
                            //           color: Colors.white,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // )
                            //     : ImageView(
                            //   url: AppImages.editProfileImg,
                            //   size: 80.sdp,
                            // ),
                          )
                      ),
                      // SizedBox(height: 10,),

                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          margin: 10.top + 3.bottom + 20.left,
                          text: widget.userData.name ?? "",
                          style: 18.txtSBoldprimary,
                        ),
                        Visibility(
                          visible: (widget.userData.bio ?? "").isNotNullEmpty,
                          child: TextView(
                            margin: 3.bottom + 20.left,
                            text: widget.userData.bio ?? "",
                            // text: "sales360.xyz is LIVE and we will move files and tables when done with final testing on test API"
                            //     "We found in our review that your app includes user-generated content but does not have all the required precautions. Apps with user-generated content must take specific steps to moderate content and prevent abusive behavior.",
                            style: 13.txtRegularprimary,
                            maxlines: 3,
                          ),
                        ),
                        Visibility(
                          visible:
                              (widget.userData.website ?? "").isNotNullEmpty,
                          child: GestureDetector(
                            onTap: () {
                              launchUrl(Uri.parse(widget.userData.website!));
                            },
                            child: Padding(
                              padding: 3.bottom + 20.left,
                              child: Row(
                                children: [
                                  Image.asset(
                                    AppImages.attachFile,
                                    color: AppColors.primaryBlue,
                                    height: 10.sdp,
                                    width: 10.sdp,
                                  ),
                                  // ImageView(url: AppImages.attachFile,
                                  //   size: 10,
                                  //   margin: 3.right,
                                  // ),
                                  5.width,
                                  Expanded(
                                    child: TextView(
                                      text: (widget.userData.website ?? ""),
                                      style: 13.txtRegularblue,
                                      maxlines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TextView(
                          margin: 3.bottom + 20.left,
                          text: _formatTimeAgo(widget.userData.createdAt),
                          style: 14.txtRegularprimary,
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),


      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.03,
              top: MediaQuery.of(context).size.height * 0.015,
            ),
            child: Column(
              children: [
                TextView(
                  text: '${widget.postsCount ?? 0}',
                  style: 14.txtSBoldprimary,
                ),
                SizedBox(width: 10),
                TextView(
                  text: 'Posts',
                  style: 16.txtSBoldprimary,
                ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.03,
                    top: MediaQuery.of(context).size.height * 0.015,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextView(
                        text: '${widget.followersCount}',
                        style: 14.txtSBoldprimary,
                      ),
                      SizedBox(width: 10),
                      TextView(
                        text: 'Linked Me',
                        style: 16.txtSBoldprimary,
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      widget.getFollowers!();
                    },
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.03,
              top: MediaQuery.of(context).size.height * 0.015,
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    TextView(
                      text: '${widget.followingCount}',
                      style: 14.txtSBoldprimary,
                    ),
                    SizedBox(width: 10),
                    TextView(
                      text: 'Link Ups',
                      style: 16.txtSBoldprimary,
                    ),
                  ],
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      widget.getFollowing!();
                    },
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),


            Visibility(
              visible: !(widget.isFriend ?? false) && !widget.isMyProfile,
              child: AppButton(
                margin: 15.top,
                onTap: () {
                  widget.followAction?.call();
                },
                labelStyle: 14.txtRegularprimary,
                buttonColor: AppColors.white,
                buttonBorderColor: AppColors.primaryColor,
                padding: 10.vertical,
                radius: 10,
                label: 'Link Up',
              ),
            ),
            // if(widget.userData.isActive == true && (widget.isFriend ?? false))
            if(false)
              AppButton(
                // prefix: ImageView(url: AppImages.getLiveBtn,size: 30,),
                radius: 10.sdp,
                buttonColor: AppColors.white,
                buttonBorderColor: AppColors.btnColor,
                label:  "View Live Streaming",
                labelStyle: 14.txtBoldBtncolor,
                margin: 10.top,
                onTap:   widget.onViewFriendStream,
              ),

            // Visibility(
            //   visible: widget.isMyProfile == true,
            //   child: AppButton(
            //     padding: 7.top + 7.bottom,
            //     prefix: ImageView(url: AppImages.getLiveBtn,size: 30,),
            //     radius: 10.sdp,
            //     buttonColor: AppColors.white,
            //     buttonBorderColor: AppColors.btnColor,
            //     label: "Start Live Streaming",
            //     labelStyle: 14.txtBoldBtncolor,
            //     margin: 10.top,
            //     onTap: widget.onLiveStreamingOnTap,
            //   ),
            // ),
            Visibility(
              visible: (widget.isFriend ?? false) && !widget.isMyProfile,
              child: Padding(
                padding: 15.top,
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        onTap: () async {
                          widget.followAction?.call();
                        },
                        labelStyle: 14.txtRegularprimary,
                        buttonColor: AppColors.white,
                        padding: 10.vertical,
                        radius: 10,
                        buttonBorderColor: AppColors.primaryColor,
                        label: 'Linked',
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: AppButton(
                        onTap: () {
                          context.pushNavigator(MessageScreen(
                            data: widget.userData,
                          ));
                        },
                        labelStyle: 14.txtRegularprimary,
                        buttonColor: AppColors.white,
                        padding: 10.vertical,
                        radius: 10,
                        buttonBorderColor: AppColors.primaryColor,
                        label: 'Message',
                      ),
                    ),
                    20.height,

                  ],

                ),
              ),
            ),

      ],
        ),
      ),
    );
  }

  Widget _buildZoomableImage(ImageDataModel imageData) {
    Widget imageWidget;
    switch (imageData.type) {
      case ImageType.network:
        imageWidget = Image.network(
          imageData.network ?? '',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        );
        break;
      case ImageType.file:
        imageWidget = Image.file(
          File(imageData.file ?? ''),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        );
        break;
      case ImageType.asset:
        imageWidget = Image.asset(
          imageData.asset ?? '',
          fit: BoxFit.contain,
        );
        break;
      default:
        imageWidget = const Icon(Icons.image_not_supported);
    }

    return InteractiveViewer(
      panEnabled: true,
      minScale: 1.0,
      maxScale: 3.5,
      child: imageWidget,
    );
  }

  Widget tabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          List.generate(widget.tabsss.length, (index) => _buildTab(index)),
    );
  }

  Widget _buildTab(int index) {
    bool isSelected = widget.tabController.index == index;
    Color backgroundColor = isSelected ? Colors.green : Colors.black;
    Color borderColor =
        isSelected ? Colors.green : Colors.grey.withOpacity(0.1);
    Color textColor = isSelected ? Colors.white : Colors.white;

    return GestureDetector(
      onTap: () {
        setState(() {
          widget.tabController.animateTo(index);
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.01),
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.01,
          horizontal: MediaQuery.of(context).size.width * 0.065,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius:
              BorderRadius.circular(MediaQuery.of(context).size.width * 0.04),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Text(
          widget.tabsss[index],
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.035,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    AppUtils.log(widget.imageData.network);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.tabsss.length,
      child: Scaffold(
        appBar: widget.appBar,
        backgroundColor: Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            Obx(
              () => SliverAppBar(
                leading: SizedBox(),
                pinned: true,
                floating: true,
                snap: true,
                expandedHeight: widget.collapseHeight.value + 10,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: [
                      profileInfo(),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const ui.Size.fromHeight(50),
                  child: tabs(),
                ),
              ),
            ),
          ],
          body: TabBarView(
            physics: const BouncingScrollPhysics(),
            controller: widget.tabController,
            children: [
              _buildGridView(widget.imagePosts!),
              _buildGridViewVideo(widget.videoPosts!),
              _buildPollListView(widget.polls),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(RxList<PostData> imagePosts) {
    return Obx(() {
      if (!Get.isRegistered<ProfileCtrl>()) {
        return const SizedBox();
      }

      // final imagePosts = profileCtrl.profileImagePostList;

      if (imagePosts.isEmpty) {
        return Center(
          child: TextView(
            text: "No post available",
            style: 16.txtSBoldprimary,
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: imagePosts.length,
        padding: 20.top + 20.left + 20.right,
        itemBuilder: (context, index) {
          final post = imagePosts[index];
          String filePath = post.files?.first.file ?? '';
          String finalImageUrl =
              filePath.startsWith("http") ? filePath : "$baseUrl$filePath";
          AppUtils.log(">>>>>>>?????$finalImageUrl");

          return GestureDetector(
            onTap: () => widget.onImagePostTap(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                height: 100,
                width: 100,
                finalImageUrl,
                fit: BoxFit.cover,
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

              // CachedNetworkImage(
              //   imageUrl: finalImageUrl,
              //   fit: BoxFit.cover,
              //   height: 100.sdp,
              //   width: 100.sdp,
              //   placeholder: (context, url) => Shimmer.fromColors(
              //     baseColor: Colors.grey.shade300,
              //     highlightColor: Colors.grey.shade100,
              //     child: Container(
              //       height: 100.sdp,
              //       width: 100.sdp,
              //       color: Colors.white,
              //     ),
              //   ),
              //   errorWidget: (context, url, error) => Icon(Icons.error),
              // ),
            ),
          );
        },
      );
    });
  }

  Widget _buildGridViewVideo(RxList<PostData> videoPosts) {
    return Obx(() {
      if (!Get.isRegistered<ProfileCtrl>()) {
        return const SizedBox();
      }

      if (videoPosts.isEmpty) {
        return Center(
          child: TextView(
            text: "No post available",
            style: 16.txtSBoldprimary,
          ),
        );
      }

      final videoUrls = <String>[];

      for (var post in videoPosts) {
        if (post.files?.isNotEmpty ?? false) {
          String? filePath = post.files?.first.file;
          if (filePath != null && filePath.isNotEmpty) {
            String ext = filePath.split('.').last.toLowerCase();

            final isVideoFormat = ext.contains("mp4") ||
                ext.contains("mov") ||
                ext.contains("MOV") ||
                ext.contains("avi");

            if (isVideoFormat) {
              if (filePath.startsWith("http")) {
                videoUrls.add(filePath);
              } else if (filePath.startsWith("/public/uploads/") ||
                  filePath.startsWith("/")) {
                videoUrls.add("$baseUrl$filePath");
              }
            }
          }
        }
      }

      return GridView.builder(
        shrinkWrap: true,
        padding: 20.top + 20.left + 20.right,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          final videoUrl = videoUrls[index];

          return FutureBuilder<Uint8List?>(
            future: AppUtils.getVideoThumbnail(videoUrl),
            builder: (context, snapshot) {
              AppUtils.log('builder process::: ${snapshot.connectionState}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasError || snapshot.data == null) {
                return const SizedBox();
              }

              return GestureDetector(
                onTap: () => widget.onVideoPostTap(videoUrls, index),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.sdp),
                    child: Image.memory(
                      snapshot.data!,
                      height: 100.sdp,
                      width: 100.sdp,
                      fit: BoxFit.cover,
                    )
                    ),
              );
            },
          );
        },
      );
    });
  }

  Widget _buildPollListView(List<PostData> videoPosts) {
    final ProfileCtrl profileCtrl = ProfileCtrl.find;
    return Obx(() {
      if (!Get.isRegistered<ProfileCtrl>()) {
        return const SizedBox();
      }

      // final videoPosts = profileCtrl.profilePollPostList;

      if (videoPosts.isEmpty) {
        return Center(
          child: TextView(
            text: "No Polls Available",
            style: 16.txtSBoldprimary,
          ),
        );
      }

      final videoUrls = <String>[];

      videoUrls.add(
          "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4");

      for (var post in videoPosts) {
        if (post.files?.isNotEmpty ?? false) {
          String? filePath = post.files?.first.file;
          if (filePath != null && filePath.isNotEmpty) {
            if (filePath.startsWith("http")) {
              videoUrls.add(filePath);
            } else if (filePath.startsWith("/public/uploads/") ||
                filePath.startsWith("/")) {
              videoUrls.add("$baseUrl$filePath");
            }
          }
        }
      }

      return ListView.separated(
          padding: EdgeInsets.only(top: 20),
          itemBuilder: (context, index) {
            final item = videoPosts[index];

            final footer = postFooter(
              context: context,
              item: item,
              postLiker: (value) async {
                widget.pollLikeAction(item.id ?? '', index);
              },
              updateCommentCount: (value) {},
              updatePostOnAction: (commentCount) {
                final postId = item.id!;
                profileCtrl.getSinglePostData(postId).then((value) {
                  final index = profileCtrl.globalPostList
                      .indexWhere((element) => element.id == postId);
                  if (index > -1) {
                    profileCtrl.globalPostList[index] = value.copyWith(
                        user: profileCtrl.globalPostList[index].user,
                        commentCount: commentCount ?? 0);
                    profileCtrl.globalPostList.refresh();
                  }
                });
              },
            );
            ;
            return PollCard(
              footer: footer,
              data: item,
              header: postCardHeader(item,
                  onRemovePostAction: () => widget.onRemovePollAction(index)),
              question: item.content ?? '',
              options: item.options ?? [],
              onPollAction: (String optionId) {
                widget.onPollAction(item, optionId);
              },
            );
          },
          separatorBuilder: (context, index) => SizedBox(
                height: 10,
              ),
          itemCount: videoPosts.length);
    });
  }
}

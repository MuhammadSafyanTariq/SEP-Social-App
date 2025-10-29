import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/home_model/comments_list_model.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/presentation/profileScreens/friend_profile_screen.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import '../../../components/coreComponents/ImageView.dart';
import '../../../components/coreComponents/TextView.dart';
import '../../../components/coreComponents/appBSheet.dart';
import '../../../components/coreComponents/editProfileImage.dart';
import '../../../components/styles/appColors.dart';
import '../../../components/styles/appImages.dart';
import '../controller/auth_Controller/profileCtrl.dart';
import 'homeScreenComponents/postVideo.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  final Function(int?)? updatePostOnAction;
  final Function(int) onCommentAdded;

  const CommentScreen({
    super.key,
    required this.postId,
    required this.onCommentAdded,
    this.updatePostOnAction,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final ProfileCtrl profileCtrl = ProfileCtrl.find;
  final RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMorePosts();
  }

  bool isLoadingMore = false;

  Future<void> _loadMorePosts() async {
    await profileCtrl.comentLists(selectedId: widget.postId).applyLoader;
    widget.updatePostOnAction?.call(profileCtrl.comentslistdata.length);
    refreshController.isRefresh;
    return;
  }

  Rx<bool> messageEnable = Rx(true);
  FocusNode commentBoxFocusNode = FocusNode();

  void _submitComment() async {
    messageEnable.value = false;
    if (commentController.getText.isNotNullEmpty) {
      try {
        await sendMessage(msg: commentController.getText).then((value) {
          commentController.clear();
        });
      } finally {
        messageEnable.value = true;
      }
    }
  }

  void sendMediaFile(String value, String fileType) async {
    await sendMessage(file: value, fileType: fileType).then((value) {});
  }

  Future sendMessage({String? msg, String? file, String? fileType}) async {
    final replyToData = replyForComment.value;
    replyForComment.value = null;

    await profileCtrl
        .commentsPost(
          postId: widget.postId ,
          content: msg,
          mediaFile: file,
          fileType: fileType,
          parentId: replyToData?.parentId ?? replyToData?.id,
          replyToUser: replyToData?.userId?.id,
        )
        .then((value) {
          CommentsListModel? item = profileCtrl.comentslistdata
              .firstWhereOrNull((element) => element.id == value.parentId);
          if (value.parentId != null && item != null) {
            final index = profileCtrl.comentslistdata.indexWhere(
              (element) => element.id == value.parentId,
            );
            List<CommentsListModel> list = [...(item.child ?? [])];
            list.add(value);
            profileCtrl.comentslistdata[index] = item.copyWith(child: list);
          } else {
            profileCtrl.comentslistdata.add(value);
          }
          profileCtrl.comentslistdata.refresh();
          widget.updatePostOnAction?.call(profileCtrl.comentslistdata.length);
          int newCommentCount = profileCtrl.comentslistdata.length;
          widget.onCommentAdded(newCommentCount);
        });

    return;
  }

  @override
  void dispose() {
    widget.updatePostOnAction?.call(profileCtrl.comentslistdata.length);
    profileCtrl.comentslistdata.clear();
    super.dispose();
  }

  Rx<CommentsListModel?> replyForComment = Rx(null);

  Widget commentCard(CommentsListModel comment) {
    return Column(
      children: [
        Container(
          color: AppColors.white,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageView(
                  onTap: () {
                    if (Preferences.uid != comment.userId?.id) {
                      context.replaceNavigator(
                        FriendProfileScreen(
                          data: ProfileDataModel(
                            image: comment.userId?.image,
                            name: comment.userId?.name,
                            id: comment.userId?.id,
                          ),
                        ),
                      );
                    }
                  },
                  url: AppUtils.configImageUrl(comment.userId?.image ?? ''),
                  size: 40,
                  radius: 20,
                  imageType: ImageType.network,
                  defaultImage: AppImages.dummyProfile,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: comment.userId?.name.toString() ?? 'Unknown User',
                        style: 14.txtMediumBlack,
                      ),
                      SizedBox(height: 3),

                      Visibility(
                        visible: comment.content.isNotNullEmpty,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    (comment.replyToUser?.name ?? '')
                                        .isNotNullEmpty
                                    ? '@${comment.replyToUser!.name} '
                                    : '',
                                style: 12.txtshare,
                              ),
                              TextSpan(
                                text:
                                    '${comment.content}.' ??
                                    'No content available',
                                style: 12.txtRegularprimary,
                              ),
                              TextSpan(
                                text: " Reply",
                                style: 12.txtmarkread,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    commentBoxFocusNode.requestFocus();
                                    replyForComment.value = comment;
                                  },
                              ),
                            ],
                          ),
                        ),
                        // Row(
                        //   children: [
                        //     TextView(
                        //       style: 12.txtRegularprimary,
                        //       text: '${comment.content}.' ??
                        //           'No content available',
                        //     ),
                        //     TextView(
                        //       text: " Reply",
                        //       style: 12.txtmarkread,
                        //       onTap: () {
                        //         commentBoxFocusNode
                        //             .requestFocus();
                        //         replyForComment.value = comment;
                        //       },
                        //     )
                        //   ],
                        // ),
                      ),
                      SizedBox(
                        child: (comment.files ?? []).isNotEmpty
                            ? (comment.files?[0].type == 'image'
                                  ? GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => FullImageScreen(
                                              imageUrl:
                                                  baseUrl +
                                                  (comment.files?[0].file ??
                                                      ''),
                                            ),
                                          ),
                                        );
                                      },
                                      child: ImageView(
                                        url:
                                            baseUrl +
                                            (comment.files?[0].file ?? ''),
                                        size: 80,
                                        imageType: ImageType.network,
                                      ),
                                    )
                                  : SizedBox(
                                      height: 80,
                                      child: VideoCardPlayer(
                                        videoUrl:
                                            '$baseUrl${comment.files?[0].file ?? ''}',
                                        // videoUrl: '$baseUrl${'/public/uploads/2.mp4'}',
                                        postId: widget.postId,
                                      ),
                                    ))
                            : null,
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: comment.userId?.id == Preferences.uid,
                  child: GestureDetector(
                    onTap: () {
                      profileCtrl
                          .removeHomePostComment(comment.id ?? '')
                          .applyLoader
                          .then((value) {
                            profileCtrl.comentslistdata.removeWhere(
                              (element) => element.id == comment.id,
                            );
                            profileCtrl.comentslistdata.refresh();
                            widget.updatePostOnAction?.call(
                              profileCtrl.comentslistdata.length,
                            );
                          });
                    },
                    child: ImageView(url: AppImages.delete, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: (comment.child ?? []).isNotEmpty,
          child: ListView.separated(
            padding: EdgeInsets.only(left: 40),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => commentCard(comment.child![index]),
            separatorBuilder: (context, index) => SizedBox(),
            itemCount: (comment.child ?? []).length,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.newgrey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(text: 'Comments', style: 18.txtMediumBlack),
                const SizedBox(height: 5),
                Obx(
                  () => TextView(
                    text:
                        "${profileCtrl.comentslistdata.length} people commented",
                    style: 12.txtRegularGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            final list = profileCtrl.comentslistdata.reversed.toList();

            if (list.isEmpty) {
              return Center(
                child: TextView(
                  text: "No comments yet",
                  style: 14.txtRegularGrey,
                ),
              );
            } else {
              return ListView.builder(
                reverse: true,
                itemCount: profileCtrl.comentslistdata.length,
                itemBuilder: (context, index) {
                  final comment = list[index];
                  return Column(
                    children: [
                      commentCard(comment),
                      Divider(thickness: 1, color: AppColors.Grey),
                    ],
                  );
                },
              );
            }
          }),
        ),
        Obx(
          () => Visibility(
            visible: replyForComment.value != null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextView(
                      text: 'Reply to ${replyForComment.value?.userId?.name}',
                      style: 13.txtMediumPrimary,
                    ),
                  ),
                  ImageView(
                    onTap: () {
                      replyForComment.value = null;
                    },
                    url: AppImages.crossbtn,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.Grey.withOpacity(0.5),
                      blurRadius: 30,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10) +
                    const EdgeInsets.only(left: 16, right: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: commentBoxFocusNode,
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: "Write Comment",
                          hintStyle: 14.txtRegularGrey,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: AppColors.Grey),
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          suffixIcon: GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 15,
                                right: 10,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  if (messageEnable.isTrue) {
                                    _submitComment();
                                  }
                                },
                                child: Obx(
                                  () => ImageView(
                                    url: AppImages.cmntmsg,
                                    tintColor: messageEnable.isTrue
                                        ? null
                                        : AppColors.grey.withAlpha(100),
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                appBSheet(
                  context,
                  EditImageBSheetView(
                    hasVideoPicker: true,
                    onItemTap: (source) async {
                      Navigator.pop(context);
                      final path = await openFilePicker(source);
                      if (path != null) {
                        sendMediaFile(path, source.fileType);
                      }
                      // final path =  await _imagePickerOpen(source);
                      // if(path != null){
                      //   ImageDataModel imageDataTemp = imageData; imageDataTemp.file = path; imageDataTemp.type = ImageType.file; if(onChange != null){
                      //     onChange!(imageDataTemp); }
                      // }
                    },
                  ),
                );
                // context.openBottomSheet(Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       TextView(text: 'Choose file', style: 18.txtMediumBlackText,
                //         margin: EdgeInsets.only(bottom: 20),
                //       ),
                //
                //       Row(
                //         children: [
                //           ImageView(
                //             onTap: (){
                //               context.pop();
                //
                //             },
                //             url: AppImages.cemaraaa, size: 40,
                //           margin: EdgeInsets.only(right: 10),
                //           ),
                //           ImageView(
                //             onTap: (){
                //               context.pop();
                //             },
                //             url: AppImages.video, size: 40,),
                //         ],
                //       )
                //     ],
                //   ),
                // ));
              },
              child: Container(
                height: 40,
                width: 40,
                margin: EdgeInsets.only(right: 16),
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.btnColor,
                ),
                alignment: Alignment.center,
                child: ImageView(
                  url: AppImages.attachFile,
                  tintColor: AppColors.white,
                ),
              ),
            ),
          ],
        ),

        // SizedBox(
        //   height: context.bottomSafeArea + 10,
        // ),
      ],
    );
  }
}

class FullImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullImageScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(child: Image.network(imageUrl, fit: BoxFit.contain)),
    );
  }
}

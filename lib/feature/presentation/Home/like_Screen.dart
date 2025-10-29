import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/presentation/profileScreens/friend_profile_screen.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../components/coreComponents/AppButton.dart';
import '../../../components/coreComponents/ImageView.dart';
import '../../../components/coreComponents/TextView.dart';
import '../../../components/styles/appColors.dart';
import '../../../components/styles/appImages.dart';
import '../controller/auth_Controller/profileCtrl.dart';

class LikeScreen extends StatefulWidget {
  final String postId;
  const LikeScreen({super.key, required this.postId});

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
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
    await profileCtrl.likedListes(selectedId: widget.postId).applyLoader;
  }

  @override
  void dispose() {
    super.dispose();
    profileCtrl.comentslistdata.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
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
                  TextView(text: 'Likes', style: 18.txtMediumBlack),
                  const SizedBox(height: 5),
                  Obx(
                    () => TextView(
                      text:
                          "${profileCtrl.comentslistdata.length} people Likes",
                      style: 12.txtRegularGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Display comments
          Expanded(
            child: Obx(() {
              if (profileCtrl.comentslistdata.isEmpty) {
                return Center(
                  child: TextView(
                    text: "No Likes yet",
                    style: 14.txtRegularGrey,
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: profileCtrl.comentslistdata.length,
                  itemBuilder: (context, index) {
                    final content = profileCtrl.comentslistdata[index];
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (Preferences.uid != content.userId?.id) {
                              context.replaceNavigator(
                                FriendProfileScreen(
                                  data: ProfileDataModel(
                                    id: content.userId?.id,
                                    name: content.userId?.name,
                                    image: content.userId?.image,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            color: AppColors.white,
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ImageView(
                                    url: AppUtils.configImageUrl(
                                      content.userId?.image ?? '',
                                    ),
                                    imageType: ImageType.network,
                                    defaultImage: AppImages.dummyProfile,
                                    fit: BoxFit.cover,
                                    size: 40,
                                    radius: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      15.height,
                                      TextView(
                                        text:
                                            content.userId?.name.toString() ??
                                            'Unknown User',
                                        style: 14.txtMediumBlack,
                                      ),
                                      SizedBox(height: 3),
                                      // TextView(
                                      //   style: 12.txtRegularBlack,
                                      //   text: content.content ?? 'No content available',
                                      // ),
                                    ],
                                  ),
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     // Handle delete functionality if needed
                                  //   },
                                  //   child: ImageView(url: AppImages.delete, size: 20),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(thickness: 1, color: AppColors.Grey),
                      ],
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}

// Delete Confirmation Dialog
void showDeleteDialog(BuildContext context, VoidCallback onDelete) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.white,
        title: TextView(
          text: "Delete Comment",
          style: 24.txtBoldBtncolor,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(color: AppColors.btnColor, thickness: 1),
            TextView(
              text:
                  "Are you sure you want to delete this comment? This action cannot be undone.",
              textAlign: TextAlign.center,
              style: 16.txtRegularGrey,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton(
                radius: 25.sdp,
                width: 110.sdp,
                label: "Cancel",
                labelStyle: 14.txtMediumbtncolor,
                buttonColor: AppColors.white,
                buttonBorderColor: AppColors.btnColor,
                margin: 20.right,
                onTap: () => Navigator.pop(context),
              ),
              AppButton(
                radius: 25.sdp,
                width: 110.sdp,
                label: "Delete",
                labelStyle: 14.txtMediumWhite,
                buttonColor: AppColors.btnColor,
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}

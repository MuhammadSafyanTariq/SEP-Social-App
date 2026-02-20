import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/profileScreens/friend_profile_screen.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';

import '../../../../../components/coreComponents/AppButton.dart';
import '../../../../../components/styles/appImages.dart';
import '../../../../../components/styles/app_strings.dart';

class MyFollowersListScreen extends StatefulWidget {
  const MyFollowersListScreen({super.key});

  @override
  State<MyFollowersListScreen> createState() => _MyFollowersListScreenState();
}

class _MyFollowersListScreenState extends State<MyFollowersListScreen> {
  @override
  void initState() {
    super.initState();
    // Load followers when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProfileCtrl.find.getMyFollowers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _FollowerScreen(
      list: ProfileCtrl.find.myFollowersList,
      onRemove: (value) {
        ProfileCtrl.find.removeFollower(value).applyLoader.then((updated) {
          if (updated != null) {
            ProfileCtrl.find.profileData.value = updated;
            AppUtils.toast('Follower removed. They can no longer see your posts.');
          } else {
            ProfileCtrl.find.getProfileDetails();
            AppUtils.toast('Follower removed. They can no longer see your posts.');
          }
          ProfileCtrl.find.getMyFollowers();
        }).catchError((_) {
          AppUtils.toastError('Failed to remove follower');
        });
      },
      isMyList: true,
    );
  }
}

class FriendFollowersListScreen extends StatefulWidget {
  final List<ProfileDataModel> list;
  final String userId;
  const FriendFollowersListScreen({
    super.key,
    required this.list,
    required this.userId,
  });

  @override
  State<FriendFollowersListScreen> createState() =>
      _FriendFollowersListScreenState();
}

class _FriendFollowersListScreenState extends State<FriendFollowersListScreen> {
  RxList<ProfileDataModel> list = RxList([]);

  @override
  void initState() {
    super.initState();
    list.assignAll(widget.list);
  }

  void followUnFollowAction(String value) {
    ProfileCtrl.find.followRequest(value).applyLoader.then((value) {
      ProfileCtrl.find.getProfileDetails();
      ProfileCtrl.find.getFriendFollowers(widget.userId).then((value) {
        list.assignAll(value);
        list.refresh();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _FollowerScreen(
      list: list,
      onRemove: (value) {
        followUnFollowAction(value);
        // ProfileCtrl.find.followRequest(value).applyLoader.then((value){
        //   ProfileCtrl.find.getFriendFollowers(widget.userId).then((value){
        //     list.assignAll(value);
        //     list.refresh();
        //   });
        // });
      },
      isMyList: false,
      onFollow: (value) {
        followUnFollowAction(value);
      },
    );
  }
}

class _FollowerScreen extends StatefulWidget {
  final List<ProfileDataModel> list;
  final Function(String)? onRemove;
  final bool isMyList;
  final Function(String)? onFollow;
  const _FollowerScreen({
    super.key,
    required this.list,
    this.onRemove,
    required this.isMyList,
    this.onFollow,
  });

  @override
  State<_FollowerScreen> createState() => _FollowerScreenState();
}

class _FollowerScreenState extends State<_FollowerScreen> {
  final search = TextEditingController();
  RxString searchRx = RxString('');
  String get searchText => searchRx.value;

  List<ProfileDataModel> get list => searchText.isNotNullEmpty
      ? widget.list
            .where(
              (element) =>
                  element.name?.toLowerCase().contains(
                    searchText.toLowerCase(),
                  ) ??
                  false,
            )
            .toList()
      : widget.list;

  @override
  void initState() {
    super.initState();
    searchRx.value = search.getText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Linked Me', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: widget.list.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: search,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  hintText: 'Search',
                  hintStyle: 14.txtRegularGrey,
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.grey,
                    size: 25.sdp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                onChanged: (value) {
                  searchRx.value = search.getText;
                },
              ),
            ),
          ),
          Obx(
            () => Visibility(
              visible: list.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10,
                ),
                child: Text(
                  '${list.length.toString().padLeft(2, '0')} Linked Me',
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(
              () => list.isEmpty
                  ? Center(
                      child: TextView(
                        text: 'No User Found.',
                        style: 18.txtBoldBlack,
                      ),
                    )
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: AppColors.black,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final user = list[index];

                        bool isFollowed = widget.isMyList;
                        if (!widget.isMyList) {
                          isFollowed =
                              ProfileCtrl.find.profileData.value.following
                                  ?.contains(user.id!) ??
                              false;
                          // for(var item in list){
                          //   if(ProfileCtrl.find.profileData.value.following?.contains(item.id) ?? false){
                          //     isFollowed = true;
                          //     break;
                          //   }
                          // }
                        }
                        return BlockedUserTile(
                          data: user,
                          isFollowed: isFollowed,
                          name: user.name ?? '',
                          image: user.image ?? '',
                          onUnblock: () {},
                          onRemove: () {
                            widget.onRemove?.call(user.id!);
                          },
                          onFollow: () {
                            widget.onFollow?.call(user.id!);
                          },
                          goToProfile: () {
                            context.pushNavigator(
                              FriendProfileScreen(data: user),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlockedUserTile extends StatelessWidget {
  final ProfileDataModel data;
  final String name;
  final String image;
  final VoidCallback onUnblock;
  final Function? onRemove;
  final Function? goToProfile;
  final bool isFollowed;
  final Function? onFollow;

  const BlockedUserTile({
    Key? key,
    required this.name,
    required this.image,
    required this.onUnblock,
    this.onRemove,
    this.goToProfile,
    required this.isFollowed,
    this.onFollow,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ImageView(
        onTap: () {
          goToProfile?.call();
        },
        url: AppUtils.configImageUrl(image),

        // image.isNotNullEmpty ? (image.contains('http') ? image : baseUrl + image) : ''
        size: 50,
        imageType: ImageType.network,
        defaultImage: AppImages.dummyProfile,
        radius: 50 / 2,
        fit: BoxFit.cover,
        bgColor: AppColors.grey.withAlpha(100),
      ),
      title: TextView(
        onTap: () {
          goToProfile?.call();
        },
        text: name,
        style: 16.txtRegularWhite,
      ),
      trailing: data.id == Preferences.uid
          ? null
          : isFollowed
          ? TextButton(
              onPressed: onUnblock,
              child: TextView(
                text: 'Remove',
                style: 14.txtRegularbtncolor,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Stack(
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 5,
                              sigmaY: 5,
                            ), // Blur intensity
                            child: Container(
                              color: Colors.black.withOpacity(
                                0.3,
                              ), // Slightly dark background
                            ),
                          ),
                          AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.white,
                            insetPadding: EdgeInsets.symmetric(horizontal: 40),
                            contentPadding: EdgeInsets.zero,
                            titlePadding: EdgeInsets.zero,
                            title: Column(
                              children: [
                                15.height,

                                TextView(
                                  text: "Remove Follower?",
                                  style: 24.txtSBoldprimary,
                                  textAlign: TextAlign.center,
                                ),

                                10.height,
                                Divider(thickness: 1, color: AppColors.Grey),
                              ],
                            ),
                            content: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextView(
                                text:
                                    "Are you sure you want to remove this follower?",
                                textAlign: TextAlign.center,
                                style: 16.txtRegularprimary,
                              ),
                            ),
                            actionsAlignment: MainAxisAlignment.center,
                            actions: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AppButton(
                                      radius: 25.sdp,
                                      width: 110.sdp,
                                      label: AppStrings.no.tr,
                                      labelStyle: 14.txtMediumbtncolor,
                                      buttonColor: AppColors.white,
                                      buttonBorderColor: AppColors.btnColor,
                                      margin: 20.right,
                                      onTap: context.pop,
                                    ),
                                    AppButton(
                                      radius: 25.sdp,
                                      width: 110.sdp,
                                      label: AppStrings.yes.tr,
                                      labelStyle: 14.txtMediumWhite,
                                      buttonColor: AppColors.btnColor,
                                      onTap: () {
                                        context.pop();
                                        onRemove?.call();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              10.height,
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            )
          : TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.green),
              ),
              onPressed: onUnblock,
              child: TextView(
                text: 'Link Up',
                style: 14.txtRegularprimary,
                onTap: () {
                  onFollow?.call();
                  // showDialog(
                  //   context: context,
                  //   builder: (BuildContext context) {
                  //     return Stack(
                  //         children: [
                  //
                  //           BackdropFilter(
                  //             filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur intensity
                  //             child: Container(
                  //               color: Colors.black.withOpacity(0.3), // Slightly dark background
                  //             ),
                  //           ),
                  //           AlertDialog(
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(20),
                  //             ),
                  //             backgroundColor: Colors.white,
                  //             insetPadding: EdgeInsets.symmetric(horizontal: 40),
                  //             contentPadding: EdgeInsets.zero,
                  //             titlePadding: EdgeInsets.zero,
                  //             title: Column(
                  //               children: [
                  //                 15.height,
                  //
                  //                 TextView(
                  //                   text: "Remove Follower?",
                  //                   style: 24.txtBoldBlack,
                  //                   textAlign: TextAlign.center,
                  //                 ),
                  //
                  //                 10.height,
                  //                 Divider(
                  //                   thickness: 1,color: AppColors.Grey,
                  //                 ),
                  //               ],
                  //             ),
                  //             content: Padding(
                  //               padding: const EdgeInsets.all(8.0),
                  //               child: TextView(
                  //                 text: "Are you sure you want to remove this follower?",
                  //                 textAlign: TextAlign.center,
                  //                 style: 16.txtRegularBlack,
                  //               ),
                  //             ),
                  //             actionsAlignment: MainAxisAlignment.center,
                  //             actions: [
                  //               Padding(
                  //                 padding: const EdgeInsets.all(8.0),
                  //                 child: Row(
                  //                   crossAxisAlignment: CrossAxisAlignment.center,
                  //                   mainAxisAlignment: MainAxisAlignment.center,
                  //                   children: [
                  //                     AppButton(
                  //                       radius: 25.sdp,
                  //                       width: 110.sdp,
                  //                       label: AppStrings.no.tr,
                  //                       labelStyle: 14.txtMediumbtncolor,
                  //                       buttonColor: AppColors.white,
                  //                       buttonBorderColor: AppColors.btnColor,
                  //                       margin: 20.right,
                  //                       onTap: context.pop,
                  //                     ),
                  //                     AppButton(
                  //                       radius: 25.sdp,
                  //                       width: 110.sdp,
                  //                       label: AppStrings.yes.tr,
                  //                       labelStyle: 14.txtMediumWhite,
                  //                       buttonColor: AppColors.btnColor,
                  //                       onTap: (){
                  //                         context.pop();
                  //                         onRemove?.call();
                  //                       },
                  //
                  //                     ),
                  //
                  //                   ],
                  //                 ),
                  //               ),10.height
                  //             ],
                  //           ),]
                  //     );
                  //   },
                  // );
                },
              ),
            ),
    );
  }
}

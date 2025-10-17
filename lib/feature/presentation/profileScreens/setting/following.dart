
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/profileScreens/friend_profile_screen.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';

import '../../../../../components/coreComponents/AppButton.dart';
import '../../../../../components/styles/app_strings.dart';

class MyFollowingListScreen extends StatefulWidget {
  const MyFollowingListScreen({super.key});

  @override
  State<MyFollowingListScreen> createState() => _MyFollowingListScreenState();
}

class _MyFollowingListScreenState extends State<MyFollowingListScreen> {
  @override
  Widget build(BuildContext context) {
    return Obx(()=>_Following(list: ProfileCtrl.find.myFollowingList.value,
      onRemove: (value){
      ProfileCtrl.find.followRequest(value).applyLoader.then((value){
        ProfileCtrl.find.getMyFollowings();
      });
      },

    ));
  }
}


class FriendFollowingListScreen extends StatefulWidget {
  final List<ProfileDataModel> list;
  final String userId;
  const FriendFollowingListScreen({super.key, required this.list, required this.userId});

  @override
  State<FriendFollowingListScreen> createState() => _FriendFollowingListScreenState();
}

class _FriendFollowingListScreenState extends State<FriendFollowingListScreen> {
  RxList<ProfileDataModel> list = RxList([]);


  @override
  void initState() {
    super.initState();
    list.assignAll(widget.list);
  }


  void followUnFollowAction(String value){
    ProfileCtrl.find.followRequest(value).applyLoader.then((value){
      ProfileCtrl.find.getProfileDetails();
      ProfileCtrl.find.getFriendFollowings(widget.userId).then((value){
        list.assignAll(value);
        list.refresh();
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Obx(()=>_Following(list: list.value,
      isMyList: false,
      onRemove: (value){
        followUnFollowAction(value);
      },
      onFollow: (value){
        followUnFollowAction(value);
      },

    ));
  }
}



class _Following extends StatefulWidget {
  final List<ProfileDataModel> list;
  final Function(String)? onRemove;
  final Function(String)? onFollow;
  final bool isMyList;
  const _Following({super.key, required this.list, this.onRemove, this.onFollow,  this.isMyList = true});

  @override
  State<_Following> createState() => _FollowingState();
}

class _FollowingState extends State<_Following> {
  final search = TextEditingController();
  RxString searchRx = RxString('');
  String get searchText => searchRx.value;

  List<ProfileDataModel> get list => searchText.isNotNullEmpty ?
  widget.list.where((element)=> element.name?.toLowerCase().contains(searchText.toLowerCase()) ?? false ).toList() : widget.list;

  @override
  void initState() {
    super.initState();
    searchRx.value = search.getText;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Link Ups ',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black,size: 20,),
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
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.3),
                  hintText: 'Search',
                  hintStyle: 14.txtRegularGrey,
                  prefixIcon: Icon(Icons.search, color:AppColors.grey,size: 25.sdp,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                controller: search,
                onChanged: (value){
                  searchRx.value = search.getText;
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Obx(
                  ()=>list.isEmpty ?
                  Center(
                    child: TextView(text: 'No User Found.', style: 18.txtBoldBlack,),
                  ):



                      ListView.separated(
                itemCount: list.length,
                separatorBuilder: (context, index) => const Divider(
                  color: AppColors.white,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  final user = list[index];

                  bool isFollowed = widget.isMyList;
                  if(!widget.isMyList){
                    isFollowed = ProfileCtrl.find.profileData.value.following?.contains(user.id!) ?? false;
                    // for(var item in list){
                    //   if(ProfileCtrl.find.profileData.value.following?.contains(item.id!) ?? false){
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
                    onUnblock: () {
                    }, onRemove:(){
                    widget.onRemove?.call(user.id!);
                  },
                    onFollow: (){
                      widget.onFollow?.call(user.id!);
                    },
                    openProfile: (){
                      context.pushNavigator(FriendProfileScreen(data: user));
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
  final String name;
  final String image;
  final VoidCallback onUnblock;
  final Function? onRemove;
  final Function? onFollow;
  final Function()? openProfile;
  final bool isFollowed;
  final ProfileDataModel data;
  

  const BlockedUserTile({
    Key? key,
    required this.name,
    required this.image,
    required this.onUnblock,  this.onRemove, required this.isFollowed, this.onFollow, this.openProfile, required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ImageView(
        onTap: openProfile,
        url: AppUtils.configImageUrl(image)
        // image.isNotNullEmpty ? (image.contains('http') ? image : baseUrl + image) : ''
        ,
          radius: 50/2,
          size: 50,
        defaultImage: AppImages.dummyProfile,
        fit: BoxFit.cover,
        imageType: ImageType.network,
        bgColor: AppColors.grey.withAlpha(100),
      ),
      title: TextView(
        onTap: openProfile,
        text: name,
        style: 16.txtRegularWhite,
      ),
      trailing: Preferences.uid == data.id ? null :



      isFollowed ?
      TextButton(
        onPressed: onUnblock,
        child:  TextView(
          text: 'Remove',
          style: 14.txtRegularbtncolor,
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Stack(
                    children: [

                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur intensity
                        child: Container(
                          color: Colors.black.withOpacity(0.3), // Slightly dark background
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
                              text: "Unfollow?",
                              style: 24.txtSBoldprimary,
                              textAlign: TextAlign.center,
                            ),
                            10.height,
                            Divider(
                              thickness: 1,color: AppColors.Grey,
                            ),
                          ],
                        ),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextView(
                            text: "Are you sure you want to unfollow this user?",
                            textAlign: TextAlign.center,
                            style: 16.txtRegularprimary,
                          ),
                        ),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: [
                          Row(
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
                                onTap: (){
                                  context.pop();
                                  onRemove?.call();
                                },
                              ),
                            ],
                          ),
                          10.height
                        ],
                      ),
                    ]
                );
              },
            );
          },
        ),
      ) :   TextButton(
        style: ButtonStyle(
          backgroundColor:WidgetStateProperty.all(Colors.green),

        ),
        onPressed: onUnblock,
        child:  TextView(
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
            //                 TextView(
            //                   text: "Unfollow?",
            //                   style: 24.txtBoldBlack,
            //                   textAlign: TextAlign.center,
            //                 ),
            //                 10.height,
            //                 Divider(
            //                   thickness: 1,color: AppColors.Grey,
            //                 ),
            //               ],
            //             ),
            //             content: Padding(
            //               padding: const EdgeInsets.all(8.0),
            //               child: TextView(
            //                 text: "Are you sure you want to unfollow this user?",
            //                 textAlign: TextAlign.center,
            //                 style: 16.txtRegularBlack,
            //               ),
            //             ),
            //             actionsAlignment: MainAxisAlignment.center,
            //             actions: [
            //               Row(
            //                 crossAxisAlignment: CrossAxisAlignment.center,
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 children: [
            //                   AppButton(
            //                     radius: 25.sdp,
            //                     width: 110.sdp,
            //                     label: AppStrings.no.tr,
            //                     labelStyle: 14.txtMediumbtncolor,
            //                     buttonColor: AppColors.white,
            //                     buttonBorderColor: AppColors.btnColor,
            //                     margin: 20.right,
            //                     onTap: context.pop,
            //                   ),
            //                   AppButton(
            //                     radius: 25.sdp,
            //                     width: 110.sdp,
            //                     label: AppStrings.yes.tr,
            //                     labelStyle: 14.txtMediumWhite,
            //                     buttonColor: AppColors.btnColor,
            //                     onTap: (){
            //                       context.pop();
            //                       onRemove?.call();
            //                     },
            //                   ),
            //                 ],
            //               ),
            //               10.height
            //             ],
            //           ),
            //         ]
            //     );
            //   },
            // );
          },
        ),
      )
    );
  }
}

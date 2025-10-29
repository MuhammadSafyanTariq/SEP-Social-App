import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppBar2.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';

import '../../../../../components/coreComponents/AppButton.dart';
import '../../../../../components/styles/app_strings.dart';

class Blockuser extends StatefulWidget {
  const Blockuser({super.key});

  @override
  State<Blockuser> createState() => _BlockuserState();
}

class _BlockuserState extends State<Blockuser> {
  @override
  void initState() {
    super.initState();
    ProfileCtrl.find.getBlockedUserList().applyLoader;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar2(
            title: "Blocked Users",
            titleStyle: 18.txtMediumBlack,
            prefixImage: "back",
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: Colors.white,
            hasTopSafe: true,
          ),
          Expanded(
            child: Obx(() {
              print(
                "Blocked user list length: ${ProfileCtrl.find.blockedUserList.length}",
              );
              return ProfileCtrl.find.blockedUserList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.sdp),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.block,
                              size: 64.sdp,
                              color: AppColors.grey.withOpacity(0.5),
                            ),
                            24.height,
                            TextView(
                              text: "No blocked users",
                              style: 20.txtMediumBlack,
                              textAlign: TextAlign.center,
                            ),
                            12.height,
                            TextView(
                              text: "Users you block will appear here",
                              style: 14.txtRegularGrey,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(16.sdp),
                      itemCount: ProfileCtrl.find.blockedUserList.length,
                      separatorBuilder: (context, index) => Divider(
                        color: AppColors.grey.withOpacity(0.2),
                        thickness: 1,
                        height: 24.sdp,
                      ),
                      itemBuilder: (context, index) {
                        final user = ProfileCtrl.find.blockedUserList[index];
                        return BlockedUserTile(
                          name: user.name ?? '',
                          image: user.image ?? '',
                          onUnblock: () {
                            ProfileCtrl.find
                                .unblockBlockUser(
                                  userId: user.id!,
                                  refreshList: true,
                                )
                                .applyLoader;
                          },
                        );
                      },
                    );
            }),
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

  const BlockedUserTile({
    Key? key,
    required this.name,
    required this.image,
    required this.onUnblock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.sdp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sdp),
        border: Border.all(color: AppColors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ImageView(
            url: image.contains('http') ? image : baseUrl + image,
            imageType: ImageType.network,
            size: 50.sdp,
            radius: 25.sdp,
            fit: BoxFit.cover,
          ),
          16.width,
          Expanded(
            child: TextView(text: name, style: 16.txtMediumBlack),
          ),
          TextButton(
            onPressed: () {
              context.openDialog(
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 14.sdp),
                      child: TextView(
                        text: "Unblock?",
                        style: 24.txtMediumprimary,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.sdp),
                      child: TextView(
                        text: "Are you sure you want to unblock this user?",
                        textAlign: TextAlign.center,
                        style: 16.txtRegularprimary,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.sdp, top: 10.sdp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppButton(
                            radius: 25.sdp,
                            width: 110.sdp,
                            label: AppStrings.no.tr,
                            labelStyle: 14.txtMediumbtncolor,
                            buttonColor: AppColors.black,
                            buttonBorderColor: AppColors.btnColor,
                            margin: 20.right,
                            onTap: () => context.stopLoader,
                          ),
                          AppButton(
                            radius: 25.sdp,
                            width: 110.sdp,
                            label: AppStrings.yes.tr,
                            labelStyle: 14.txtMediumWhite,
                            buttonColor: AppColors.btnColor,
                            onTap: () {
                              context.stopLoader;
                              onUnblock();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 16.sdp,
                vertical: 8.sdp,
              ),
              backgroundColor: AppColors.btnColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.sdp),
              ),
            ),
            child: TextView(text: "Unblock", style: 14.txtMediumbtncolor),
          ),
        ],
      ),
    );
  }
}

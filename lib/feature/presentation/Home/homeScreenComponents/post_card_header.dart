import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/presentation/Add%20post/edit_Post.dart';
import 'package:sep/feature/data/models/dataModels/responseDataModel.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/auth_ctrl.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/profileScreens/friend_profile_screen.dart';
import '../../../presentation/helpers/token_transfer_helper.dart';
import '../../../presentation/wallet/packages_screen.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';

import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appImages.dart';
import '../../../data/models/dataModels/post_data.dart';
import '../option.dart';

class PostCardHeader extends StatelessWidget {
  final String time;
  final String? location;
  final ProfileDataModel userData;
  final PostData data;
  final Function? onBlockUser;
  final Function? onRemovePostAction;

  const PostCardHeader({
    super.key,
    required this.time,
    required this.location,
    required this.data,
    required this.userData,
    this.onBlockUser,
    this.onRemovePostAction,
  });

  List<int> get tokens => [10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000];

  void _openTokenBottomSheet(BuildContext context) {
    RxnInt selectedToken = RxnInt();
    final TextEditingController customAmountController =
        TextEditingController();
    RxBool useCustomAmount = false.obs;

    context.openBottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                ImageView(
                  url: AppImages.token,
                  size: 30,
                  margin: EdgeInsets.only(right: 8),
                ),
                Expanded(
                  child: TextView(
                    text: 'Send Tokens',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 30, color: Colors.grey),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Token Amount Selection
            TextView(
              text: 'Select Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 12),

            // Pre-defined amounts
            Obx(
              () => !useCustomAmount.value
                  ? Container(
                      height: 120,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: tokens.length,
                        itemBuilder: (context, index) {
                          final token = tokens[index];
                          return Obx(
                            () => GestureDetector(
                              onTap: () => selectedToken.value = token,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedToken.value == token
                                      ? AppColors.primaryColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  border: selectedToken.value == token
                                      ? Border.all(
                                          color: AppColors.primaryColor,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Image.asset(
                                          AppImages.token,
                                          width: 16,
                                          height: 16,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      TextView(
                                        text: '$token',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: selectedToken.value == token
                                              ? Colors.white
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                        controller: customAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12),
                            child: ImageView(
                              url: AppImages.token,
                              size: 20,
                              fit: BoxFit.contain,
                            ),
                          ),
                          hintText: 'Enter custom amount',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          final amount = int.tryParse(value);
                          selectedToken.value = amount;
                        },
                      ),
                    ),
            ),

            // Custom amount toggle
            Obx(
              () => GestureDetector(
                onTap: () {
                  useCustomAmount.value = !useCustomAmount.value;
                  if (!useCustomAmount.value) {
                    customAmountController.clear();
                    selectedToken.value = null;
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: useCustomAmount.value
                        ? AppColors.primaryColor
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextView(
                    text: useCustomAmount.value
                        ? 'Use Quick Select'
                        : 'Custom Amount',
                    style: TextStyle(
                      fontSize: 14,
                      color: useCustomAmount.value
                          ? Colors.white
                          : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Send Button
            Obx(
              () => Container(
                width: double.infinity,
                child: AppButton(
                  label: selectedToken.value != null
                      ? 'Send ${selectedToken.value} Tokens'
                      : 'Select Amount',
                  buttonColor: selectedToken.value != null
                      ? AppColors.primaryColor
                      : Colors.grey,
                  onTap: selectedToken.value != null
                      ? () => _sendTokens(
                          context,
                          selectedToken.value!,
                          userData.id!,
                        )
                      : null,
                ),
              ),
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _sendTokens(BuildContext context, int tokenAmount, String recipientId) {
    // Check current token balance first - use walletTokens
    final currentBalance = ProfileCtrl.find.profileData.value.walletTokens ?? 0;

    if (currentBalance < tokenAmount) {
      Navigator.pop(context);
      context.openDialog(
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextView(
                      text: 'Insufficient Token Balance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 25, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextView(
                text:
                    'You have $currentBalance tokens but need $tokenAmount tokens to complete this transfer.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              AppButton(
                label: 'Add Tokens',
                onTap: () {
                  Navigator.pop(context);
                  context.pushNavigator(PackagesScreen());
                },
              ),
            ],
          ),
        ),
      );
      return;
    }

    // Implement token transfer using AuthCtrl
    try {
      AuthCtrl.find
          .createMoneyWalletTransaction(tokenAmount.toString(), recipientId)
          .applyLoader
          .then((responseData) async {
            Navigator.pop(context);

            // Refresh profile data to update token balance
            await ProfileCtrl.find.getProfileDetails();

            // Show formatted success message with commission details
            TokenTransferHelper.showTransferSuccessMessage(
              responseData,
              defaultTokenAmount: tokenAmount,
              recipientType: 'Recipient',
            );
          })
          .catchError((error) {
            Navigator.pop(context);
            if (error is ResponseData) {
              String errorMsg = error.getError.toString().replaceAll(
                'Exception: ',
                '',
              );
              // Check if it's an insufficient balance error
              if (errorMsg.toLowerCase().contains('insufficient') ||
                  errorMsg.toLowerCase().contains('balance')) {
                context.openDialog(
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextView(
                                text: 'Insufficient Token Balance',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                Icons.close,
                                size: 25,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextView(
                          text: errorMsg,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 20),
                        AppButton(
                          label: 'Add Tokens',
                          onTap: () {
                            Navigator.pop(context);
                            context.pushNavigator(PackagesScreen());
                          },
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                AppUtils.toastError(errorMsg);
              }
            } else {
              AppUtils.toastError('Failed to send tokens: ${error.toString()}');
            }
          });
    } catch (e) {
      Navigator.pop(context);
      AppUtils.toastError('Failed to send tokens: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10),
      child: Row(
        children: [
          Stack(
            children: [
              ImageView(
                url: AppUtils.configImageUrl(userData.image ?? ''),
                imageType: ImageType.network,
                size: 40,
                radius: 20,
                fit: BoxFit.cover,
                defaultImage: AppImages.dummyProfile,
              ),

              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    if (userData.id != Preferences.uid) {
                      context.pushNavigator(
                        FriendProfileScreen(data: userData),
                      );
                      AppUtils.log("imagefriend${userData.image.fileUrl}");
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(width: 10.sdp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextView(
                        maxlines: 1,
                        text: userData.name ?? '',
                        style: 15.txtMediumBlack,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TextView(text: '$time', style: 12.txtRegularGrey),

                        // Visibility(
                        //   visible: location != null,
                        //   child: Row(
                        //     children: [
                        //       Icon(
                        //         Icons.location_on,
                        //         color: AppColors.black,
                        //         size: 13,
                        //       ),
                        //       TextView(
                        //         text: location ?? '',
                        //         style: 12.txtRegularBlack,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                    Visibility(
                      visible: data.country.isNotNullEmpty,
                      child: TextView(
                        text: '${data.country ?? ''}',
                        style: 12.txtRegularGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Token transfer button
          GestureDetector(
            onTap: () => _openTokenBottomSheet(context),
            child: ImageView(url: AppImages.token, size: 30),
          ),
          userData.id == Preferences.uid
              ? PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      AppUtils.log('Edit clicked');
                      if (Preferences.uid == userData.id) {
                        context.pushNavigator(EditPost(data: data));
                      }
                    } else if (value == 'delete') {
                      AppUtils.log('Delete clicked');
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange,
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Delete ${data.fileType?.capitalizeFirst ?? 'Post'}?',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            content: Text(
                              'Are you sure you want to delete this ${data.fileType?.toLowerCase() ?? 'post'}? This action cannot be undone.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                  ProfileCtrl.find
                                      .removePost(data.id!)
                                      .applyLoader
                                      .then((value) {
                                        onRemovePostAction?.call();
                                      });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    if (data.fileType != 'poll')
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20, color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Edit ${data.fileType?.capitalizeFirst}'),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Delete ${data.fileType?.capitalizeFirst}',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : IconButton(
                  onPressed: () {
                    ProfileCtrl.find
                        .getFriendProfileDetails(userData.id!)
                        .applyLoader
                        .then((value) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext context) {
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.43,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 70,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: AppColors.grey,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Options(
                                        onBlockSuccess: () {
                                          context.pop();
                                          onBlockUser?.call();
                                        },
                                        data: value,
                                        name: value.name ?? '',
                                        postUserId: value.id,
                                        postId: data.id,
                                        postData: data,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        });
                  },
                  icon: const Icon(Icons.more_vert),
                ),
        ],
      ),
    );
  }
}

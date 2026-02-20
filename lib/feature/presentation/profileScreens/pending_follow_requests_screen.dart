import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/profileScreens/friend_profile_screen.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/widget.dart';

/// Screen where a private account owner can see and approve/reject follow requests.
class PendingFollowRequestsScreen extends StatefulWidget {
  const PendingFollowRequestsScreen({super.key});

  @override
  State<PendingFollowRequestsScreen> createState() =>
      _PendingFollowRequestsScreenState();
}

class _PendingFollowRequestsScreenState
    extends State<PendingFollowRequestsScreen> {
  final ProfileCtrl _profileCtrl = ProfileCtrl.find;
  final RxList<ProfileDataModel> _list = <ProfileDataModel>[].obs;
  final RxBool _loading = true.obs;
  final RxBool _error = false.obs;

  Future<void> _loadRequests() async {
    _loading.value = true;
    _error.value = false;
    final result = await _profileCtrl.getPendingFollowRequests();
    _loading.value = false;
    if (result.isSuccess && result.data != null) {
      _list.assignAll(result.data!);
      _list.refresh();
    } else {
      _error.value = true;
      AppUtils.toastError(result.getError?.toString() ?? 'Failed to load requests');
    }
  }

  Future<void> _approve(String requesterId) async {
    final res = await _profileCtrl.approveFollowRequest(requesterId);
    if (res.isSuccess) {
      AppUtils.toast('Follow request approved');
      _list.removeWhere((u) => u.id == requesterId);
      _list.refresh();
      await _profileCtrl.getProfileDetails();
    } else {
      AppUtils.toastError(res.getError?.toString() ?? 'Failed to approve');
    }
  }

  Future<void> _reject(String requesterId) async {
    final res = await _profileCtrl.rejectFollowRequest(requesterId);
    if (res.isSuccess) {
      AppUtils.toast('Follow request rejected');
      _list.removeWhere((u) => u.id == requesterId);
      _list.refresh();
      await _profileCtrl.getProfileDetails();
    } else {
      AppUtils.toastError(res.getError?.toString() ?? 'Failed to reject');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRequests());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Follow requests',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Obx(() {
        if (_loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_error.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextView(
                  text: 'Could not load follow requests',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                16.height,
                AppButton(
                  label: 'Retry',
                  buttonColor: AppColors.btnColor,
                  onTap: _loadRequests,
                ),
              ],
            ),
          );
        }
        if (_list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_disabled, size: 64, color: Colors.grey[400]),
                16.height,
                TextView(
                  text: 'No follow requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                ),
                8.height,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: TextView(
                    text: 'When someone requests to follow you, they will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          itemCount: _list.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[300]),
          itemBuilder: (context, index) {
            final user = _list[index];
            final id = user.id ?? '';
            final name = user.name ?? 'Unknown';
            final username = user.userName ?? '';
            final image = user.image ?? '';
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pushNavigator(FriendProfileScreen(data: user)),
                    child: ImageView(
                      url: AppUtils.configImageUrl(image),
                      size: 50,
                      imageType: ImageType.network,
                      defaultImage: AppImages.dummyProfile,
                      radius: 25,
                      fit: BoxFit.cover,
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.pushNavigator(FriendProfileScreen(data: user)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextView(
                            text: name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            maxlines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (username.isNotEmpty)
                            TextView(
                              text: '@$username',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              maxlines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _reject(id),
                          child: TextView(
                            text: 'Reject',
                            style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(width: 4),
                        AppButton(
                          width: 88,
                          radius: 20,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          label: 'Approve',
                          labelStyle: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                          buttonColor: AppColors.btnColor,
                          onTap: () => _approve(id),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

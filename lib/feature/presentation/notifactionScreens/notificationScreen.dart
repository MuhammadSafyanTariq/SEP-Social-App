import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/notification_model/notification_model.dart';
import 'package:sep/feature/presentation/controller/agora_chat_ctrl.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';

import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';

import '../../../components/coreComponents/AppButton.dart';
import '../../../components/styles/appColors.dart';
import '../../../components/styles/appImages.dart';

import '../../../services/storage/preferences.dart';

import '../../data/models/dataModels/profile_data/profile_data_model.dart';

import '../../data/repository/iAuthRepository.dart';
import '../../data/repository/iTempRepository.dart';
import '../../domain/respository/templateRepository.dart';
import '../chatScreens/Messages_Screen.dart';
import '../profileScreens/friend_profile_screen.dart';
import '../postDetail/post_detail_screen.dart';
import 'notificationScreen.dart' as controller;

class Notificationscreen extends StatefulWidget {
  Notificationscreen({super.key});

  @override
  State<Notificationscreen> createState() => _NotificationscreenState();
}

Map<String, List<NotificationItem>> groupByDate(List<NotificationItem> items) {
  return groupBy(items, (item) {
    final date = item.localDate;
    return DateFormat('yyyy-MM-dd').format(date ?? DateTime(2000));
  });
}

abstract class NotificationListEntry {}

class DateSeparator extends NotificationListEntry {
  final String date;
  DateSeparator(this.date);
}

class NotificationEntry extends NotificationListEntry {
  final NotificationItem item;
  NotificationEntry(this.item);
}

List<NotificationListEntry> buildListWithSeparators(
  List<NotificationItem> items,
) {
  final grouped = groupByDate(items);
  final sortedKeys = grouped.keys.toList()
    ..sort((a, b) => b.compareTo(a)); // most recent first

  final List<NotificationListEntry> finalList = [];

  for (var date in sortedKeys) {
    finalList.add(DateSeparator(date));
    finalList.addAll(grouped[date]!.map(NotificationEntry.new));
  }

  return finalList;
}

final TempRepository _repo = ITempRepository();
RxList<NotificationItem> notificationlist = <NotificationItem>[].obs;

RefreshController _refreshController = RefreshController(initialRefresh: false);
RxInt currentPage = 1.obs;

Future<void> getNotification({
  bool isRefresh = false,
  bool isLoadMore = false,
}) async {
  // try {
  int localPage = currentPage.value;
  if (isLoadMore) {
    localPage++;
  } else {
    localPage = 1;
  }
  final response = await _repo.notification(page: localPage);
  if (response.isNotEmpty) {
    // Get cached read notification IDs
    final cachedReadIds = Preferences.readNotificationIds;

    // Merge server response with cached read status
    final mergedNotifications = response.map((notification) {
      if (cachedReadIds.contains(notification.id)) {
        // Override server's isRead if we have it cached as read
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    // Log notification read states from server
    final serverUnreadCount = response.where((n) => n.isRead == false).length;
    final actualUnreadCount = mergedNotifications
        .where((n) => n.isRead == false)
        .length;
    AppUtils.log(
      "Fetched ${response.length} notifications. Server unread: $serverUnreadCount, Actual unread (after cache merge): $actualUnreadCount, Cached read IDs: ${cachedReadIds.length}",
    );

    if (localPage == 1) {
      notificationlist.assignAll(mergedNotifications);
    } else {
      notificationlist.addAll(mergedNotifications);
    }

    currentPage.value = localPage;
  } else {
    AppUtils.log("No more notifications to load.");
  }
  // } catch (e) {
  //   AppUtils.log("Error in getNotification: $e");
  // }
}

void _onRefresh() async {
  currentPage.value = 1;
  await getNotification(isRefresh: true);
  _refreshController.refreshCompleted();
}

void _onLoading() async {
  await getNotification(isLoadMore: true);
  _refreshController.loadComplete();
}

final now = DateTime.now();
final cutoffTime = now.subtract(const Duration(hours: 24));

// final todayNotifications = controller.notificationlist.where((item) {
//   if (item.createdAt != null) {
//     final notificationTime = DateTime.parse(item.createdAt!);
//     return notificationTime.isAfter(cutoffTime);
//   }
//   return false;
// }).toList();

final yesterdayStart = DateTime(
  now.year,
  now.month,
  now.day,
).subtract(const Duration(days: 1));
final yesterdayEnd = DateTime(now.year, now.month, now.day)
    .subtract(const Duration(days: 1))
    .add(const Duration(hours: 23, minutes: 59, seconds: 59));

final yesterdayNotifications = controller.notificationlist.where((item) {
  if (item.createdAt != null) {
    final notificationTime = DateTime.parse(item.createdAt!);
    return notificationTime.isAfter(yesterdayStart) &&
        notificationTime.isBefore(yesterdayEnd);
  }
  return false;
}).toList();

final olderNotifications = notificationlist.where((item) {
  if (item.createdAt != null) {
    final notificationTime = DateTime.parse(item.createdAt!);
    return notificationTime.isBefore(yesterdayStart);
  }
  return false;
}).toList();

class _NotificationscreenState extends State<Notificationscreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => getNotification().applyLoader,
    );
    super.initState();
  }

  Future<bool?> showConfirmationDialog(
    BuildContext context,
    String notificationId,
  ) async {
    bool? confirmDeletion = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(horizontal: 40),
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.zero,
              title: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: TextView(
                      text: "Delete Notification?",
                      style: 20.txtMediumBlack,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  10.height,
                  Divider(thickness: 1, color: AppColors.Grey),
                ],
              ),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextView(
                  text: "Are you sure you want to delete this notification?",
                  textAlign: TextAlign.center,
                  style: 16.txtRegularGrey,
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
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
                            onTap: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          AppButton(
                            radius: 25.sdp,
                            width: 110.sdp,
                            label: "Delete",
                            labelStyle: 14.txtMediumWhite,
                            buttonColor: AppColors.btnColor,
                            onTap: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: SpinKitCircle(
                                    color: AppColors.btnColor,
                                    size: 50,
                                  ),
                                ),
                              );
                              try {
                                final response = await IAuthRepository()
                                    .deleteNotification(notificationId);
                                Navigator.pop(context);
                                if (response.isSuccess) {
                                  AppUtils.toast(
                                    "Your Notification has been deleted.",
                                  );
                                  controller.notificationlist.removeWhere(
                                    (item) => item.id == notificationId,
                                  );
                                  Navigator.of(context).pop(true);
                                } else {
                                  AppUtils.toastError(
                                    "Failed to delete Notification.",
                                  );
                                  Navigator.of(context).pop(false);
                                }
                              } catch (e) {
                                Navigator.pop(context);
                                AppUtils.toast("An unexpected error occurred.");
                                Navigator.of(context).pop(false);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    10.height,
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
    return confirmDeletion;
  }

  String getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(date.year, date.month, date.day);

    final difference = today.difference(thatDay).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return DateFormat('dd MMM yyyy').format(date);
  }

  bool connectionCallBack = false;

  void _navigateToPost(NotificationItem item, {required bool openComments}) {
    if (item.postId != null && item.postId!.isNotEmpty) {
      // If postId is available, fetch the actual post
      _fetchAndNavigateToPost(item.postId!, openComments: openComments);
    } else {
      // For now, show a message until backend includes postId in notifications
      AppUtils.toast(
        "Post navigation requires postId in notification data. Please update your backend to include postId in notifications.",
      );
      AppUtils.log(
        "Notification navigation attempted but postId not available in notification data",
      );
    }
  }

  Future<void> _fetchAndNavigateToPost(
    String postId, {
    required bool openComments,
  }) async {
    try {
      // First, try to find the post in already-loaded globalPostList (has full data)
      final existingPost = ProfileCtrl.find.globalPostList.firstWhereOrNull(
        (post) => post.id == postId,
      );

      if (existingPost != null) {
        // Post found in memory with full data - navigate directly
        AppUtils.log("Found post in globalPostList: $postId");
        context.pushNavigator(
          PostDetailScreen(postData: existingPost, openComments: openComments),
        );
        return;
      }

      // Post not in memory, fetch from API
      AppUtils.log("Post not in memory, fetching from API: $postId");

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );

      // Fetch post with rich data including likes, comments, and engagement metrics
      // API response includes: likeCount, commentCount, likes[], comments[], user details
      final response = await _repo.getSinglePost(postId);

      Navigator.pop(context); // Close loading dialog

      if (response.isSuccess && response.data != null) {
        // Cache the fetched post with rich data for future use
        final existingIndex = ProfileCtrl.find.globalPostList.indexWhere(
          (post) => post.id == postId,
        );

        if (existingIndex != -1) {
          // Update existing post with rich data
          ProfileCtrl.find.globalPostList[existingIndex] = response.data!;
        } else {
          // Add new post with rich data to cache
          ProfileCtrl.find.globalPostList.add(response.data!);
        }

        context.pushNavigator(
          PostDetailScreen(
            postData: response.data!,
            openComments: openComments,
          ),
        );
        AppUtils.log("Successfully navigated to post with rich data: $postId");
      } else {
        AppUtils.toast("Post not found or has been deleted");
        AppUtils.log("Failed to fetch post: ${response.error}");
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close loading dialog if still open
      }
      AppUtils.toast("Error fetching post: $e");
      AppUtils.log("Exception in _fetchAndNavigateToPost: $e");
    }
  }

  // void _connect(Function() call){
  //   connectionCallBack = false;
  //   AgoraChatCtrl.find.connect((){
  //     if(connectionCallBack) return;
  //     connectionCallBack = true;
  //     call();
  //   });
  // }

  String _getFormattedNotificationMessage(String message) {
    // Check if this is a celebration message and format it properly
    if (message.startsWith('SEP#Celebrate')) {
      return '🎉 Shared a celebration';
    }
    return message;
  }

  Future<void> markAllAsRead() async {
    try {
      final result = await _repo.markAllNotificationsAsRead();

      if (result.isSuccess) {
        // Cache all notification IDs as read
        final allIds = notificationlist
            .where((n) => n.id != null)
            .map((n) => n.id!)
            .toSet();
        Preferences.readNotificationIds = allIds;

        // Update local list only if API call succeeded
        for (int i = 0; i < notificationlist.length; i++) {
          notificationlist[i] = notificationlist[i].copyWith(isRead: true);
        }
        notificationlist.refresh();
        AppUtils.log(
          'Successfully marked all ${allIds.length} notifications as read',
        );
      } else {
        AppUtils.log(
          'Failed to mark all notifications as read: ${result.error}',
        );
      }
    } catch (e) {
      AppUtils.log('Error marking all as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar2(
            title: 'Notifications',
            titleStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            prefixImage: 'back',
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: Colors.white,
            suffixWidget: Obx(() {
              final hasUnread = notificationlist.any(
                (notif) => notif.isRead == false,
              );
              if (!hasUnread) return SizedBox.shrink();
              return TextButton(
                onPressed: markAllAsRead,
                child: Text(
                  'Mark all as read',
                  style: TextStyle(
                    color: AppColors.btnColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ),
          Expanded(
            child: SafeArea(
              child: Obx(() {
                final list = buildListWithSeparators(notificationlist);

                if (notificationlist.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageView(url: AppImages.nonotification, size: 100),
                        TextView(
                          text: "No Notifications Yet",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          margin: EdgeInsets.only(top: 35),
                        ),
                        TextView(
                          text:
                              "When someone comments or likes your video, you will see it here.",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          margin: EdgeInsets.only(top: 22),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  color: Colors.grey[50],
                  child: SmartRefresher(
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    enablePullDown: true,
                    enablePullUp: true,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemBuilder: (context, index) {
                        final entry = list[index];
                        if (entry is DateSeparator) {
                          return sectionHeader(
                            getDateLabel(DateTime.parse(entry.date)),
                          );
                        } else if (entry is NotificationEntry) {
                          final item = entry.item;
                          return Obx(() {
                            final liveIndex = AgoraChatCtrl
                                .find
                                .liveStreamChannels
                                .indexWhere(
                                  (element) => element.channelId == item.roomId,
                                );

                            return buildNotificationList(
                              item,
                              context,
                              liveIndex > -1,
                              onTap: () async {
                                // Mark as read when tapped
                                if (item.isRead == false) {
                                  try {
                                    final result = await _repo
                                        .markNotificationAsRead(
                                          notificationId: item.id ?? '',
                                        );

                                    if (result.isSuccess) {
                                      // Cache the read notification ID
                                      if (item.id != null) {
                                        Preferences.addReadNotificationId(
                                          item.id!,
                                        );
                                      }

                                      // Update local list only if API call succeeded
                                      final index = notificationlist.indexOf(
                                        item,
                                      );
                                      if (index != -1) {
                                        notificationlist[index] = item.copyWith(
                                          isRead: true,
                                        );
                                        notificationlist.refresh();
                                      }
                                      AppUtils.log(
                                        'Successfully marked notification ${item.id} as read',
                                      );
                                    } else {
                                      AppUtils.log(
                                        'Failed to mark notification as read: ${result.error}',
                                      );
                                    }
                                  } catch (e) {
                                    AppUtils.log('Error marking as read: $e');
                                  }
                                }
                              },
                            );
                          });
                        }
                        return const SizedBox.shrink();
                      },
                      separatorBuilder: (context, index) => SizedBox(height: 8),
                      itemCount: list.length,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: TextView(
        text: title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget buildNotificationList(
    NotificationItem item,
    BuildContext context,
    bool liveStatus, {
    VoidCallback? onTap,
  }) {
    return Dismissible(
      key: Key(item.id ?? UniqueKey().toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showConfirmationDialog(context, item.id ?? ""),
      onDismissed: (_) => notificationlist.remove(item),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ImageView(url: AppImages.deleteicon, size: 40)],
        ),
      ),
      child: InkWell(
        onTap: () {
          onTap?.call();
          if (item.notificationType == 'live' ||
              item.notificationType == 'inviteForLive') {
            bool liveStatus1 =
                item.notificationType == 'inviteForLive' ||
                item.status == 'start';
            if (liveStatus1 && liveStatus) {
              AgoraChatCtrl.find.joinLiveChannel(
                LiveStreamChannelModel(
                  channelId: item.roomId!,
                  hostId: item.senderId?.id,
                  hostName: item.senderId?.name,
                  title: item.title, // Include title from notification
                ),
                item.notificationType == 'inviteForLive'
                    ? ClientRoleType.clientRoleBroadcaster
                    : null,
                connectionCallBack,
                (value) {
                  _onRefresh();
                },
              );
            }
            return;
          }

          final sender = item.senderId;

          // AppUtils.log("Sender: ${sender?.id}, Name: ${sender?.name}, Image: ${sender?.image}");

          final message = item.message?.toLowerCase() ?? "";
          final isLikeNotification =
              message.contains("liked your post") ||
              item.notificationType?.toLowerCase() == 'like';
          final isFollowNotification =
              message.contains("started following you") ||
              message.contains("started folowing you") ||
              item.notificationType?.toLowerCase() == 'follow';
          final isCommentNotification =
              message.contains("commented") ||
              item.notificationType?.toLowerCase() == 'comment';
          final isDirectMessage =
              message.contains("sent you a message") ||
              item.notificationType?.toLowerCase() == 'message';

          // AppUtils.log("isLikeNotification: $isLikeNotification, isFollowNotification: $isFollowNotification, isCommentNotification: $isCommentNotification");

          if (sender != null && sender.id != Preferences.uid) {
            final userData = ProfileDataModel(
              id: sender.id ?? '',
              name: sender.name ?? '',
              image: sender.image,
            );

            if (isLikeNotification) {
              // Navigate to post for likes
              _navigateToPost(item, openComments: false);
            } else if (isCommentNotification) {
              // Navigate to post/comments sheet for comments
              _navigateToPost(item, openComments: true);
            } else if (isFollowNotification) {
              context.pushNavigator(FriendProfileScreen(data: userData));
              AppUtils.log(
                "Navigated to friend profile: ${userData.name}, ${userData.image}",
              );
            } else if (isDirectMessage) {
              context.pushNavigator(
                MessageScreen(data: userData, chatId: item.id),
              );
              AppUtils.log(
                "Navigated to message screen: ${userData.name}, chatId: ${item.id}",
              );
            } else {
              AppUtils.log("Notification type not handled for navigation.");
            }
          } else {
            AppUtils.log("Cannot navigate: sender is null or own profile.");
          }
        },

        child: NotificationItemComponent(
          data: item,
          title:
              (item.notificationType == 'live' ||
                  item.notificationType == 'inviteForLive')
              ? item.senderId?.name ?? ''
              : 'New Notification',
          type: item.notificationType ?? '',
          notification: _getFormattedNotificationMessage(
            item.message ?? "No message",
          ),
          // time: DateTime.parse(item.createdAt ?? ""),
          time: item.localDate ?? DateTime.parse(''),
          liveStatus: liveStatus,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextView(
          text: title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class NotificationItemComponent extends StatelessWidget {
  final String notification;
  final String title;
  final String type;
  final DateTime time;
  final NotificationItem data;
  final bool liveStatus;

  const NotificationItemComponent({
    required this.notification,
    super.key,
    required this.time,
    required this.title,
    required this.type,
    required this.data,
    required this.liveStatus,
  });

  String formatTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(dateTime);
  }

  bool get isTypeLiveStream =>
      data.notificationType == 'live' ||
      data.notificationType == 'inviteForLive';
  bool get liveStatus1 =>
      data.notificationType == 'inviteForLive' ? true : data.status == 'start';

  IconData getNotificationIcon() {
    switch (data.notificationType?.toLowerCase()) {
      case 'live':
      case 'inviteforlive':
        return Icons.videocam_outlined;
      case 'marketplace':
      case 'order':
        return Icons.shopping_cart_outlined;
      case 'games':
      case 'game':
        return Icons.sports_esports_outlined;
      case 'security':
        return Icons.security_outlined;
      case 'updates':
        return Icons.system_update_outlined;
      case 'rewards':
        return Icons.card_giftcard_outlined;
      case 'message':
      case 'comment':
        return Icons.chat_bubble_outline;
      case 'follow':
        return Icons.person_add_outlined;
      case 'like':
        return Icons.favorite_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color getNotificationIconColor() {
    return AppColors.greenlight;
  }

  String getNotificationTypeDisplay() {
    switch (data.notificationType?.toLowerCase()) {
      case 'live':
      case 'inviteforlive':
        return 'Live Streaming';
      case 'marketplace':
      case 'order':
        return 'Marketplace';
      case 'games':
      case 'game':
        return 'Games';
      case 'security':
        return 'Security';
      case 'updates':
        return 'Updates';
      case 'rewards':
        return 'Rewards';
      case 'message':
        return 'Messages';
      case 'comment':
        return 'Comments';
      case 'follow':
        return 'Social';
      case 'like':
        return 'Likes';
      default:
        return 'AI Assistant';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug print to see notification type
    print('Notification Type: ${data.notificationType}');
    print('Icon: ${getNotificationIcon()}');
    print('Color: ${getNotificationIconColor()}');

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unread indicator (green dot)
          if (data.isRead == false)
            Container(
              margin: EdgeInsets.only(top: 16, right: 8),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          // Notification Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: getNotificationIconColor().withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: getNotificationIconColor().withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                getNotificationIcon(),
                color: getNotificationIconColor(),
                size: 24,
              ),
            ),
          ),

          SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type/Sender and Time Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getNotificationTypeDisplay(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      formatTime(time),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4),

                // Description
                Text(
                  notification,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

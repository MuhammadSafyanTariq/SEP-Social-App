import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/postDetail/post_detail_screen.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';

/// Instagram-like compact post card for chat
/// Fetches post data on demand using postId
class ChatPostCard extends StatefulWidget {
  final String postId;
  final bool isSentByUser;

  const ChatPostCard({
    Key? key,
    required this.postId,
    required this.isSentByUser,
  }) : super(key: key);

  @override
  State<ChatPostCard> createState() => _ChatPostCardState();
}

class _ChatPostCardState extends State<ChatPostCard> {
  PostData? _postData;
  ProfileDataModel? _userData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPostData();
  }

  Future<void> _fetchUserData(String userId) async {
    try {
      AppUtils.log('👤 Fetching user data for userId: $userId');
      final userData = await ProfileCtrl.find.getFriendProfileDetails(userId);

      if (mounted) {
        setState(() {
          _userData = userData;
        });
        AppUtils.log('👤 User data received: ${userData.name}');
      }
    } catch (e) {
      AppUtils.logEr('❌ Failed to fetch user data: $e');
    }
  }

  Future<void> _fetchPostData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      AppUtils.log('📥 Fetching post data for postId: ${widget.postId}');
      final postData = await ProfileCtrl.find.getSinglePostData(widget.postId);

      AppUtils.log('📦 Post data received:');
      AppUtils.log('  - Post ID: ${postData.id}');
      AppUtils.log('  - UserId in post: ${postData.userId}');
      AppUtils.log('  - User count: ${postData.user.length}');
      AppUtils.log('  - isLikedByUser: ${postData.isLikedByUser}');
      AppUtils.log('  - likeCount: ${postData.likeCount}');
      AppUtils.log('  - commentCount: ${postData.commentCount}');
      if (postData.user.isNotEmpty) {
        AppUtils.log('  - User name: ${postData.user.first.name}');
        AppUtils.log('  - User image: ${postData.user.first.image}');
      }
      AppUtils.log('  - Files count: ${postData.files.length}');
      if (postData.files.isNotEmpty) {
        AppUtils.log('  - First file URL: ${postData.files.first.file}');
        AppUtils.log('  - First file type: ${postData.files.first.type}');
      }

      if (mounted) {
        setState(() {
          _postData = postData;
          _isLoading = false;
        });

        // If user data is not populated, fetch it using userId
        if (postData.user.isEmpty && postData.userId != null) {
          await _fetchUserData(postData.userId!);
        }
      }
    } catch (e) {
      AppUtils.logEr('❌ Failed to fetch post data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }

    if (_hasError || _postData == null) {
      return _buildErrorCard();
    }

    return _buildPostCard();
  }

  Widget _buildLoadingCard() {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Loading post...',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Post unavailable',
                style: TextStyle(fontSize: 13, color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard() {
    final hasMedia = _postData!.files.isNotEmpty;
    final firstFile = hasMedia ? _postData!.files.first : null;
    final isVideo = firstFile?.type?.toLowerCase() == 'video';

    // Get user info from post data or fetched user data
    final userName = _postData!.user.isNotEmpty
        ? _postData!.user.first.name ?? 'Unknown'
        : _userData?.name ?? 'Unknown';
    final userImagePath = _postData!.user.isNotEmpty
        ? _postData!.user.first.image
        : _userData?.image;
    final userImage = userImagePath?.fileUrl;

    // Get file URL
    final fileUrl = firstFile?.file?.fileUrl;
    final thumbnailUrl = firstFile?.thumbnail?.fileUrl;

    AppUtils.log('🎨 Building post card:');
    AppUtils.log('  - userName: $userName');
    AppUtils.log('  - userImage: $userImage');
    AppUtils.log('  - fileUrl: $fileUrl');
    AppUtils.log('  - isVideo: $isVideo');

    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          // Log current post data before opening detail screen
          AppUtils.log('🔍 Opening post detail screen:');
          AppUtils.log('  - Post ID: ${_postData!.id}');
          AppUtils.log('  - isLikedByUser: ${_postData!.isLikedByUser}');
          AppUtils.log('  - likeCount: ${_postData!.likeCount}');
          AppUtils.log(
            '  - Likes array length: ${_postData!.likes?.length ?? 0}',
          );
          AppUtils.log('  - User array length: ${_postData!.user.length}');

          // Ensure post has complete user data before opening detail screen
          PostData postToOpen = _postData!;

          // Check if current user has liked the post by checking likes array
          bool isLikedByCurrentUser = false;
          if (postToOpen.likes != null && postToOpen.likes!.isNotEmpty) {
            isLikedByCurrentUser = postToOpen.likes!.any((like) {
              if (like is Map) {
                return like['userId'] == Preferences.uid ||
                    like['_id'] == Preferences.uid;
              } else if (like is String) {
                return like == Preferences.uid;
              }
              return false;
            });
            AppUtils.log(
              '✅ Checked likes array - isLiked: $isLikedByCurrentUser',
            );
          }

          // If user array is empty but we have fetched user data, populate it
          if (postToOpen.user.isEmpty && _userData != null) {
            AppUtils.log(
              '📝 Populating post user array with fetched user data',
            );
            // Use copyWith to preserve all existing data and set isLikedByUser
            postToOpen = postToOpen.copyWith(
              isLikedByUser: isLikedByCurrentUser,
              user: [
                User(
                  id: _userData!.id,
                  name: _userData!.name,
                  image: _userData!.image,
                  email: _userData!.email,
                  phone: _userData!.phone,
                  gender: _userData!.gender,
                  role: _userData!.role,
                ),
              ],
            );

            AppUtils.log('✅ Post data prepared with user info:');
            AppUtils.log('  - User: ${_userData!.name}');
            AppUtils.log('  - isLikedByUser: ${postToOpen.isLikedByUser}');
            AppUtils.log('  - likeCount: ${postToOpen.likeCount}');
            AppUtils.log('  - commentCount: ${postToOpen.commentCount}');
          } else {
            // User data already in post, but still need to set isLikedByUser
            AppUtils.log('✅ User data already in post, setting isLikedByUser');
            postToOpen = postToOpen.copyWith(
              isLikedByUser: isLikedByCurrentUser,
            );
            AppUtils.log(
              '  - isLikedByUser being passed: ${postToOpen.isLikedByUser}',
            );
          }

          // Open full post in PostDetailScreen with complete data
          Get.to(() => PostDetailScreen(postData: postToOpen));
        },
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: widget.isSentByUser
                ? AppColors.primaryColor.withOpacity(0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSentByUser
                  ? AppColors.primaryColor.withOpacity(0.3)
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info header
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    // User avatar
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      backgroundImage: userImage != null
                          ? NetworkImage(userImage)
                          : null,
                      child: userImage == null
                          ? Icon(
                              Icons.person,
                              size: 14,
                              color: AppColors.primaryColor,
                            )
                          : null,
                    ),
                    SizedBox(width: 8),
                    // User name
                    Expanded(
                      child: Text(
                        userName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Media preview
              if (hasMedia && fileUrl != null)
                Stack(
                  children: [
                    // Image/video
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(0),
                      ),
                      child: Image.network(
                        isVideo && thumbnailUrl != null
                            ? thumbnailUrl
                            : fileUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          AppUtils.logEr('Image load error: $error');
                          return Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                isVideo ? Icons.videocam : Icons.image,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Video play icon
                    if (isVideo)
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),

                    // Multiple media badge
                    if (_postData!.files.length > 1)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.collections,
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${_postData!.files.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

              // Content preview
              if (_postData!.content?.isNotEmpty == true)
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Text(
                    _postData!.content!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Stats footer
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tap to view post',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

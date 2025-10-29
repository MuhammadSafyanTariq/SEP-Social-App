// import 'package:flutter/material.dart';
// import 'package:sep/components/coreComponents/TextView.dart';
// import 'package:sep/components/styles/appColors.dart';
// import 'package:sep/components/styles/textStyles.dart';
// import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
// import 'package:sep/services/storage/preferences.dart';
// import 'package:sep/utils/extensions/extensions.dart';
// import 'package:sep/utils/extensions/size.dart';
// import '../../../services/networking/urls.dart';
// import '../../../utils/appUtils.dart';
// import '../../data/repository/iTempRepository.dart';
// import '../Home/homeScreenComponents/deletePostCard.dart';
// import '../Home/homeScreenComponents/postCard.dart';
// import '../Home/homeScreenComponents/post_components.dart';
//
// class DeletePostScreen extends StatelessWidget {
//   final String postId;
//   final String userName;
//   final String profileImageUrl;
//   final String time;
//   final String location;
//   final String caption;
//   final List<String> imageUrls;
//   final String likes;
//   final int comments;
//
//   const DeletePostScreen({
//     super.key,
//     required this.postId,
//     required this.userName,
//     required this.profileImageUrl,
//     required this.time,
//     required this.location,
//     required this.caption,
//     required this.imageUrls,
//     required this.likes,
//     required this.comments,
//   });
//
//   Future<void> _deletePost(BuildContext context) async {
//     final response = await ITempRepository().deletePost(postId).applyLoader;
//     if (response.isSuccess) {
//       AppUtils.log("Post deleted successfully");
//       ProfileCtrl().postList.removeWhere((p) => p.id == postId);
//       Navigator.pop(context);
//     } else {
//       AppUtils.log("Failed to delete post: \${response.exception ?? response.error}");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to delete post")),
//       );
//     }
//   }
//
//   void _showPostOptions(BuildContext context, String id) {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16.sdp)),
//       ),
//       backgroundColor: Colors.black,
//       builder: (context) => PostOptions(onDelete: () => _deletePost(context)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final userPosts = ProfileCtrl.find.postList;
//     final name = Preferences.profile?.name;
//
//     final filteredPosts = userPosts.where((post) =>
//     (post.files?.isNotEmpty ?? false) &&
//         post.files!.any((file) =>
//         file.file != null &&
//             file.file!.isNotEmpty &&
//             !(file.type == "video")
//         )).toList();
//
//     AppUtils.log("Total valid posts: ${filteredPosts.length}");
//
//     if (filteredPosts.isEmpty) return const SizedBox.shrink();
//
//     return Scaffold(
//       backgroundColor: AppColors.black,
//       appBar: AppBar(
//         centerTitle: true,
//         title: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextView(text: name.toString(), style: 14.txtRegularWhite),
//             TextView(text: "Posts", style: 14.txtRegularWhite),
//           ],
//         ),
//         backgroundColor: AppColors.black,
//       ),
//       body: ListView.builder(
//         padding: EdgeInsets.all(10.sdp),
//         itemCount: filteredPosts.length,
//         itemBuilder: (context, index) {
//           final post = filteredPosts[index];
//
//           return DeletePostCard(
//             onTap: () => _showPostOptions(context, post.id ?? ''),
//             userName: '',
//             profileImageUrl: '',
//             time: formatTimeAgo(post.createdAt ?? ''),
//             location: post.location?.type ?? '',
//             caption: post.content ?? '',
//             imageUrls: post.files?.map((file) => file.file ?? '').toList() ?? [],
//             likes: '',
//             comments: 2, userId: postId,
//           );
//         },
//       ),
//     );
//   }
// }
//
//
//
// class PostOptions extends StatelessWidget {
//   final VoidCallback onDelete;
//
//   const PostOptions({super.key, required this.onDelete});
//
//   void _confirmDelete(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.black,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.sdp)),
//         title: Center(child: TextView(text: "Delete Post", style: 20.txtMediumWhite)),
//         content: TextView(
//           text: "Are you sure you want to delete this post?",
//           style: 16.txtRegularWhite,
//           textAlign: TextAlign.center,
//         ),
//         actionsAlignment: MainAxisAlignment.spaceEvenly,
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: TextView(text: "Cancel", style: 14.txtRegularWhite),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//               onDelete();
//             },
//             child: TextView(text: "Delete", style: 14.txtRegularError),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       children: [
//         Padding(
//           padding: 30.left + 20.bottom,
//           child: ListTile(
//             contentPadding: const EdgeInsets.symmetric(vertical: 12),
//             onTap: () => _confirmDelete(context),
//             leading: const Icon(Icons.delete, color: Colors.redAccent),
//             title: const Text("Delete Post", style: TextStyle(color: Colors.redAccent)),
//           ),
//         ),
//       ],
//     );
//   }
// }

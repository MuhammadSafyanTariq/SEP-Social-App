// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:sep/components/styles/textStyles.dart';
// import 'package:sep/feature/data/models/dataModels/post_data.dart';
// import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
// import 'package:sep/utils/extensions/contextExtensions.dart';
// import 'package:sep/utils/extensions/size.dart';
// import 'package:sep/utils/extensions/textStyle.dart';
// import 'package:sep/utils/extensions/widget.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import '../../../../components/coreComponents/TextView.dart';
// import '../../../../components/coreComponents/loadOptimizedImage.dart';
// import '../../../../components/styles/appColors.dart';
// import '../../../../components/styles/appImages.dart';
// import '../../../../services/networking/urls.dart';
// import '../comment.dart';
// import '../option.dart';
// import '../otheruserprofile.dart';
//
// class DeletePostCard extends StatelessWidget {
//   final String userId;
//   final String userName;
//   final String profileImageUrl;
//   final String time;
//   final String location;
//   final String caption;
//   final List<String> imageUrls;
//   final String likes;
//   final int comments;
//   final VoidCallback? onTap;
//
//   DeletePostCard({
//     Key? key,
//     required this.userId,
//
//     required this.userName,
//     required this.profileImageUrl,
//     required this.time,
//     required this.location,
//     required this.caption,
//     required this.imageUrls,
//     required this.likes,
//     required this.comments, this.onTap,
//   }) : super(key: key);
//
//   final PageController _pageController = PageController();
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(40.sdp),
//       child: Card(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.sdp),
//         ),
//         margin: 10.all,
//         color: Colors.white,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: 10.top + 10.left,
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       context.pushNavigator(OtheruserProfile());
//                     },
//                     child: CircleAvatar(
//                         backgroundImage: AssetImage(AppImages.postImg)
//                       // NetworkImage(profileImageUrl),
//                     ),
//                   ),
//                  10.width,
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         TextView(text: userName, style: 15.txtMediumBlack),
//                         Row(
//                           children: [
//                             TextView(text: "$time • ", style: 12.txtRegularGrey),
//                             Icon(Icons.location_on, size: 13, color: AppColors.black),
//                             TextView(text: location, style: 12.txtRegularBlack),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.more_vert),
//                     onPressed: onTap ?? () {
//                       showModalBottomSheet(
//                         context: context,
//                         isScrollControlled: true,
//                         backgroundColor: Colors.transparent,
//                         builder: (BuildContext context) {
//                           return Options(
//                             onBlockSuccess: (){},
//                             data: ProfileDataModel(),
//                             name: userName, postUserId:userId, loginUserId: userId ,
//                             // postImage: ""
//                             postData: PostData(),
//                             );
//                         },
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//
//
//             Padding(
//               padding: 10.horizontal + 8.vertical,
//               child: TextView(text: caption, style: 10.txtRegularBlack),
//             ),
//
//           if (imageUrls.isNotEmpty)
//       SizedBox(
//       height: 260.sdp,
//       child: PageView.builder(
//         controller: _pageController,
//         itemCount: imageUrls.length,
//         itemBuilder: (context, index) {
//           return FutureBuilder<ImageProvider?>(
//             future: loadOptimizedImage(imageUrls[index], baseUrl),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting || snapshot.hasError || !snapshot.hasData) {
//                 return Shimmer.fromColors(
//                   baseColor: Colors.grey[300]!,
//                   highlightColor: AppColors.grey,
//                   child: Container(
//                     width: double.infinity,
//                     height: 260.sdp,
//                     color: Colors.white,
//                   ),
//                 );
//               }
//               return Image(
//                 image: snapshot.data!,
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: 260.sdp,
//               );
//             },
//           );
//         },
//       ),
//     ),
//     15.height,
//     if (imageUrls.length > 1)
//               Center(
//                 child: SmoothPageIndicator(
//                   controller: _pageController,
//                   count: imageUrls.length,
//                   effect: ExpandingDotsEffect(
//                     activeDotColor: AppColors.btnColor,
//                     dotColor: AppColors.Grey,
//                     dotHeight: 4,
//                     dotWidth: 10,
//                   ),
//                 ),
//               ),
//
//             Padding(
//               padding:10.horizontal + 15.vertical,
//               child: Row(
//                 children: [
//                   Row(
//                     children: [
//                       SvgPicture.asset("assets/images/likesvg.svg"),
//                       5.width,
//                       TextView(text: "$likes Likes", style: 12.txtRegularGrey),
//                     ],
//                   ),
//                   15.width,
//                   InkWell(
//                     onTap: () {
//                       showModalBottomSheet(
//                         context: context,
//                         isScrollControlled: true,
//                         backgroundColor: Colors.transparent,
//                         builder: (BuildContext context) => CommentScreen(postId: '', onCommentAdded: (int ) {  },),
//                       );
//                     },
//                     child: Row(
//                       children: [
//                         SvgPicture.asset("assets/images/mesgsvg.svg"),
//                         const SizedBox(width: 5),
//                         TextView(text: "$comments Comments", style: 12.txtRegularGrey),
//                       ],
//                     ),
//                   ),
//                   Spacer(),
//                   TextView(text: "Share", style: 12.txtboldBtncolor, onTap: () {}),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

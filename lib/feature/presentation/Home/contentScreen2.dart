// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:get/get.dart';
// import 'package:sep/components/appLoader.dart';
// import 'package:sep/components/coreComponents/ImageView.dart';
// import 'package:sep/components/coreComponents/TextView.dart';
// import 'package:sep/components/styles/appColors.dart';
// import 'package:sep/components/styles/appImages.dart';
// import 'package:sep/components/styles/textStyles.dart';
// import 'package:sep/feature/data/models/dataModels/Createpost/getcategory_model.dart';
// import 'package:sep/feature/data/models/dataModels/post_data.dart';
// import 'package:sep/utils/appUtils.dart';
// import 'package:sep/utils/extensions/contextExtensions.dart';
// import 'package:sep/utils/extensions/extensions.dart';
// import 'package:sep/utils/extensions/widget.dart';
// import '../../../services/networking/urls.dart';
// import '../../data/models/dataModels/profile_data/profile_data_model.dart';
// import '../Add post/categoryselection.dart';
// import '../controller/auth_Controller/profileCtrl.dart';
// import '../controller/createpost/createpost_ctrl.dart';
// import 'comment.dart';
// import 'homeScreenComponents/pollCard.dart';
// import 'homeScreenComponents/postCard.dart';
// import 'homeScreenComponents/postVideo.dart';
// import 'homeScreenComponents/post_card_header.dart';
//
// class Contentscreen extends StatefulWidget {
//   const Contentscreen({Key? key}) : super(key: key);
//
//   @override
//   State<Contentscreen> createState() => _ContentscreenState();
// }
//
// class _ContentscreenState extends State<Contentscreen> {
//
//   List<Categories> get categories {
//     final list = CreatePostCtrl.find.getCategories;
//     return [Categories(
//       id:null,
//       name: 'All'
//     ),...list];
//   }
//
//   Rx<Categories> selectedCategory = Rx(Categories(
//       id:null,
//       name: 'All'
//   ));
//
//   final ProfileCtrl profileCtrl = Get.put(ProfileCtrl());
//   final ScrollController _scrollController = ScrollController();
//   // final RxBool _isLoading = false.obs;
//   bool isLoadingMore = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadInitialPosts();
//     _scrollController.addListener(_scrollListener);
//     CreatePostCtrl.find.getPostCategories();
//   }
//
//   void _scrollListener() {
//     if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 &&
//         // !_isLoading.value &&
//         profileCtrl.hasMoreData) {
//       _loadMorePosts();
//     }
//   }
//
//   Future _loadInitialPosts({bool isRefresh = false}) async {
//
//     await profileCtrl.globalList(offset: 0, selectedCat: selectedCategory.value);
//     return;
//     // _isLoading.value = false;
//   }
//
//   Future<void> _loadMorePosts() async {
//     if (
//     // _isLoading.value ||
//         isLoadingMore || !profileCtrl.hasMoreData) return;
//     setState(() => isLoadingMore = true);
//     int offset = profileCtrl.globalPostList.length;
//     await profileCtrl.globalList(offset: offset,selectedCat: selectedCategory.value).applyLoaderWithOption(profileCtrl.globalPostList.isEmpty);
//     setState(() => isLoadingMore = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           context.pushNavigator(CategorySelection(isPoll: true,));
//         },
//         child: ImageView(url: "assets/images/floating.png"),
//       ),
//       body: Column(
//         children: [
//           _buildFilterBar(),
//           Expanded(child: _buildPostList()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterBar() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         color: Colors.black,
//         height: 50,
//         child: Obx(
//           ()=> ListView.builder(
//             scrollDirection: Axis.horizontal,
//             // itemCount: filters.length,
//             itemCount: categories.length,
//             itemBuilder: (context, index) {
//
//               return GestureDetector(
//                 onTap: () {
//                   selectedCategory.value = categories[index];
//                   selectedCategory.refresh();
//                   _loadInitialPosts().applyLoader;
//                 },
//                 child: Obx(
//                     ()=> Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: categories[index].name == selectedCategory.value.name && categories[index].id == selectedCategory.value.id ?
//                        AppColors.btnColor : Colors.white,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: Center(
//                       child: TextView(
//                         // text: filters[index],
//                         text: categories[index].name ?? '',
//                         style: TextStyle(
//                           color: categories[index].name == selectedCategory.value.name && categories[index].id == selectedCategory.value.id
//                           ? Colors.white : AppColors.btnColor,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//         String address = '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
//         return address;
//       }
//     } catch (e) {
//       print("Error retrieving address: $e");
//     }
//     return "No Address Found";
//   }
//   Widget _buildPostList() {
//     return Obx(() {
//       if (profileCtrl.globalPostList.isEmpty) return Center(child: TextView(text: "No posts available"));
//
//       return RefreshIndicator(
//         onRefresh: () async => _loadInitialPosts(),
//         child: ListView.builder(
//           controller: _scrollController,
//           itemCount: profileCtrl.globalPostList.length + (isLoadingMore ? 1 : 0),
//           itemBuilder: (context, index) {
//             if (index >= profileCtrl.globalPostList.length) {
//               return Padding(padding: EdgeInsets.all(10), child: AppLoader.loaderWidget());
//             }
//             return _buildPostWidget(profileCtrl.globalPostList[index]);
//           },
//         )
//     );
//
//         } );}
//
//   Widget _buildPostWidget(PostData item) {
//     final coordinates = item.location?.coordinates;
//
//     return FutureBuilder<String>(
//         future: coordinates != null
//             ? getAddressFromCoordinates(coordinates[1], coordinates[0])
//             : Future.value(""),
//         builder: (context, snapshot) {
//           String address = "Loading...";
//
//           if (snapshot.connectionState == ConnectionState.done) {
//             address = snapshot.hasData ? snapshot.data! : "No Address Found";
//           }
//           final userProfile = ProfileDataModel(
//             id: item.userId ?? '',
//             name: "User  Name",
//           );
//           final header = PostCardHeader(
//             time: formatTimeAgo(item.createdAt ?? ''),
//             userData: userProfile,
//             location: snapshot.connectionState == ConnectionState.done
//                 ? (snapshot.hasData ? address : "No Address Found")
//                 : "Loading...", data: item, // You can also show "Loading..." while waiting for the address
//           );
//
//           final footer = Column(
//             children: [
//               SizedBox(height: 10),
//               Padding(
//                 padding: const EdgeInsets.only(right: 10, left: 10, bottom: 15),
//                 child: Container(
//                   height: 50,
//                   width: double.infinity,
//                   color: AppColors.contcolor,
//                   child: Row(
//                     children: [
//                       12.width,
//                       Row(
//                         children: [
//                           SvgPicture.asset("assets/images/likesvg.svg"),
//                           const SizedBox(width: 5),
//                           TextView(
//                             text: "",
//                             style: 12.txtRegularBlack,
//                           ),
//                           TextView(
//                             text: " Likes",
//                             style: 12.txtRegularGrey,
//                           ),
//                         ],
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 15.0),
//                         child: InkWell(
//                             onTap: () {
//                               showModalBottomSheet(
//                                 context: context,
//                                 isScrollControlled: true,
//                                 backgroundColor: Colors.transparent,
//                                 builder: (BuildContext context) {
//                                   return Container(
//                                     height:
//                                     MediaQuery.of(context).size.height * 0.6,
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(20),
//                                         topRight: Radius.circular(20),
//                                       ),
//                                     ),
//                                     child: Column(
//                                       children: [
//                                         // Expanded(
//                                         //   child: CommentScreen(),
//                                         // ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                             child: Row(
//                               children: [
//                                 SvgPicture.asset("assets/images/mesgsvg.svg"),
//                                 const SizedBox(width: 5),
//                                 TextView(
//                                   text: "2",
//                                   style: 12.txtRegularBlack,
//                                 ),
//                                 TextView(
//                                   text: " Comments",
//                                   style: 12.txtRegularGrey,
//                                 )
//                               ],
//                             )),
//                       ),
//                       Spacer(),
//                       Padding(
//                         padding: const EdgeInsets.only(right: 14.0),
//                         child: TextView(
//                           text: "Share",
//                           style: 12.txtboldBtncolor,
//                           onTap: () {},
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//
//     if (item.fileType == 'poll') {
//       return PollCard(
//         footer: footer,
//         data: item,
//         header: header,
//         question: item.content ?? '',
//         options: item.options ?? [],
//         // selectedOption: null,
//
//         onPollAction: (String optionId){
//           profileCtrl.givePollToHomePost(item,optionId).applyLoader;
//           AppUtils.log(optionId);
//         },
//         starttime: DateTime.parse(item.startTime.toString()), // Ensure this is a DateTime
//         endtime: DateTime.parse(item.endTime.toString()), // Ensure this is a DateTime
//       );
//     } else if (item.files != null && item.files!.isNotEmpty && item.files!.first.type == 'video') {
//       return PostVideo(
//         header: header,
//         caption: item.content ?? '',
//         videoUrl: _getFormattedVideoUrl(item.files?.first.file),
//         likes: '',
//         comments: '',
//         footer: footer
//       );
//     } else {
//       return PostCard(
//         header: header,
//         caption: item.content ?? '',
//         imageUrls: item.files ?? <FileElement>[],
//         likes: '',
//         comments: '',
//           footer: footer
//       );
//     }
//   });}
//
//
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
// }
//
// String _getFormattedImageUrl(String filePath) {
//   return filePath.startsWith("http") ? filePath : "$baseUrl$filePath";
// }
//
// String _getFormattedVideoUrl(String? video) {
//   if (video == null || video.isEmpty) return "";
//   return video.startsWith("http") ? video : "$baseUrl$video";
// }
//
// String formatTimeAgo(String createdAt) {
//   DateTime? postTime;
//   try{
//      postTime = DateTime.tryParse(createdAt);
//   }catch(e){
//
//     AppUtils.log('Date Format issuee....... $createdAt');
//     postTime = DateTime.now();
//   }
//
//   Duration difference = DateTime.now().difference(postTime!);
//
//   if (difference.inSeconds < 60) return '${difference.inSeconds} seconds ago';
//   if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
//   if (difference.inHours < 24) return '${difference.inHours} hours ago';
//   if (difference.inDays < 7) return '${difference.inDays} days ago';
//   if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
//   if (difference.inDays < 365) return '${(difference.inDays / 30).floor()} months ago';
//   return '${(difference.inDays / 365).floor()} years ago';
// }

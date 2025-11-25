import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/feature/data/models/dataModels/Createpost/address_model.dart';
import 'package:sep/feature/presentation/controller/createpost/createpost_ctrl.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:video_player/video_player.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../components/coreComponents/appDropDown.dart';
import '../../../utils/appUtils.dart';
import '../../../utils/image_utils.dart';
import '../../data/models/dataModels/Createpost/getcategory_model.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../../data/repository/iAuthRepository.dart';
import '../Home/homeScreen.dart';
import '../controller/auth_Controller/profileCtrl.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

class CreatePost extends StatefulWidget {
  final String categoryid;
  CreatePost({super.key, required this.categoryid});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _postController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();
  ProfileDataModel? profiledata;
  final IAuthRepository authRepository = IAuthRepository();
  List<MediaItem> _mediaItems = [];
  XFile? _selectedMedia;
  // Category data
  List<Categories> categories = [];
  Categories? selectedCategory;

  String? userId = Preferences.uid.toString();
  String? _selectedCountry;
  bool isVideo = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    AppUtils.log(
      "CreatePost initialized with categoryid: '${widget.categoryid}'",
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      profileCtrl.getProfileDetails();
    });
    fetchCategories();
  }

  // Helper method to sort categories in the specified order
  List<Categories> _sortCategories(List<Categories> categories) {
    // Define the desired order
    const order = [
      'sports',
      'entertainment',
      'perception',
      'politics',
      'advertisement',
      'others',
      'other',
    ];

    return categories..sort((a, b) {
      final aName = a.name?.toLowerCase() ?? '';
      final bName = b.name?.toLowerCase() ?? '';

      final aIndex = order.indexOf(aName);
      final bIndex = order.indexOf(bName);

      // If both are in the order list, sort by their position
      if (aIndex != -1 && bIndex != -1) {
        return aIndex.compareTo(bIndex);
      }

      // If only a is in the order list, it comes first
      if (aIndex != -1) return -1;

      // If only b is in the order list, it comes first
      if (bIndex != -1) return 1;

      // If neither is in the order list, sort alphabetically
      return aName.compareTo(bName);
    });
  }

  Future<void> fetchCategories() async {
    try {
      await CreatePostCtrl.find.getPostCategories().applyLoaderWithOption(
        CreatePostCtrl.find.getCategories.isEmpty,
      );

      setState(() {
        categories = _sortCategories(
          CreatePostCtrl.find.getCategories.isNotEmpty
              ? CreatePostCtrl.find.getCategories
              : [],
        );
      });

      AppUtils.log("Fetched Categories count: ${categories.length}");

      // Detailed logging for each category
      for (int i = 0; i < categories.length; i++) {
        final cat = categories[i];
        AppUtils.log(
          "Category $i: name='${cat.name}', id='${cat.id}', hasValidId=${cat.id != null && cat.id!.isNotEmpty}",
        );
      }

      // Check if we have any categories with valid IDs
      final validCategories = categories
          .where((cat) => cat.id != null && cat.id!.isNotEmpty)
          .toList();
      AppUtils.log(
        "Categories with valid IDs: ${validCategories.length}/${categories.length}",
      );

      if (validCategories.isEmpty && categories.isNotEmpty) {
        AppUtils.log(
          "WARNING: All categories have invalid IDs! Raw category data: ${categories.map((c) => c.toString()).join(', ')}",
        );
      }

      // If a category ID was passed in constructor, try to find and select it
      if (widget.categoryid.isNotEmpty && selectedCategory == null) {
        final preSelectedCategory = categories.firstWhere(
          (cat) => cat.id == widget.categoryid,
          orElse: () => Categories(), // Return empty category if not found
        );

        if (preSelectedCategory.id != null &&
            preSelectedCategory.id!.isNotEmpty) {
          setState(() {
            selectedCategory = preSelectedCategory;
          });
          AppUtils.log(
            "Pre-selected category from constructor: ${preSelectedCategory.name} (ID: ${preSelectedCategory.id})",
          );
        } else {
          AppUtils.log("Could not find category with ID: ${widget.categoryid}");
        }
      }
    } catch (e) {
      AppUtils.log("Error fetching categories: $e");
      AppUtils.toastError(
        "Failed to load categories. Please check your internet connection.",
      );
    }
  }

  Future<ui.Size> getImageSize(File file) async {
    Uint8List bytes = await file.readAsBytes();
    ui.Image image = await decodeImageFromList(bytes);
    return ui.Size(image.width.toDouble(), image.height.toDouble());
  }

  Future<ui.Size> getVideoResolution(String path) async {
    final controller = VideoPlayerController.file(File(path));
    await controller.initialize(); // loads metadata
    final size = ui.Size(
      controller.value.size.width,
      controller.value.size.height,
    );

    await controller.dispose();
    return size;
  }

  Future<Uint8List?> getThumbnail(
    String file,
    // , double height, double width
  ) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: file,
      quality: 100,
      imageFormat: ImageFormat.JPEG,
    );
    return uint8list;
  }

  Future<void> chooseImage() async {
    if (_mediaItems.length >= 6) {
      AppUtils.toastError("You can only upload up to 6 images or videos.");
      return;
    }

    if (_selectedMedia != null) {
      setState(() {
        _selectedMedia = null;
      });
    }

    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      int remainingSlots = 6 - _mediaItems.length;

      for (var file in pickedFiles.take(remainingSlots)) {
        final fileData = File(file.path);
        // 👇 Await outside setState
        // final size = await getImageSize(fileData);

        setState(() {
          _mediaItems.add(
            MediaItem(
              file: fileData,
              isVideo: false,
              // x: size.width,   // You can store size if needed
              // y: size.height,
            ),
          );
        });
      }
    }
  }

  void _pickVideo() async {
    final XFile? media = await _picker.pickVideo(source: ImageSource.gallery);

    if (media != null) {
      // Check video duration before proceeding
      final controller = VideoPlayerController.file(File(media.path));
      try {
        await controller.initialize();
        final duration = controller.value.duration;

        // Check if video is longer than 90 seconds
        if (duration.inSeconds > 90) {
          AppUtils.toastError("You can't upload videos longer than 90 seconds");
          await controller.dispose();
          return;
        }

        await controller.dispose();
      } catch (e) {
        AppUtils.log("Error checking video duration: $e");
        AppUtils.toastError(
          "Error processing video. Please try another video.",
        );
        return;
      }

      // String networkThumbnailUrl = "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhgBO9es3gnfmoILLgaplnrfQCAqYKl_rGf2TqRead8WjoMnpJ-rS7fFWEBn0oJy_-U1DFeTM-Gle7-Humwy3KDO8EjV0G3a7M6QOkEd2CPXaRbYWR94aRuiYp4sn9gttYvNpwS5X1etudg/s1600/file-MrylO8jADD.png";
      // final size = await getVideoResolution(media.path);
      final thumbnail = await getThumbnail(
        media.path,
        // , size.height, size.width
      );

      setState(() {
        _mediaItems.add(
          MediaItem(
            file: File(media.path),
            isVideo: true,
            // thumbnailUrl: networkThumbnailUrl,
            thumnailFile: thumbnail,
            // x: size.width,
            // y: size.height
          ),
        );
      });
    }
  }

  Future<void> _submitPost(BuildContext context) async {
    // Prevent multiple clicks
    if (_isUploading) {
      AppUtils.log("Upload already in progress, ignoring duplicate click");
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      AppUtils.log("Starting post submission...");

      if (_mediaItems.isEmpty && _postController.text.trim().isEmpty) {
        AppUtils.toastError(
          "Please add a post link or select at least one image/video",
        );
        return;
      }

      // Ensure a category is selected - use first category if none selected
      if (selectedCategory == null) {
        if (categories.isNotEmpty) {
          // Find first category with valid ID
          Categories? validCategory;
          for (var category in categories) {
            if (category.id != null && category.id!.isNotEmpty) {
              validCategory = category;
              break;
            }
          }

          if (validCategory != null) {
            selectedCategory = validCategory;
            AppUtils.log(
              "Auto-selected valid category: ${selectedCategory?.name} (ID: ${selectedCategory?.id})",
            );
          } else {
            AppUtils.toastError(
              'No valid categories found. Please check your internet connection and try again.',
            );
            AppUtils.log(
              "ERROR: No categories with valid IDs found. Total categories: ${categories.length}",
            );
            return;
          }
        } else {
          AppUtils.toastError(
            'No categories available. Please check your internet connection and try again.',
          );
          return;
        }
      }

      // Additional debugging for selected category
      AppUtils.log(
        "Selected category details: name=${selectedCategory?.name}, id=${selectedCategory?.id}, full_object=${selectedCategory.toString()}",
      );

      // LatLng location = await _getCurrentLocation();
      LatLng location = LatLng(0, 0);

      // if (_mediaItems.isEmpty) {
      //   AppUtils.toastError("Please select at least one image or video");
      //   return;
      // }

      // AppLoader.showLoader(context);
      List<Map<String, dynamic>> uploadedFiles = [];

      // try {

      Future<(String, ui.Size)?> uploadFile(data, bool isImage) async {
        bool isUint8 = data is Uint8List;
        final response = await authRepository.uploadPhoto(
          imageFile: isUint8 ? null : data,
          memoryFile: isUint8 ? data : null,
        );
        if (response.isSuccess) {
          List<String> data = response.data ?? [];
          if (data.isNotEmpty) {
            String fileUrl = data.first;
            final size = isImage
                ? await getNetworkImageSize(fileUrl.fileUrl ?? '')
                : ui.Size.zero;
            return (fileUrl, size);
          }
        }
        return null;
      }

      for (MediaItem mediaItem in _mediaItems) {
        if (!mediaItem.file.existsSync()) {
          AppUtils.log("File does not exist: ${mediaItem.file.path}");
        } else {
          (String, ui.Size)? thumbnailUrl;
          if (mediaItem.isVideo) {
            thumbnailUrl = await uploadFile(mediaItem.thumnailFile, true);
          }
          final fileUrlData = await uploadFile(
            mediaItem.file,
            !mediaItem.isVideo,
          );
          if (fileUrlData != null) {
            uploadedFiles.add({
              "file": fileUrlData.$1,
              "type": mediaItem.isVideo ? 'video' : "image",
              ...(thumbnailUrl != null
                  ? {
                      'thumbnail': thumbnailUrl.$1,
                      'x': thumbnailUrl.$2.width,
                      'y': thumbnailUrl.$2.height,
                    }
                  : {'x': fileUrlData.$2.width, 'y': fileUrlData.$2.height}),
            });
          }
        }
      }

      final categoryId = selectedCategory?.id ?? '';
      AppUtils.log("Final category ID before API call: '$categoryId'");
      AppUtils.log("Selected category: ${selectedCategory?.name}");

      // Final validation - ensure category ID is not empty
      if (categoryId.isEmpty) {
        AppUtils.log(
          "ERROR: Category ID is empty. Selected category: ${selectedCategory?.name}, Available categories: ${categories.length}",
        );
        for (var cat in categories.take(3)) {
          AppUtils.log("Category sample: ${cat.name} (ID: '${cat.id}')");
        }

        // Last resort - check if we passed a categoryId from constructor
        if (widget.categoryid.isNotEmpty) {
          AppUtils.log(
            "Using fallback category ID from constructor: ${widget.categoryid}",
          );
          // Use the categoryId passed from constructor
          final fallbackCategoryId = widget.categoryid;

          await CreatePostCtrl.find
              .createPosts(
                userId.toString(),
                fallbackCategoryId,
                _postController.text,
                AddressModel(country: _selectedCountry),
                {
                  "latitude": location.latitude,
                  "longitude": location.longitude,
                  "country": _selectedCountry ?? " ",
                },
                uploadedFiles,
                null,
                "post",
                null,
                null,
                null,
              )
              .applyLoader;

          context.pushAndClearNavigator(HomeScreen());
          return;
        }

        AppUtils.toastError(
          'Category validation failed. Please select a category manually or restart the app.',
        );
        return;
      }

      await CreatePostCtrl.find
          .createPosts(
            userId.toString(),
            categoryId,
            _postController.text,
            AddressModel(country: _selectedCountry),
            {
              "latitude": location.latitude,
              "longitude": location.longitude,
              "country": _selectedCountry ?? " ",
            },
            uploadedFiles,
            null,
            "post",
            null,
            null,
            null,
          )
          .applyLoader;

      context.pushAndClearNavigator(HomeScreen());
    } catch (e) {
      AppUtils.log("Error during post submission: $e");
      AppUtils.toastError("Failed to create post. Please try again.");
    } finally {
      // Always reset loading state
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  String _getCategoryDisplayName(String? categoryName) {
    if (categoryName == null) return 'No Category Available';
    // Map "Politics" to "Perception" for display
    if (categoryName == 'Politics') return 'Perception';

    // Capitalize category names that start with lowercase
    if (categoryName.isNotEmpty &&
        categoryName[0].toLowerCase() == categoryName[0]) {
      return categoryName[0].toUpperCase() + categoryName.substring(1);
    }

    return categoryName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: TextView(
          text: "Post",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: _isUploading ? null : () => _submitPost(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isUploading
                        ? AppColors.greenlight.withOpacity(0.6)
                        : AppColors.greenlight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _isUploading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            TextView(
                              text: "Uploading...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : TextView(
                          text: "Upload",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Upload Section
            _buildMediaUploadSection(),

            SizedBox(height: 20),

            // Selected Media Display (auto-adjusting height)
            if (_mediaItems.isNotEmpty) ...[
              _selectedMediaWidget(),
              SizedBox(height: 20),
            ],

            // Caption Section
            _buildCaptionSection(),

            SizedBox(height: 20),

            // Location Section
            _buildLocationSection(),

            SizedBox(height: 20),

            // Category Selection
            _buildCategorySection(),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: "Upload Image/Video",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[50],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: Colors.grey[500],
              ),
              SizedBox(height: 8),
              TextView(
                text: "Tap to upload from gallery or camera",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMediaButton(
                    icon: Icons.photo_library,
                    label: "Images",
                    onTap: chooseImage,
                  ),
                  SizedBox(width: 20),
                  _buildMediaButton(
                    icon: Icons.videocam,
                    label: "Videos",
                    onTap: _pickVideo,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[700]),
            SizedBox(width: 6),
            TextView(
              text: label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: "Caption",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _postController,
            maxLength: 600,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Write a caption...",
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
              counterText: "${_postController.text.length}/600",
              counterStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            onChanged: (text) {
              setState(() {}); // Refresh counter
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: "Location",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return CountryPickerDropdown(
                  onCountrySelected: (String country) {
                    setState(() {
                      _selectedCountry = country;
                    });
                  },
                );
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey[600],
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextView(
                    text: _selectedCountry ?? "Add location",
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedCountry != null
                          ? Colors.black
                          : Colors.grey[500],
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category_outlined, size: 20, color: Colors.grey[600]),
            SizedBox(width: 8),
            TextView(
              text: "Select a Category",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Spacer(),
            if (categories.isEmpty ||
                categories.every((cat) => cat.id == null || cat.id!.isEmpty))
              GestureDetector(
                onTap: () {
                  AppUtils.log("Refreshing categories...");
                  fetchCategories();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.btnColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.btnColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: 16, color: AppColors.btnColor),
                      SizedBox(width: 4),
                      TextView(
                        text: "Refresh",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.btnColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Icon(Icons.keyboard_arrow_down, color: AppColors.btnColor),
          ],
        ),
        SizedBox(height: 8),
        AppDropDown<Categories>.singleSelect(
          title: 'Choose category',
          list: [...categories],
          selectedValue: selectedCategory,
          singleValueBuilder: (category) =>
              _getCategoryDisplayName(category.name),
          itemBuilder: (category) => _getCategoryDisplayName(category.name),
          onSingleChange: (category) {
            setState(() {
              selectedCategory = category;
              AppUtils.log(
                "Manually selected category: ${category.name} (ID: ${category.id})",
              );
            });
          },
          isEnabled: categories.isNotEmpty,
          borderColor: Colors.grey[300],
          radius: 20,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          isFilled: true,
        ),
      ],
    );
  }

  Widget _selectedMediaWidget() {
    // If there are no media items, return an empty widget
    if (_mediaItems.isEmpty) return SizedBox.shrink();

    // Calculate dynamic height based on number of items
    int rows = (_mediaItems.length / 3).ceil();
    double itemHeight = 120; // Height per item
    double totalHeight = rows * itemHeight + (rows - 1) * 10; // Include spacing

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: "Selected Media (${_mediaItems.length})",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: totalHeight,
          child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: _mediaItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final mediaItem = _mediaItems[index]; // Get the media item

              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: mediaItem.isVideo ? AppColors.grey : null,
                      borderRadius: BorderRadius.circular(20),
                      image: mediaItem.isVideo
                          ? DecorationImage(
                              image: mediaItem.thumbnailUrl != null
                                  ? NetworkImage(mediaItem.thumbnailUrl!)
                                  : MemoryImage(
                                      mediaItem.thumnailFile!,
                                    ), // Use the network image
                              fit: BoxFit.cover,
                            )
                          : DecorationImage(
                              image: FileImage(
                                mediaItem.file,
                              ), // Actual image for images
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  if (mediaItem.isVideo)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _mediaItems.removeAt(
                            index,
                          ); // Remove the media item on tap
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class CountryPickerDropdown extends StatefulWidget {
  final Function(String)
  onCountrySelected; // Callback to handle country selection

  CountryPickerDropdown({required this.onCountrySelected});

  @override
  _CountryPickerDropdownState createState() => _CountryPickerDropdownState();
}

class _CountryPickerDropdownState extends State<CountryPickerDropdown> {
  TextEditingController _searchController = TextEditingController();
  List<Country> _allCountries = CountryService().getAll();
  List<Country> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = _allCountries; // Initialize with all countries
  }

  void _filterCountries(String query) {
    setState(() {
      _filteredCountries = _allCountries
          .where(
            (country) =>
                country.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 10),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Select Country",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Icon(
                  Icons.highlight_remove,
                  size: 30,
                  color: AppColors.btnColor,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Country",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (query) {
                _filterCountries(query);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                return ListTile(
                  title: Text(country.name),
                  onTap: () {
                    widget.onCountrySelected(country.name); // Call the callback
                    Navigator.pop(context); // Close the modal
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MediaItem {
  final File file;
  final bool isVideo;
  final String? thumbnailUrl;
  final Uint8List? thumnailFile;
  final double? x;
  final double? y;
  // Change this to String?

  MediaItem({
    required this.file,
    required this.isVideo,
    this.thumbnailUrl,
    this.thumnailFile,
    this.x,
    this.y,
  });
}

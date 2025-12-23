import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/feature/presentation/controller/createpost/createpost_ctrl.dart';
import 'package:sep/feature/presentation/controller/story/story_controller.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/data/models/dataModels/Createpost/getcategory_model.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/components/coreComponents/EditText.dart';

class StoryCreateScreen extends StatefulWidget {
  final PostData? existingStory;

  const StoryCreateScreen({Key? key, this.existingStory}) : super(key: key);

  @override
  State<StoryCreateScreen> createState() => _StoryCreateScreenState();
}

class _StoryCreateScreenState extends State<StoryCreateScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();
  bool _isUploading = false;
  Categories? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Load categories
    final createPostCtrl = Get.find<CreatePostCtrl>();
    createPostCtrl.getPostCategories();

    // If editing, populate form with existing data
    if (widget.existingStory != null) {
      // Set caption (remove #SEPStory tag)
      String caption = widget.existingStory!.content ?? '';
      caption = caption
          .replaceAll(RegExp(r'#SEPStory', caseSensitive: false), '')
          .trim();
      _captionController.text = caption;

      // Set category after categories are loaded
      Future.delayed(Duration(milliseconds: 500), () {
        final categories = createPostCtrl.getCategories;
        if (widget.existingStory!.categoryId != null && categories.isNotEmpty) {
          final category = categories.firstWhereOrNull(
            (cat) => cat.id == widget.existingStory!.categoryId,
          );
          if (category != null) {
            setState(() {
              _selectedCategory = category;
            });
          }
        }
      });

      // Load existing image
      if (widget.existingStory!.files?.isNotEmpty == true) {
        final imageUrl = widget.existingStory!.files!.first.file;
        if (imageUrl != null) {
          // Note: For editing, we'll show the network image
          // The actual file will be handled differently
          // You may need to download it or keep the URL
          AppUtils.log('Editing story with image: $imageUrl');
        }
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      AppUtils.toastError('Error picking image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primaryColor),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primaryColor),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createStory() async {
    // For editing, image is optional (can keep existing)
    // For new story, image is required
    if (_selectedImage == null && widget.existingStory == null) {
      AppUtils.toastError('Please select an image');
      return;
    }

    if (_selectedCategory == null) {
      AppUtils.toastError('Please select a category');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final createPostCtrl = Get.find<CreatePostCtrl>();
      final isEditing = widget.existingStory != null;

      // Upload new image if selected, otherwise use existing
      List<Map<String, dynamic>> uploadedFiles = [];
      if (_selectedImage != null) {
        final newFiles = await createPostCtrl.uploadFiles([_selectedImage!]);
        if (newFiles.isEmpty) {
          AppUtils.toastError('Failed to upload image');
          return;
        }
        uploadedFiles = newFiles.cast<Map<String, dynamic>>();
      } else if (isEditing) {
        // Keep existing files - convert to proper format
        if (widget.existingStory!.files != null &&
            widget.existingStory!.files!.isNotEmpty) {
          uploadedFiles = widget.existingStory!.files!.map((file) {
            return {'file': file.file ?? '', 'type': file.type ?? 'image'};
          }).toList();
        }
      }

      // Create caption with #SEPStory tag
      String caption = _captionController.text.trim();
      if (caption.isEmpty) {
        caption = '#SEPStory';
      } else if (!caption.toLowerCase().contains('#sepstory')) {
        caption = '$caption #SEPStory';
      }

      if (isEditing) {
        // Update existing story using ProfileCtrl.editPost
        final profileCtrl = Get.find<ProfileCtrl>();
        await profileCtrl.editPost(
          postId: widget.existingStory!.id!,
          content: caption,
          country: '',
          uploadedFileUrls: uploadedFiles,
        );
        AppUtils.toast('Story updated successfully!');
      } else {
        // Create new story
        await createPostCtrl.createStory(
          categoryId: _selectedCategory?.id,
          content: caption,
          files: uploadedFiles,
          country: '',
        );
        AppUtils.toast('Story created successfully!');
      }

      // Refresh stories list
      try {
        final storyController = Get.find<StoryController>();
        await storyController.refreshStories();
      } catch (e) {
        AppUtils.log('StoryController not found, will refresh on next load');
      }

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      AppUtils.toastError(
        'Failed to ${widget.existingStory != null ? 'update' : 'create'} story: $e',
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existingStory != null ? 'Edit Story' : 'Create Story',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (_selectedImage != null || widget.existingStory != null)
            TextButton(
              onPressed: _isUploading ? null : _createStory,
              child: _isUploading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Share',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
        ],
      ),
      body: _selectedImage == null && widget.existingStory == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 80, color: Colors.white54),
                  SizedBox(height: 20),
                  Text(
                    'Select an image to create story',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _showImageSourceDialog,
                    icon: Icon(Icons.add_photo_alternate),
                    label: Text('Select Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Image preview
                      Center(
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.contain)
                            : (widget.existingStory?.files?.isNotEmpty == true
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          widget
                                              .existingStory!
                                              .files!
                                              .first
                                              .file!
                                              .startsWith('http')
                                          ? widget
                                                .existingStory!
                                                .files!
                                                .first
                                                .file!
                                          : '$baseUrl${widget.existingStory!.files!.first.file}',
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                            Icons.error,
                                            color: Colors.white,
                                            size: 50,
                                          ),
                                    )
                                  : SizedBox()),
                      ),
                      // Change image button
                      Positioned(
                        top: 20,
                        right: 20,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.black54,
                          onPressed: _showImageSourceDialog,
                          child: Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                // Category and Caption input
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[900],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category selector
                      Obx(() {
                        final allCategories =
                            Get.find<CreatePostCtrl>().getCategories;

                        // Filter out Advertisement and order: Sports, Entertainment, Perception, Other
                        final filteredCategories = allCategories.where((cat) {
                          final name = cat.name?.toLowerCase() ?? '';
                          return name != 'advertisement';
                        }).toList();

                        // Sort in specific order
                        final orderedCategories = <Categories>[];
                        final order = [
                          'sports',
                          'entertainment',
                          'perception',
                          'other',
                        ];

                        for (final orderName in order) {
                          final cat = filteredCategories.firstWhereOrNull(
                            (c) => c.name?.toLowerCase() == orderName,
                          );
                          if (cat != null) orderedCategories.add(cat);
                        }

                        // Add any remaining categories not in the order list
                        for (final cat in filteredCategories) {
                          if (!orderedCategories.contains(cat)) {
                            orderedCategories.add(cat);
                          }
                        }

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: _selectedCategory == null
                                  ? Colors.red.withOpacity(0.5)
                                  : Colors.white24,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Categories>(
                              value: _selectedCategory,
                              hint: Text(
                                'Select Category *',
                                style: TextStyle(color: Colors.white54),
                              ),
                              dropdownColor: Colors.grey[800],
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              isExpanded: true,
                              style: TextStyle(color: Colors.white),
                              items: orderedCategories.map((category) {
                                // Capitalize first letter
                                String displayName = category.name ?? '';
                                if (displayName.isNotEmpty) {
                                  displayName =
                                      displayName[0].toUpperCase() +
                                      displayName.substring(1).toLowerCase();
                                }
                                return DropdownMenuItem<Categories>(
                                  value: category,
                                  child: Text(
                                    displayName,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                              onChanged: (Categories? value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                            ),
                          ),
                        );
                      }),
                      SizedBox(height: 12),
                      // Caption input
                      EditText(
                        controller: _captionController,
                        hint: 'Add a caption...',
                        textStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white54),
                        isFilled: true,
                        filledColor: Colors.grey[800],
                        borderColor: Colors.white24,
                        radius: 25,
                        maxLength: 100,
                        noOfLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

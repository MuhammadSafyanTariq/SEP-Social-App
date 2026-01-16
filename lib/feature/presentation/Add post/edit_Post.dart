import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/EditText.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/app_strings.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../components/appLoader.dart';
import '../../../components/coreComponents/ImageView.dart';
import '../../../components/styles/appImages.dart';
import '../../../utils/image_utils.dart';
import '../../data/repository/iAuthRepository.dart';
import '../controller/auth_Controller/profileCtrl.dart';
import 'CreatePost.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class EditPost extends StatefulWidget {
  PostData data;
  EditPost({super.key, required this.data});

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  XFile? _selectedMedia;
  List<MediaItem> _mediaItems = [];
  final ImagePicker _picker = ImagePicker();
  bool _isOriginalImageRemoved = false;
  Set<String> _removedOriginalImageIds = {};
  String? _selectedCountry;
  late TextEditingController _editTitleController = TextEditingController();
  late TextEditingController _countryController = TextEditingController();
  final IAuthRepository authRepository = IAuthRepository();

  @override
  void initState() {
    super.initState();
    AppUtils.log("userPostData::${widget.data}");
    if (widget.data.files != null && widget.data.files!.isNotEmpty) {
      AppUtils.log("image:::::${widget.data.files!.first.file.fileUrl}");
    } else {
      AppUtils.log("No files available in post data");
    }

    _editTitleController = TextEditingController(
      text: widget.data.content ?? "",
    );
    _countryController = TextEditingController(text: widget.data.country ?? "");
  }

  @override
  void dispose() {
    _editTitleController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _updatePost(BuildContext context) async {
    AppUtils.log("Starting post submission...");

    // if ((widget.data.files == null || widget.data.files!.isEmpty || widget.data.files!.first.file!.fileUrl == null) &&
    //     _mediaItems.isEmpty) {
    //   AppUtils.toastError("Please select at least one image or video");
    //   return;
    // }

    AppLoader.showLoader(context);
    List<Map<String, dynamic>> uploadedFiles = [];

    try {
      Future<(String, ui.Size)?> uploadFile(data) async {
        bool isUint8 = data is Uint8List;
        final response = await authRepository.uploadPhoto(
          imageFile: isUint8 ? null : data,
          memoryFile: isUint8 ? data : null,
        );
        if (response.isSuccess) {
          List<String> data = response.data ?? [];
          if (data.isNotEmpty) {
            String fileUrl = data.first;
            final size = await getNetworkImageSize(fileUrl.fileUrl ?? '');
            return (fileUrl, size);
          }
        }
        return null;
      }

      for (MediaItem mediaItem in _mediaItems) {
        if (!mediaItem.file.existsSync()) {
          AppUtils.log("File does not exist: ${mediaItem.file.path}");
          continue;
        }

        (String, ui.Size)? thumbnailUrl;
        if (mediaItem.isVideo) {
          thumbnailUrl = await uploadFile(mediaItem.thumnailFile);
        }
        final fileUrlData = await uploadFile(mediaItem.file);
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

      await ProfileCtrl.find.editPost(
        postId: widget.data.id ?? "",
        content: _editTitleController.getText,
        country: _countryController.getText,
        uploadedFileUrls: uploadedFiles,
      );
      AppUtils.log("Edit Post Request: ${uploadedFiles.toString()}");

      AppUtils.toast("Update successfully");
      AppLoader.hideLoader(context);
      context.pop();
    } catch (e) {
      AppUtils.toastError("Failed to create post: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.primaryColor, size: 20.sdp),
        elevation: 0,
        backgroundColor: AppColors.white,
        title: TextView(text: AppStrings.editPost, style: 17.txtMediumBlack),
      ),
      body: Padding(
        padding: 15.horizontal,
        child: Column(
          children: [
            20.height,
            Row(
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (widget.data.files != null &&
                        widget.data.files!.isNotEmpty)
                      ...widget.data.files!
                          .where(
                            (fileElement) => !_removedOriginalImageIds.contains(
                              fileElement.id,
                            ),
                          )
                          .map((fileElement) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    fileElement.file.fileUrl ?? "",
                                    width: 80.sdp,
                                    height: 80.sdp,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _removedOriginalImageIds.add(
                                          fileElement.id ?? "",
                                        );
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          })
                          .toList(),

                    // _mediaItems (new uploads)
                    for (int i = 0; i < _mediaItems.length; i++)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _mediaItems[i].file,
                              width: 80.sdp,
                              height: 80.sdp,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _mediaItems.removeAt(i);
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    // Add new image/video button
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Padding(
                                      padding: 12.all,
                                      child: ImageView(
                                        url: AppImages.gallery,
                                        size: 30,
                                      ),
                                    ),
                                    title: TextView(
                                      text: 'Pick Image',
                                      style: 16.txtRegularprimary,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      chooseImage();
                                    },
                                  ),
                                  ListTile(
                                    leading: Padding(
                                      padding: 12.all,
                                      child: ImageView(
                                        url: AppImages.videoicon,
                                        size: 30,
                                      ),
                                    ),
                                    title: TextView(
                                      text: 'Pick Video',
                                      style: 16.txtRegularprimary,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickVideo();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 80.sdp,
                        height: 80.sdp,
                        decoration: BoxDecoration(
                          color: AppColors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryColor),
                        ),
                        child: Icon(
                          Icons.add_a_photo,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            EditText(
              padding: 20.top + 20.bottom + 12.left,
              hint: "Edit Title",
              hintStyle: 16.txtRegularGrey,
              inputType: TextInputType.emailAddress,
              margin: 20.bottom + 40.top,
              controller: _editTitleController,
              validator: (value) {
                return null;
              },
            ),
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
                          _countryController.text = country;
                        });
                      },
                    );
                  },
                );
              },
              child: AbsorbPointer(
                child: EditText(
                  controller: _countryController,
                  hint: "Country",
                  margin: 20.bottom,
                  padding: 20.top + 20.bottom + 12.left,
                  hintStyle: 16.txtRegularGrey,
                  inputType: TextInputType.text,
                  validator: (value) => null,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ImageView(url: AppImages.locations, size: 50.sdp),
                  ),
                ),
              ),
            ),

            AppButton(
              radius: 10,
              onTap: () => _updatePost(context),
              label: "Update Post",

              labelStyle: 16.txtBoldWhite,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> chooseImage() async {
    if (_mediaItems.length >= 6) {
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
        setState(() {
          _mediaItems.add(MediaItem(file: File(file.path), isVideo: false));
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

      final thumbnail = await getThumbnail(
        media.path,
        // , size.height, size.width
      );
      setState(() {
        _mediaItems.add(
          MediaItem(
            file: File(media.path),
            isVideo: true,
            thumnailFile: thumbnail,
          ),
        );
      });
    }
  }
}

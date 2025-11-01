import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/editText.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/repository/iAuthRepository.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:sep/services/storage/preferences.dart';

class ProductUploadForm extends StatefulWidget {
  final bool isDropship;

  const ProductUploadForm({Key? key, this.isDropship = false})
    : super(key: key);

  @override
  State<ProductUploadForm> createState() => _ProductUploadFormState();
}

class _ProductUploadFormState extends State<ProductUploadForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _linkController = TextEditingController();
  final _picker = ImagePicker();
  final IAuthRepository _authRepository = IAuthRepository();
  final IApiMethod _apiMethod = IApiMethod();

  final RxList<String> selectedImages = RxList([]);
  final RxBool isAvailable = RxBool(true);
  final RxBool isUploading = RxBool(false);

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (selectedImages.length >= 5) {
      AppUtils.toastError("You can upload up to 5 images/videos only");
      return;
    }

    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      int remainingSlots = 5 - selectedImages.length;
      for (var file in pickedFiles.take(remainingSlots)) {
        selectedImages.add(file.path);
      }
    }
  }

  Future<void> _pickVideo() async {
    if (selectedImages.length >= 5) {
      AppUtils.toastError("You can upload up to 5 images/videos only");
      return;
    }

    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      selectedImages.add(video.path);
    }
  }

  void _removeMedia(int index) {
    selectedImages.removeAt(index);
  }

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedImages.isEmpty) {
      AppUtils.toastError("Please add at least one image or video");
      return;
    }

    isUploading.value = true;

    try {
      // First, get the user's shop ID
      final token = Preferences.authToken;
      final shopResponse = await _apiMethod.get(
        url: Urls.getMyShop,
        authToken: token,
        headers: {},
      );

      if (!shopResponse.isSuccess || shopResponse.data?['data'] == null) {
        throw Exception(
          "You need to create a shop first before uploading products",
        );
      }

      final shopId = shopResponse.data!['data']['_id'] as String;

      // Upload media files
      List<String> uploadedUrls = [];
      for (String filePath in selectedImages) {
        final response = await _authRepository.uploadPhoto(
          imageFile: File(filePath),
        );
        if (response.isSuccess &&
            response.data != null &&
            response.data!.isNotEmpty) {
          uploadedUrls.add(response.data!.first);
        }
      }

      if (uploadedUrls.isEmpty) {
        throw Exception("Failed to upload media files");
      }

      // Concatenate category with suffix based on product type
      String categoryValue = _categoryController.text.trim();
      if (widget.isDropship) {
        categoryValue = "$categoryValue+drop+${_linkController.text.trim()}";
      } else {
        categoryValue = "$categoryValue+simple";
      }

      final productData = {
        "name": _nameController.text.trim(),
        "description": _descriptionController.text.trim(),
        "price": double.parse(_priceController.text.trim()),
        "mediaUrls": uploadedUrls,
        "category": categoryValue,
        "isAvailable": isAvailable.value,
        "shopId": shopId,
      };

      AppUtils.log("Creating product with data: $productData");

      final response = await _apiMethod.post(
        url: Urls.userProduct,
        body: productData,
        headers: {},
        authToken: token,
      );

      if (response.isSuccess) {
        AppUtils.toast("Product uploaded successfully");
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        AppUtils.toastError(response.getError ?? "Failed to upload product");
      }
    } catch (e) {
      AppUtils.toastError("Error: ${e.toString()}");
    } finally {
      isUploading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: 20.all,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Upload Section
            TextView(
              text: "Product Media *",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            8.height,
            Obx(
              () => selectedImages.isEmpty
                  ? _buildAddMediaButton()
                  : _buildMediaGrid(),
            ),
            24.height,

            // Product Name
            TextView(
              text: "Product Name *",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            8.height,
            EditText(
              controller: _nameController,
              hint: "Enter product name",
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return "Product name is required";
                }
                return null;
              },
            ),
            16.height,

            // Product Description
            TextView(
              text: "Description *",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            8.height,
            EditText(
              controller: _descriptionController,
              hint: "Enter product description",
              noOfLines: 4,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return "Description is required";
                }
                return null;
              },
            ),
            16.height,

            // Price
            TextView(
              text: "Price *",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            8.height,
            EditText(
              controller: _priceController,
              hint: "Enter price",
              inputType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return "Price is required";
                }
                final price = double.tryParse(value!);
                if (price == null || price <= 0) {
                  return "Please enter a valid price";
                }
                return null;
              },
            ),
            16.height,

            // Category
            TextView(
              text: "Category *",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            8.height,
            EditText(
              controller: _categoryController,
              hint: "Enter category (e.g., Electronics, Fashion)",
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return "Category is required";
                }
                return null;
              },
            ),
            16.height,

            // Product Link (only for dropship)
            if (widget.isDropship) ...[
              TextView(
                text: "Product Link *",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              8.height,
              EditText(
                controller: _linkController,
                hint: "Enter product link (e.g., https://example.com/product)",
                inputType: TextInputType.url,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return "Product link is required for dropshipping";
                  }
                  return null;
                },
              ),
              16.height,
            ],

            // Availability Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextView(
                  text: "Product Available",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Obx(
                  () => Switch(
                    value: isAvailable.value,
                    onChanged: (value) => isAvailable.value = value,
                    activeColor: AppColors.btnColor,
                  ),
                ),
              ],
            ),
            32.height,

            // Upload Button
            Obx(
              () => AppButton(
                label: isUploading.value ? "Uploading..." : "Upload Product",
                onTap: isUploading.value ? null : _uploadProduct,
                buttonColor: AppColors.btnColor,
                labelStyle: 16.txtBoldWhite,
                isLoading: isUploading.value,
              ),
            ),
            20.height,
          ],
        ),
      ),
    );
  }

  Widget _buildAddMediaButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 150.sdp,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  size: 48,
                  color: AppColors.grey,
                ),
                12.height,
                TextView(text: "Add Images/Videos", style: 14.txtRegularGrey),
                4.height,
                TextView(text: "Up to 5 files", style: 12.txtRegularGrey),
              ],
            ),
          ),
        ),
        12.height,
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: "Add Images",
                onTap: _pickImages,
                buttonColor: AppColors.btnColor.withOpacity(0.1),
                labelStyle: 14.txtMediumbtncolor,
                prefix: Icon(Icons.image, color: AppColors.btnColor, size: 20),
              ),
            ),
            12.width,
            Expanded(
              child: AppButton(
                label: "Add Video",
                onTap: _pickVideo,
                buttonColor: AppColors.btnColor.withOpacity(0.1),
                labelStyle: 14.txtMediumbtncolor,
                prefix: Icon(
                  Icons.videocam,
                  color: AppColors.btnColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaGrid() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount:
              selectedImages.length + (selectedImages.length < 5 ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == selectedImages.length) {
              return GestureDetector(
                onTap: _pickImages,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.add, color: AppColors.grey),
                ),
              );
            }

            final imagePath = selectedImages[index];
            final isVideo =
                imagePath.toLowerCase().endsWith('.mp4') ||
                imagePath.toLowerCase().endsWith('.mov');

            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isVideo
                        ? Container(
                            color: AppColors.grey.withOpacity(0.2),
                            child: Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                size: 40,
                                color: AppColors.white,
                              ),
                            ),
                          )
                        : Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeMedia(index),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (selectedImages.length < 5) ...[
          12.height,
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: "Add Images",
                  onTap: _pickImages,
                  buttonColor: AppColors.btnColor.withOpacity(0.1),
                  labelStyle: 14.txtMediumbtncolor,
                  prefix: Icon(
                    Icons.image,
                    color: AppColors.btnColor,
                    size: 20,
                  ),
                ),
              ),
              12.width,
              Expanded(
                child: AppButton(
                  label: "Add Video",
                  onTap: _pickVideo,
                  buttonColor: AppColors.btnColor.withOpacity(0.1),
                  labelStyle: 14.txtMediumbtncolor,
                  prefix: Icon(
                    Icons.videocam,
                    color: AppColors.btnColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/editText.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/feature/data/models/dataModels/user_store/user_product_model.dart';
import 'package:sep/feature/presentation/controller/user_store_controller.dart';
import 'package:sep/feature/data/repository/iAuthRepository.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:sep/services/networking/urls.dart';

class AddEditProductScreen extends StatefulWidget {
  final UserProductModel? product; // null for add, populated for edit

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final UserStoreController storeController = UserStoreController.find;
  final IAuthRepository authRepository = IAuthRepository();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  // State variables
  final RxList<String> selectedImages = <String>[].obs;
  final RxBool isAvailable = true.obs;
  final RxBool isUploadingImages = false.obs;
  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name ?? '';
    _descriptionController.text = product.description ?? '';
    _priceController.text = product.price?.toString() ?? '';
    _categoryController.text = product.category ?? '';
    selectedImages.assignAll(product.mediaUrls ?? []);
    isAvailable.value = product.isAvailable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            AppBar2(
              title: isEditing ? "Edit Product" : "Add Product",
              titleStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              prefixImage: "back",
              onPrefixTap: () => context.pop(),
              backgroundColor: AppColors.white,
              hasTopSafe: true,
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: 20.all,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Images Section
                      _buildImageSection(),
                      24.height,

                      // Product Name
                      TextView(
                        text: "Product Name *",
                        style: 16.txtMediumBlack,
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
                      TextView(text: "Description *", style: 16.txtMediumBlack),
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

                      // Price and Category Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextView(
                                  text: "Price (\$) *",
                                  style: 16.txtMediumBlack,
                                ),
                                8.height,
                                EditText(
                                  controller: _priceController,
                                  hint: "0.00",
                                  inputType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  validator: (value) {
                                    if (value?.trim().isEmpty ?? true) {
                                      return "Price is required";
                                    }
                                    final price = double.tryParse(value!);
                                    if (price == null || price <= 0) {
                                      return "Enter valid price";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          16.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextView(
                                  text: "Category",
                                  style: 16.txtMediumBlack,
                                ),
                                8.height,
                                EditText(
                                  controller: _categoryController,
                                  hint: "e.g., Electronics",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      24.height,

                      // Available Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextView(
                            text: "Product Available",
                            style: 16.txtMediumBlack,
                          ),
                          Obx(
                            () => Switch(
                              value: isAvailable.value,
                              activeColor: AppColors.greenlight,
                              onChanged: (value) => isAvailable.value = value,
                            ),
                          ),
                        ],
                      ),
                      40.height,

                      // Save Button
                      Obx(
                        () => AppButton(
                          label: isUploadingImages.value
                              ? "Uploading Images..."
                              : storeController.isLoadingProducts.value
                              ? (isEditing ? "Updating..." : "Creating...")
                              : (isEditing ? "Update Product" : "Add Product"),
                          labelStyle: 16.txtBoldWhite,
                          buttonColor: AppColors.greenlight,
                          isLoading:
                              storeController.isLoadingProducts.value ||
                              isUploadingImages.value,
                          onTap:
                              (storeController.isLoadingProducts.value ||
                                  isUploadingImages.value)
                              ? null
                              : _saveProduct,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(text: "Product Images", style: 16.txtMediumBlack),
        8.height,
        TextView(
          text: "Add up to 5 images to showcase your product",
          style: 12.txtMediumgrey,
        ),
        16.height,

        Obx(
          () => SizedBox(
            height: 100.sdp,
            child: Row(
              children: [
                // Add Image Button
                if (selectedImages.length < 5)
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      width: 100.sdp,
                      height: 100.sdp,
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.sdp),
                        border: Border.all(
                          color: AppColors.grey.withOpacity(0.3),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 30.sdp,
                            color: AppColors.grey,
                          ),
                          4.height,
                          TextView(text: "Add Image", style: 12.txtMediumgrey),
                        ],
                      ),
                    ),
                  ),

                // Selected Images
                if (selectedImages.isNotEmpty) 16.width,
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImages.length,
                    separatorBuilder: (_, __) => 12.width,
                    itemBuilder: (context, index) {
                      final imagePath = selectedImages[index];
                      return Container(
                        width: 100.sdp,
                        height: 100.sdp,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.sdp),
                          border: Border.all(
                            color: AppColors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.sdp),
                              child: _buildImageWidget(imagePath),
                            ),
                            // Remove button
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => selectedImages.removeAt(index),
                                child: Container(
                                  width: 24.sdp,
                                  height: 24.sdp,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 16.sdp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(String imagePath) {
    // Check if it's a server image (full URL or server relative path /public/upload/...)
    final isServerImage =
        imagePath.startsWith('http') || imagePath.startsWith('/public/');

    if (isServerImage) {
      final fullImageUrl = Urls.getFullImageUrl(imagePath);
      AppUtils.log("Edit Product Image - Raw: $imagePath");
      AppUtils.log("Edit Product Image - Full: $fullImageUrl");

      return ImageView(
        url: fullImageUrl,
        width: 100.sdp,
        height: 98.sdp,
        fit: BoxFit.cover,
        imageType: ImageType.network,
      );
    } else {
      // Local file from image picker (starts with /data/ or /storage/ or other local paths)
      AppUtils.log("Edit Product Image - Local File: $imagePath");
      return Image.file(
        File(imagePath),
        width: 100.sdp,
        height: 98.sdp,
        fit: BoxFit.cover,
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: 20.all,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextView(text: "Select Image Source", style: 18.txtBoldBlack),
            20.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    context.pop();
                    _pickImage(ImageSource.camera);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60.sdp,
                        height: 60.sdp,
                        decoration: BoxDecoration(
                          color: AppColors.greenlight.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 30.sdp,
                          color: AppColors.greenlight,
                        ),
                      ),
                      8.height,
                      TextView(text: "Camera", style: 14.txtMediumBlack),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.pop();
                    _pickImage(ImageSource.gallery);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60.sdp,
                        height: 60.sdp,
                        decoration: BoxDecoration(
                          color: AppColors.greenlight.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.photo_library,
                          size: 30.sdp,
                          color: AppColors.greenlight,
                        ),
                      ),
                      8.height,
                      TextView(text: "Gallery", style: 14.txtMediumBlack),
                    ],
                  ),
                ),
              ],
            ),
            20.height,
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImages.add(image.path);
      }
    } catch (e) {
      AppUtils.toastError("Failed to pick image: $e");
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedImages.isEmpty) {
      AppUtils.toastError("Please add at least one product image");
      return;
    }

    try {
      isUploadingImages.value = true;

      // Upload images that are local files (not already uploaded URLs)
      List<String> uploadedImageUrls = [];

      for (String imagePath in selectedImages) {
        // Check if it's already a server image (full URL or server path)
        final isServerImage =
            imagePath.startsWith('http') || imagePath.startsWith('/public/');

        if (isServerImage) {
          // Already uploaded to server, keep as is
          uploadedImageUrls.add(imagePath);
          AppUtils.log("Keeping existing server image: $imagePath");
        } else {
          // Local file from device, need to upload
          AppUtils.log("Uploading new local image: $imagePath");
          final response = await authRepository.uploadPhoto(
            imageFile: File(imagePath),
          );

          if (response.isSuccess &&
              response.data != null &&
              response.data!.isNotEmpty) {
            uploadedImageUrls.add(response.data!.first);
            AppUtils.log(
              "Image uploaded successfully: ${response.data!.first}",
            );
          } else {
            AppUtils.toastError("Failed to upload image: ${response.error}");
            return;
          }
        }
      }

      final product = UserProductModel(
        id: isEditing ? widget.product!.id : null,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        mediaUrls: uploadedImageUrls,
        category: _categoryController.text.trim().isNotEmpty
            ? _categoryController.text.trim()
            : null,
        isAvailable: isAvailable.value,
      );

      if (isEditing) {
        await storeController.updateProduct(product);
      } else {
        await storeController.createProduct(product);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      AppUtils.toastError("Failed to save product: $e");
    } finally {
      isUploadingImages.value = false;
    }
  }
}

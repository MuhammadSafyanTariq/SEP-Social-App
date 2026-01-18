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

class ProductEditForm extends StatefulWidget {
  final String productId;
  final Map<String, dynamic>? productData;

  const ProductEditForm({Key? key, required this.productId, this.productData})
    : super(key: key);

  @override
  State<ProductEditForm> createState() => _ProductEditFormState();
}

class _ProductEditFormState extends State<ProductEditForm> {
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
  final RxList<String> existingMediaUrls = RxList(
    [],
  ); // Existing URLs from server
  final RxBool isAvailable = RxBool(true);
  final RxBool isUploading = RxBool(false);
  final RxBool isLoading = RxBool(true);
  final RxBool isDropship = RxBool(false);

  @override
  void initState() {
    super.initState();
    AppUtils.log(
      "ProductEditForm initState - productData is null: ${widget.productData == null}",
    );
    if (widget.productData != null) {
      AppUtils.log("Using provided product data");
    }
    // Use provided data if available, otherwise fetch from API
    if (widget.productData != null) {
      _populateFromData(widget.productData!);
    } else {
      AppUtils.log("Fetching product data from API");
      _loadProductData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _loadProductData() async {
    try {
      final token = Preferences.authToken;
      AppUtils.log("Loading product data for ID: ${widget.productId}");
      AppUtils.log("API URL: ${Urls.userProduct}/${widget.productId}");

      final response = await _apiMethod.get(
        url: '${Urls.userProduct}/${widget.productId}',
        authToken: token,
        headers: {},
      );

      AppUtils.log("Product load response - isSuccess: ${response.isSuccess}");
      AppUtils.log("Product load response - data: ${response.data}");
      AppUtils.log("Product load response - error: ${response.error}");

      if (response.isSuccess && response.data?['data'] != null) {
        final product = response.data!['data'];

        _nameController.text = product['name'] ?? '';
        _descriptionController.text = product['description'] ?? '';
        _priceController.text = product['price']?.toString() ?? '';

        // Parse category to extract base category and type
        String category = product['category'] ?? '';
        if (category.contains('+drop+')) {
          isDropship.value = true;
          final parts = category.split('+drop+');
          _categoryController.text = parts[0];
          if (parts.length > 1) {
            _linkController.text = parts[1];
          }
        } else if (category.contains('+simple')) {
          isDropship.value = false;
          _categoryController.text = category.replaceAll('+simple', '');
        } else {
          _categoryController.text = category;
        }

        isAvailable.value = product['isAvailable'] ?? true;

        // Load existing media URLs
        if (product['mediaUrls'] != null && product['mediaUrls'] is List) {
          existingMediaUrls.value = List<String>.from(product['mediaUrls']);
        }

        AppUtils.log("Product data loaded successfully");
      } else {
        AppUtils.log(
          "Failed to load - response.isSuccess: ${response.isSuccess}, has data: ${response.data?['data'] != null}",
        );
        AppUtils.toastError("Failed to load product data");
        Navigator.pop(context);
      }
    } catch (e) {
      AppUtils.log("Exception loading product: $e");
      AppUtils.toastError("Error loading product: ${e.toString()}");
      Navigator.pop(context);
    } finally {
      isLoading.value = false;
    }
  }

  void _populateFromData(Map<String, dynamic> product) {
    try {
      _nameController.text = product['name'] ?? '';
      _descriptionController.text = product['description'] ?? '';
      _priceController.text = product['price']?.toString() ?? '';

      // Parse category to extract base category and type
      String category = product['category'] ?? '';
      if (category.contains('+drop+')) {
        isDropship.value = true;
        final parts = category.split('+drop+');
        _categoryController.text = parts[0];
        if (parts.length > 1) {
          _linkController.text = parts[1];
        }
      } else if (category.contains('+simple')) {
        isDropship.value = false;
        _categoryController.text = category.replaceAll('+simple', '');
      } else {
        _categoryController.text = category;
      }

      isAvailable.value = product['isAvailable'] ?? true;

      // Load existing media URLs
      if (product['mediaUrls'] != null && product['mediaUrls'] is List) {
        existingMediaUrls.value = List<String>.from(product['mediaUrls']);
      }

      AppUtils.log("Product data populated from provided data");
    } catch (e) {
      AppUtils.log("Error populating product data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _pickImages() async {
    final totalMedia = selectedImages.length + existingMediaUrls.length;
    if (totalMedia >= 5) {
      AppUtils.toastError("You can have up to 5 images/videos only");
      return;
    }

    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      int remainingSlots = 5 - totalMedia;
      for (var file in pickedFiles.take(remainingSlots)) {
        selectedImages.add(file.path);
      }
    }
  }

  Future<void> _pickVideo() async {
    final totalMedia = selectedImages.length + existingMediaUrls.length;
    if (totalMedia >= 5) {
      AppUtils.toastError("You can have up to 5 images/videos only");
      return;
    }

    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      selectedImages.add(video.path);
    }
  }

  void _removeNewMedia(int index) {
    selectedImages.removeAt(index);
  }

  void _removeExistingMedia(int index) {
    existingMediaUrls.removeAt(index);
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final totalMedia = selectedImages.length + existingMediaUrls.length;
    if (totalMedia == 0) {
      AppUtils.toastError("Please add at least one image or video");
      return;
    }

    isUploading.value = true;

    try {
      final token = Preferences.authToken;

      // Upload new media files
      List<String> uploadedUrls = List<String>.from(existingMediaUrls);
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
      if (isDropship.value) {
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
      };

      AppUtils.log("Updating product with data: $productData");

      final response = await _apiMethod.put(
        url: '${Urls.userProduct}/${widget.productId}',
        body: productData,
        headers: {},
        authToken: token,
      );

      if (response.isSuccess) {
        AppUtils.toast("Product updated successfully");
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        AppUtils.toastError(response.getError ?? "Failed to update product");
      }
    } catch (e) {
      AppUtils.toastError("Error: ${e.toString()}");
    } finally {
      isUploading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

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
              _buildMediaGrid(),
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
              if (isDropship.value) ...[
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
                  hint:
                      "Enter product link (e.g., https://example.com/product)",
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
                  Switch(
                    value: isAvailable.value,
                    onChanged: (value) => isAvailable.value = value,
                    activeColor: AppColors.btnColor,
                  ),
                ],
              ),
              32.height,

              // Update Button
              AppButton(
                label: isUploading.value ? "Updating..." : "Update Product",
                onTap: isUploading.value ? null : _updateProduct,
                buttonColor: AppColors.btnColor,
                labelStyle: 16.txtBoldWhite,
                isLoading: isUploading.value,
              ),
              20.height,
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMediaGrid() {
    final totalMedia = selectedImages.length + existingMediaUrls.length;
    final canAddMore = totalMedia < 5;

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
          itemCount: totalMedia + (canAddMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == totalMedia) {
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

            // Show existing media first, then new media
            if (index < existingMediaUrls.length) {
              // Existing media from server
              final mediaUrl = existingMediaUrls[index];
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        mediaUrl.startsWith('http')
                            ? mediaUrl
                            : '${Urls.appApiBaseUrl}$mediaUrl',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.grey.withOpacity(0.2),
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeExistingMedia(index),
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
            } else {
              // New media from local files
              final localIndex = index - existingMediaUrls.length;
              final imagePath = selectedImages[localIndex];
              final isVideo =
                  imagePath.toLowerCase().endsWith('.mp4') ||
                  imagePath.toLowerCase().endsWith('.mov');

              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.grey.withOpacity(0.3),
                      ),
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
                      onTap: () => _removeNewMedia(localIndex),
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
            }
          },
        ),
        if (canAddMore) ...[
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

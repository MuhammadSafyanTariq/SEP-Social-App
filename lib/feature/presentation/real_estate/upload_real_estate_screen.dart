import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/editText.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/data/repository/iAuthRepository.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:sep/services/storage/preferences.dart';

class UploadRealEstateScreen extends StatefulWidget {
  const UploadRealEstateScreen({Key? key}) : super(key: key);

  @override
  State<UploadRealEstateScreen> createState() => _UploadRealEstateScreenState();
}

class _UploadRealEstateScreenState extends State<UploadRealEstateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propertyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _propertyTypeController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _picker = ImagePicker();
  final IAuthRepository _authRepository = IAuthRepository();
  final IApiMethod _apiMethod = IApiMethod();

  final RxList<String> selectedImages = RxList([]);
  final RxBool isUploading = RxBool(false);

  @override
  void dispose() {
    _propertyNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _propertyTypeController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (selectedImages.length >= 10) {
      AppUtils.toastError("You can upload up to 10 images only");
      return;
    }

    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      int remainingSlots = 10 - selectedImages.length;
      for (var file in pickedFiles.take(remainingSlots)) {
        selectedImages.add(file.path);
      }
    }
  }

  Future<void> _pickVideo() async {
    if (selectedImages.length >= 10) {
      AppUtils.toastError("You can upload up to 10 images/videos only");
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

  Future<void> _uploadRealEstate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedImages.isEmpty) {
      AppUtils.toastError("Please add at least one image or video");
      return;
    }

    isUploading.value = true;

    try {
      // Get shop ID (reusing product module)
      final token = Preferences.authToken;
      final shopResponse = await _apiMethod.get(
        url: Urls.getMyShop,
        authToken: token,
        headers: {},
      );

      if (!shopResponse.isSuccess || shopResponse.data?['data'] == null) {
        throw Exception(
          "You need to create a shop first before uploading real estate",
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

      // Bypass logic: Use category field to store real estate info
      // Format: propertyType+realestate+country+city+contactInfo
      final categoryValue =
          "${_propertyTypeController.text.trim()}+realestate+${_countryController.text.trim()}+${_cityController.text.trim()}+${_contactInfoController.text.trim()}";

      final realEstateData = {
        "name": _propertyNameController.text.trim(),
        "description": _descriptionController.text.trim(),
        "price": double.parse(_priceController.text.trim()),
        "mediaUrls": uploadedUrls,
        "category":
            categoryValue, // Bypass: storing real estate data in category
        "isAvailable": true,
        "shopId": shopId,
      };

      AppUtils.log("Creating real estate listing with data: $realEstateData");

      // Using existing product API endpoint
      final response = await _apiMethod.post(
        url: Urls.userProduct,
        body: realEstateData,
        headers: {},
        authToken: token,
      );

      if (response.isSuccess) {
        AppUtils.toast("Real estate listing uploaded successfully");
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        AppUtils.toastError(response.getError ?? "Failed to upload listing");
      }
    } catch (e) {
      AppUtils.toastError("Error: ${e.toString()}");
    } finally {
      isUploading.value = false;
    }
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
              title: "Upload Real Estate",
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              prefixImage: "back",
              onPrefixTap: () => Navigator.pop(context),
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
                      // Media Upload Section
                      TextView(
                        text: "Property Photos *",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      4.height,
                      TextView(
                        text: "Upload up to 10 photos or videos",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      8.height,
                      Obx(
                        () => selectedImages.isEmpty
                            ? _buildAddMediaButton()
                            : _buildMediaGrid(),
                      ),
                      24.height,

                      // Property Name
                      TextView(
                        text: "Property Name *",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      8.height,
                      EditText(
                        controller: _propertyNameController,
                        hint: "Enter property name",
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return "Property name is required";
                          }
                          return null;
                        },
                      ),
                      16.height,

                      // Property Type
                      TextView(
                        text: "Property Type *",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      8.height,
                      EditText(
                        controller: _propertyTypeController,
                        hint: "e.g., House, Apartment, Land, Commercial",
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return "Property type is required";
                          }
                          return null;
                        },
                      ),
                      16.height,

                      // Country
                      TextView(
                        text: "Country *",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      8.height,
                      EditText(
                        controller: _countryController,
                        hint: "Enter country",
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return "Country is required";
                          }
                          return null;
                        },
                      ),
                      16.height,

                      // City
                      TextView(
                        text: "City *",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      8.height,
                      EditText(
                        controller: _cityController,
                        hint: "Enter city",
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return "City is required";
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
                        inputType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
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

                      // Description
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
                        hint: "Enter detailed property description",
                        noOfLines: 6,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return "Description is required";
                          }
                          return null;
                        },
                      ),
                      16.height,

                      // Contact Information
                      TextView(
                        text: "Contact Information *",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      4.height,
                      TextView(
                        text: "Phone number or email address",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      8.height,
                      EditText(
                        controller: _contactInfoController,
                        hint: "Enter phone or email",
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return "Contact information is required";
                          }
                          return null;
                        },
                      ),
                      32.height,

                      // Upload Button
                      Obx(
                        () => AppButton(
                          label: isUploading.value
                              ? "Uploading..."
                              : "Upload Listing",
                          onTap: isUploading.value ? null : _uploadRealEstate,
                          isLoading: isUploading.value,
                        ),
                      ),
                      20.height,
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

  Widget _buildAddMediaButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 50,
                    color: Colors.grey[600],
                  ),
                  12.height,
                  TextView(
                    text: "Add Photos",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  4.height,
                  TextView(
                    text: "Tap to select images",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ),
        12.height,
        ElevatedButton.icon(
          onPressed: _pickVideo,
          icon: Icon(Icons.videocam, size: 20),
          label: Text("Add Video"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.btnColor.withOpacity(0.1),
            foregroundColor: AppColors.btnColor,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            elevation: 0,
          ),
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
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: selectedImages.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(selectedImages[index]),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeMedia(index),
                    child: Container(
                      padding: 4.all,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (selectedImages.length < 10) ...[
          12.height,
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: Icon(Icons.add_photo_alternate, size: 18),
                  label: Text("Add More Photos"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.btnColor,
                    side: BorderSide(color: AppColors.btnColor),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              12.width,
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickVideo,
                  icon: Icon(Icons.videocam, size: 18),
                  label: Text("Add Video"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.btnColor,
                    side: BorderSide(color: AppColors.btnColor),
                    padding: EdgeInsets.symmetric(vertical: 12),
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

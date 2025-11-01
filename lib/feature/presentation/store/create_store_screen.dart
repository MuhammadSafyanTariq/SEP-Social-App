import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/editText.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/data/models/dataModels/store_model.dart';
import 'package:sep/feature/data/repository/iAuthRepository.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/services/storage/preferences.dart';

class CreateStoreScreen extends StatefulWidget {
  final StoreModel? existingStore;

  const CreateStoreScreen({Key? key, this.existingStore}) : super(key: key);

  @override
  State<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _picker = ImagePicker();
  final IAuthRepository _authRepository = IAuthRepository();
  final IApiMethod _apiMethod = IApiMethod();

  final RxString logoUrl = RxString('');
  final RxBool isUploading = RxBool(false);
  File? selectedLogoFile;

  bool get isEditMode => widget.existingStore != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _populateExistingData();
    }
  }

  void _populateExistingData() {
    final store = widget.existingStore!;
    _nameController.text = store.name;
    _descriptionController.text = store.description;
    _addressController.text = store.address;
    _emailController.text = store.contactEmail;
    _phoneController.text = store.contactPhone;
    if (store.logoUrl != null) {
      logoUrl.value = store.logoUrl!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          selectedLogoFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      AppUtils.log("Error picking logo: $e");
      AppUtils.toastError("Failed to pick image");
    }
  }

  Future<String?> _uploadLogo() async {
    if (selectedLogoFile == null && logoUrl.value.isEmpty) {
      return null;
    }

    if (selectedLogoFile != null) {
      try {
        final response = await _authRepository.uploadPhoto(
          imageFile: selectedLogoFile!,
        );

        if (response.isSuccess &&
            response.data != null &&
            response.data!.isNotEmpty) {
          return response.data!.first;
        } else {
          throw Exception("Failed to upload logo");
        }
      } catch (e) {
        AppUtils.log("Error uploading logo: $e");
        throw Exception("Failed to upload logo");
      }
    }

    return logoUrl.value.isEmpty ? null : logoUrl.value;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    isUploading.value = true;

    try {
      // Upload logo first if selected
      String? uploadedLogoUrl;
      if (selectedLogoFile != null || logoUrl.value.isNotEmpty) {
        uploadedLogoUrl = await _uploadLogo();
      }

      // Prepare store data
      final storeData = {
        "name": _nameController.text.trim(),
        "description": _descriptionController.text.trim(),
        "address": _addressController.text.trim(),
        "contactEmail": _emailController.text.trim(),
        "contactPhone": _phoneController.text.trim(),
        if (uploadedLogoUrl != null) "logoUrl": uploadedLogoUrl,
      };

      final token = Preferences.authToken;

      dynamic response;
      if (isEditMode) {
        // Update existing store
        response = await _apiMethod.put(
          url: '${Urls.shop}/${widget.existingStore!.id}',
          authToken: token,
          body: storeData,
          headers: {},
        );
      } else {
        // Create new store
        response = await _apiMethod.post(
          url: Urls.shop,
          authToken: token,
          body: storeData,
          headers: {},
        );
      }

      isUploading.value = false;

      if (response.isSuccess) {
        AppUtils.toast(
          isEditMode
              ? "Store updated successfully"
              : "Store created successfully",
        );
        Get.back(result: true);
      } else {
        AppUtils.toastError(
          response.getError ??
              "Failed to ${isEditMode ? 'update' : 'create'} store",
        );
      }
    } catch (e) {
      isUploading.value = false;
      AppUtils.log("Error ${isEditMode ? 'updating' : 'creating'} store: $e");
      AppUtils.toastError("An error occurred. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: TextView(
          text: isEditMode ? "Edit Store" : "Create Store",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => isUploading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo Picker Section
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickLogo,
                              child: Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.btnColor.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: selectedLogoFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          selectedLogoFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : logoUrl.value.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          logoUrl.value.startsWith('http')
                                              ? logoUrl.value
                                              : '${Urls.appApiBaseUrl}${logoUrl.value}',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return _buildLogoPlaceholder();
                                              },
                                        ),
                                      )
                                    : _buildLogoPlaceholder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _pickLogo,
                              icon: Icon(
                                selectedLogoFile != null ||
                                        logoUrl.value.isNotEmpty
                                    ? Icons.edit
                                    : Icons.add_photo_alternate,
                                color: AppColors.btnColor,
                              ),
                              label: TextView(
                                text:
                                    selectedLogoFile != null ||
                                        logoUrl.value.isNotEmpty
                                    ? "Change Logo"
                                    : "Add Store Logo",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.btnColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Store Name
                      TextView(
                        text: "Store Name *",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      EditText(
                        controller: _nameController,
                        hint: "Enter store name",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Store name is required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Description
                      TextView(
                        text: "Description *",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      EditText(
                        controller: _descriptionController,
                        hint: "Describe your store",
                        noOfLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Description is required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Address
                      TextView(
                        text: "Address *",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      EditText(
                        controller: _addressController,
                        hint: "Store location or address",
                        noOfLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Address is required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Contact Email
                      TextView(
                        text: "Contact Email *",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      EditText(
                        controller: _emailController,
                        hint: "email@example.com",
                        inputType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Email is required";
                          }
                          if (!GetUtils.isEmail(value.trim())) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Contact Phone
                      TextView(
                        text: "Contact Phone *",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      EditText(
                        controller: _phoneController,
                        hint: "+1234567890",
                        inputType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Phone number is required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      AppButton(
                        label: isEditMode ? "Update Store" : "Create Store",
                        onTap: _handleSubmit,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.store, size: 50, color: Colors.grey[400]),
        const SizedBox(height: 8),
        TextView(
          text: "Store Logo",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

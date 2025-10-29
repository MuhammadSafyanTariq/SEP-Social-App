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
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/feature/data/models/dataModels/user_store/user_store_model.dart';
import 'package:sep/feature/presentation/controller/user_store_controller.dart';
import 'package:sep/feature/data/repository/iAuthRepository.dart';
import 'package:sep/feature/domain/respository/authRepository.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:sep/services/networking/urls.dart';

class CreateStoreScreen extends StatefulWidget {
  final UserStoreModel? store; // null for create, existing store for edit

  const CreateStoreScreen({Key? key, this.store}) : super(key: key);

  @override
  State<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserStoreController _storeController = Get.find<UserStoreController>();
  final AuthRepository _authRepository = IAuthRepository();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactEmailController;
  late final TextEditingController _contactPhoneController;

  // State
  String? _logoPath;
  bool _isLoading = false;
  bool _isUploadingLogo = false;
  bool get _isEditing => widget.store != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.store?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.store?.description ?? '',
    );
    _addressController = TextEditingController(
      text: widget.store?.address ?? '',
    );
    _contactEmailController = TextEditingController(
      text: widget.store?.contactEmail ?? '',
    );
    _contactPhoneController = TextEditingController(
      text: widget.store?.contactPhone ?? '',
    );
    _logoPath = widget.store?.logoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          AppBar2(
            title: _isEditing ? 'Edit Store' : 'Create Store',
            titleStyle: 18.txtMediumBlack,
            prefixImage: "back",
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: AppColors.white,
            hasTopSafe: true,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: 16.allSide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo Section
                    TextView(
                      text: 'Store Logo',
                      style: 16.txtMediumBlack,
                      margin: 8.bottom,
                    ),
                    _buildLogoSection(),
                    24.height,

                    // Store Details
                    TextView(
                      text: 'Store Information',
                      style: 18.txtMediumBlack,
                      margin: 8.bottom,
                    ),
                    16.height,

                    EditText(
                      controller: _nameController,
                      label: 'Store Name',
                      hint: 'Enter your store name',
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Store name is required';
                        }
                        return null;
                      },
                    ),
                    16.height,

                    EditText(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Describe your store',
                      noOfLines: 3,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    16.height,

                    EditText(
                      controller: _addressController,
                      label: 'Address',
                      hint: 'Enter store address',
                      noOfLines: 2,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Address is required';
                        }
                        return null;
                      },
                    ),
                    16.height,

                    TextView(
                      text: 'Contact Information',
                      style: 18.txtMediumBlack,
                      margin: EdgeInsets.only(top: 16, bottom: 8),
                    ),

                    EditText(
                      controller: _contactEmailController,
                      label: 'Email',
                      hint: 'Enter contact email',
                      inputType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Email is required';
                        }
                        if (!GetUtils.isEmail(value!)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    16.height,

                    EditText(
                      controller: _contactPhoneController,
                      label: 'Phone Number',
                      hint: 'Enter contact phone',
                      inputType: TextInputType.phone,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                    32.height,

                    // Submit Button
                    AppButton(
                      label: _isUploadingLogo
                          ? 'Uploading Logo...'
                          : _isLoading
                          ? (_isEditing ? 'Updating...' : 'Creating...')
                          : (_isEditing ? 'Update Store' : 'Create Store'),
                      onTap: (_isLoading || _isUploadingLogo)
                          ? null
                          : _handleSubmit,
                      isLoading: _isLoading || _isUploadingLogo,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Container(
        width: 200.sdp,
        height: 200.sdp,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: _logoPath != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildLogoImage(),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _logoPath = null),
                      child: Container(
                        padding: 8.allSide,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16.sdp,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, size: 48.sdp, color: AppColors.btnColor),
                  12.height,
                  TextView(text: 'Add Store Logo', style: 14.txtMediumBlack),
                  8.height,
                  AppButton(
                    label: 'Choose Image',
                    onTap: _pickLogo,
                    width: 150.sdp,
                    height: 45.sdp,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLogoImage() {
    // Check if it's a server image (full URL or relative path)
    final isServerImage =
        _logoPath!.startsWith('http') || _logoPath!.startsWith('/public/');

    if (isServerImage) {
      final fullLogoUrl = Urls.getFullImageUrl(_logoPath!);
      AppUtils.log("Store Logo - Raw: $_logoPath");
      AppUtils.log("Store Logo - Full: $fullLogoUrl");

      return ImageView(
        url: fullLogoUrl,
        fit: BoxFit.cover,
        width: 200.sdp,
        height: 198.sdp,
        imageType: ImageType.network,
      );
    } else {
      // Local file from image picker
      return Image.file(
        File(_logoPath!),
        fit: BoxFit.cover,
        width: 200.sdp,
        height: 200.sdp,
      );
    }
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _logoPath = image.path;
        });
      }
    } catch (e) {
      AppUtils.toast('Failed to pick image: $e');
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? logoUrl = _logoPath;

      // Upload logo if it's a local file
      if (_logoPath != null && !_logoPath!.startsWith('http')) {
        setState(() => _isUploadingLogo = true);
        AppUtils.toast('Uploading logo...');

        final uploadResponse = await _authRepository.uploadPhoto(
          imageFile: File(_logoPath!),
        );

        setState(() => _isUploadingLogo = false);

        if (uploadResponse.isSuccess && uploadResponse.data != null) {
          logoUrl = uploadResponse.data!.first;
          AppUtils.log('Logo uploaded successfully: $logoUrl');
        } else {
          AppUtils.toastError('Failed to upload logo');
          return;
        }
      }

      final store = UserStoreModel(
        id: widget.store?.id ?? '',
        name: _nameController.text.trim(),
        ownerId:
            ProfileCtrl.find.profileData.value.id ?? '', // Use actual user ID
        description: _descriptionController.text.trim(),
        logoUrl: logoUrl ?? '',
        address: _addressController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        products: widget.store?.products ?? [],
        createdAt: widget.store?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success = false;
      if (_isEditing) {
        success = await _storeController.updateStore(store);
      } else {
        success = await _storeController.createStore(store);
      }

      if (success) {
        // Wait a bit for the toast to show
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Get.back(result: true);
        }
      }
    } catch (e) {
      AppUtils.toastError(
        'Failed to ${_isEditing ? 'update' : 'create'} store: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploadingLogo = false;
        });
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/coreComponents/EditText.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/presentation/controller/jobs_controller.dart';
import 'package:sep/utils/extensions/size.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load existing worker profile data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<JobsController>();
      controller.loadWorkerProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JobsController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.newgrey,
          body: Column(
            children: [
              // Custom AppBar2
              AppBar2(
                title: 'Setup Worker Profile',
                titleStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                prefixImage: 'back',
                onPrefixTap: () => Navigator.pop(context),
                backgroundColor: AppColors.white,
              ),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.sdp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24.sdp),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.sdp),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(16.sdp),
                              decoration: BoxDecoration(
                                color: AppColors.greenlight.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.work_outline,
                                size: 40.sdp,
                                color: AppColors.greenlight,
                              ),
                            ),
                            SizedBox(height: 16.sdp),
                            const TextView(
                              text: 'Complete Your Worker Profile',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.sdp),
                            TextView(
                              text:
                                  'Set up your professional profile to start receiving job opportunities',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.sdp),

                      // Form Card
                      Container(
                        padding: EdgeInsets.all(24.sdp),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.sdp),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profession dropdown
                            const TextView(
                              text: 'Profession',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.sdp),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.sdp,
                                vertical: 4.sdp,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(10.sdp),
                                color: AppColors.white,
                              ),
                              child: Obx(
                                () => DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value:
                                        controller
                                            .selectedProfessionType
                                            .value
                                            .isEmpty
                                        ? null
                                        : controller
                                              .selectedProfessionType
                                              .value,
                                    hint: Text(
                                      'Choose your profession',
                                      style: TextStyle(
                                        color: AppColors.greyHint,
                                        fontSize: 14,
                                      ),
                                    ),
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: AppColors.grey,
                                    ),
                                    items:
                                        [
                                              'software-developer',
                                              'web-developer',
                                              'mobile-developer',
                                              'data-scientist',
                                              'ui-ux-designer',
                                              'graphic-designer',
                                              'content-writer',
                                              'digital-marketer',
                                              'project-manager',
                                              'business-analyst',
                                              'virtual-assistant',
                                              'translator',
                                              'photographer',
                                              'videographer',
                                              'consultant',
                                              'accountant',
                                              'sales-representative',
                                              'customer-support',
                                              'teacher',
                                              'other',
                                            ]
                                            .map(
                                              (
                                                profession,
                                              ) => DropdownMenuItem<String>(
                                                value: profession,
                                                child: Text(
                                                  profession
                                                      .split('-')
                                                      .map(
                                                        (word) =>
                                                            word[0]
                                                                .toUpperCase() +
                                                            word.substring(1),
                                                      )
                                                      .join(' '),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      controller.selectedProfessionType.value =
                                          value ?? '';
                                    },
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20.sdp),

                            // Address field
                            EditText(
                              label: 'Address',
                              hint: 'Enter your full address',
                              controller: controller.countryController,
                              prefixIcon: Icon(
                                Icons.location_on,
                                color: AppColors.grey,
                              ),
                              margin: EdgeInsets.only(bottom: 16.sdp),
                              borderColor: AppColors.border,
                              filledColor: AppColors.white,
                              isFilled: true,
                              radius: 10.sdp,
                            ),

                            // City field
                            EditText(
                              label: 'City',
                              hint: 'Enter your city',
                              controller: controller.cityController,
                              prefixIcon: Icon(
                                Icons.location_city,
                                color: AppColors.grey,
                              ),
                              borderColor: AppColors.border,
                              filledColor: AppColors.white,
                              isFilled: true,
                              radius: 10.sdp,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.sdp),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.sdp),
                                side: BorderSide(color: AppColors.greenlight),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.sdp),
                                ),
                              ),
                              child: TextView(
                                text: 'Cancel',
                                style: TextStyle(
                                  color: AppColors.greenlight,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.sdp),
                          Expanded(
                            flex: 2,
                            child: Obx(
                              () => AppButton(
                                label: controller.isUpdatingProfile.value
                                    ? 'Updating...'
                                    : controller.isLoading.value
                                    ? 'Loading...'
                                    : 'Save Profile',
                                buttonColor: AppColors.greenlight,
                                isLoading:
                                    controller.isUpdatingProfile.value ||
                                    controller.isLoading.value,
                                onTap: controller.isLoading.value
                                    ? null
                                    : () {
                                        _validateAndSaveProfile(
                                          context,
                                          controller,
                                        );
                                      },
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.sdp),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _validateAndSaveProfile(
    BuildContext context,
    JobsController controller,
  ) {
    // Validate required fields
    if (controller.selectedProfessionType.value.isEmpty) {
      _showErrorSnackbar(context, 'Please select your profession');
      return;
    }

    if (controller.countryController.text.trim().isEmpty) {
      _showErrorSnackbar(context, 'Please enter your address');
      return;
    }

    if (controller.cityController.text.trim().isEmpty) {
      _showErrorSnackbar(context, 'Please enter your city');
      return;
    }

    // Save profile using existing /api/update endpoint
    controller.updateWorkerProfile().then((success) {
      if (success) {
        Navigator.pop(context);
        _showSuccessSnackbar(context, 'Profile updated successfully!');
      } else {
        _showErrorSnackbar(
          context,
          'Failed to update profile. Please try again.',
        );
      }
    });
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.greenlight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

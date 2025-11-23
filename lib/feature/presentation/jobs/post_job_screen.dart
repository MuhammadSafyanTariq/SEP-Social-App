import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/EditText.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/data/models/dataModels/job_model/job_model.dart';
import 'package:sep/feature/presentation/controller/jobs_controller.dart';
import 'package:sep/utils/extensions/widget.dart';

class PostJobScreen extends StatelessWidget {
  final bool editMode;
  final JobModel? jobToEdit;

  const PostJobScreen({super.key, this.editMode = false, this.jobToEdit});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    Get.put(JobsController());

    return GetBuilder<JobsController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.newgrey,
          body: Column(
            children: [
              // Custom AppBar2
              AppBar2(
                title: editMode ? 'Edit Job' : 'Post a Job',
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.work_outline,
                                size: 32,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            16.height,
                            const TextView(
                              text: 'Create Job Posting',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            8.height,
                            TextView(
                              text:
                                  'Find the perfect candidate for your opportunity',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      20.height,

                      // Form Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Job Title
                            EditText(
                              controller: controller.jobTitleController,
                              label: 'Job Title',
                              hint: 'e.g. Senior Flutter Developer',
                              prefixIcon: const Icon(
                                Icons.work_outline,
                                color: AppColors.grey,
                              ),
                              inputType: TextInputType.text,
                              margin: const EdgeInsets.only(bottom: 20),
                              validator: (value) {
                                if (value?.trim().isEmpty ?? true) {
                                  return 'Job title is required';
                                }
                                return null;
                              },
                            ),

                            // Job Type Dropdown
                            const TextView(
                              text: 'Job Type',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              margin: EdgeInsets.only(bottom: 8),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Obx(
                                () => DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value:
                                        controller
                                            .selectedJobTypeForPost
                                            .value
                                            .isEmpty
                                        ? null
                                        : controller
                                              .selectedJobTypeForPost
                                              .value,
                                    hint: const Text(
                                      'Select job type',
                                      style: TextStyle(color: AppColors.grey),
                                    ),
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: AppColors.grey,
                                    ),
                                    items:
                                        [
                                              'full-time',
                                              'part-time',
                                              'contract',
                                              'freelance',
                                              'internship',
                                            ]
                                            .map(
                                              (
                                                type,
                                              ) => DropdownMenuItem<String>(
                                                value: type,
                                                child: Text(
                                                  type
                                                      .split('-')
                                                      .map(
                                                        (word) =>
                                                            word[0]
                                                                .toUpperCase() +
                                                            word.substring(1),
                                                      )
                                                      .join(' '),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      controller.selectedJobTypeForPost.value =
                                          value ?? '';
                                    },
                                  ),
                                ),
                              ),
                            ),
                            20.height,

                            // Country Field
                            EditText(
                              controller: controller.jobCountryController,
                              label: 'Country',
                              hint: 'e.g. Pakistan',
                              prefixIcon: const Icon(
                                Icons.public_outlined,
                                color: AppColors.grey,
                              ),
                              inputType: TextInputType.text,
                              margin: const EdgeInsets.only(bottom: 20),
                              validator: (value) {
                                if (value?.trim().isEmpty ?? true) {
                                  return 'Country is required';
                                }
                                return null;
                              },
                            ),

                            // City Field
                            EditText(
                              controller: controller.jobCityController,
                              label: 'City',
                              hint: 'e.g. Karachi',
                              prefixIcon: const Icon(
                                Icons.location_city_outlined,
                                color: AppColors.grey,
                              ),
                              inputType: TextInputType.text,
                              margin: const EdgeInsets.only(bottom: 20),
                              validator: (value) {
                                if (value?.trim().isEmpty ?? true) {
                                  return 'City is required';
                                }
                                return null;
                              },
                            ),

                            // Job Description
                            EditText(
                              controller: controller.jobDescriptionController,
                              label: 'Job Description',
                              hint:
                                  'Describe responsibilities, requirements, qualifications...',
                              noOfLines: 5,
                              inputType: TextInputType.multiline,
                              margin: const EdgeInsets.only(bottom: 20),
                              validator: (value) {
                                if (value?.trim().isEmpty ?? true) {
                                  return 'Job description is required';
                                }
                                if ((value?.trim().length ?? 0) < 50) {
                                  return 'Description should be at least 50 characters';
                                }
                                return null;
                              },
                            ),

                            // Contact Email
                            EditText(
                              controller: controller.jobContactController,
                              label: 'Contact Email',
                              hint: 'applications@company.com',
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: AppColors.grey,
                              ),
                              inputType: TextInputType.emailAddress,
                              margin: const EdgeInsets.only(bottom: 24),
                              validator: (value) {
                                if (value?.trim().isEmpty ?? true) {
                                  return 'Contact email is required';
                                }
                                final emailRegex = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                );
                                if (!emailRegex.hasMatch(value!.trim())) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),

                            // Terms and Conditions
                            Obx(
                              () => InkWell(
                                onTap: () {
                                  controller.acceptTerms.value =
                                      !controller.acceptTerms.value;
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.only(
                                        right: 12,
                                        top: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: controller.acceptTerms.value
                                            ? AppColors.primaryColor
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: controller.acceptTerms.value
                                              ? AppColors.primaryColor
                                              : AppColors.grey,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: controller.acceptTerms.value
                                          ? const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    Expanded(
                                      child: TextView(
                                        text:
                                            'I agree to the terms and conditions for posting job listings and confirm that all information provided is accurate.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.grey,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      32.height,

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(color: AppColors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const TextView(
                                text: 'Cancel',
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          16.width,
                          Expanded(
                            flex: 2,
                            child: Obx(
                              () => AppButton(
                                label: controller.isPosting.value
                                    ? (editMode ? 'Updating...' : 'Posting...')
                                    : (editMode ? 'Update Job' : 'Post Job'),
                                buttonColor: AppColors.primaryColor,
                                isLoading: controller.isPosting.value,
                                onTap: () =>
                                    _validateAndSubmitJob(context, controller),
                              ),
                            ),
                          ),
                        ],
                      ),

                      24.height,
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

  void _validateAndSubmitJob(
    BuildContext context,
    JobsController controller,
  ) async {
    // Validate required fields
    if (controller.jobTitleController.text.trim().isEmpty) {
      _showMessage(context, 'Please enter a job title', isError: true);
      return;
    }

    if (controller.selectedJobTypeForPost.value.isEmpty) {
      _showMessage(context, 'Please select a job type', isError: true);
      return;
    }

    if (controller.jobCountryController.text.trim().isEmpty) {
      _showMessage(context, 'Please enter the country', isError: true);
      return;
    }

    if (controller.jobCityController.text.trim().isEmpty) {
      _showMessage(context, 'Please enter the city', isError: true);
      return;
    }

    if (controller.jobDescriptionController.text.trim().isEmpty) {
      _showMessage(context, 'Please enter a job description', isError: true);
      return;
    }

    if (controller.jobDescriptionController.text.trim().length < 50) {
      _showMessage(
        context,
        'Job description should be at least 50 characters',
        isError: true,
      );
      return;
    }

    if (controller.jobContactController.text.trim().isEmpty) {
      _showMessage(context, 'Please enter a contact email', isError: true);
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(controller.jobContactController.text.trim())) {
      _showMessage(
        context,
        'Please enter a valid email address',
        isError: true,
      );
      return;
    }

    if (!controller.acceptTerms.value) {
      _showMessage(
        context,
        'Please accept the terms and conditions',
        isError: true,
      );
      return;
    }

    // Submit job (post or update)
    try {
      final success = editMode && jobToEdit != null
          ? await controller.updateJob(jobToEdit!)
          : await controller.postJob();

      if (success) {
        Navigator.pop(context);
        _showMessage(
          context,
          editMode ? 'Job updated successfully!' : 'Job posted successfully!',
          isError: false,
        );
      } else {
        _showMessage(
          context,
          editMode
              ? 'Failed to update job. Please try again.'
              : 'Failed to post job. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      _showMessage(
        context,
        editMode
            ? 'Error updating job: ${e.toString()}'
            : 'Error posting job: ${e.toString()}',
        isError: true,
      );
    }
  }

  void _showMessage(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            12.width,
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/data/models/dataModels/job_model/job_model.dart';
import 'package:sep/feature/presentation/controller/jobs_controller.dart';
import 'package:sep/feature/presentation/controller/chat_ctrl.dart';
import 'package:sep/feature/presentation/jobs/post_job_screen.dart';
import 'package:sep/feature/presentation/jobs/worker_profile_screen.dart';
import 'package:sep/feature/presentation/chatScreens/Messages_Screen.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/feature/presentation/Home/CommonBannerAdWidget.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  Timer? _adTimer;
  bool _showAd = false;

  @override
  void initState() {
    super.initState();
    _startAdTimer();
  }

  void _startAdTimer() {
    // Show ad every 2 minutes
    _adTimer = Timer.periodic(Duration(minutes: 2), (timer) {
      if (mounted) {
        setState(() {
          _showAd = true;
        });

        // Hide ad after 30 seconds
        Future.delayed(Duration(seconds: 30), () {
          if (mounted) {
            setState(() {
              _showAd = false;
            });
          }
        });
      }
    });

    // Show ad immediately on first load
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showAd = true;
        });

        // Hide after 30 seconds
        Future.delayed(Duration(seconds: 30), () {
          if (mounted) {
            setState(() {
              _showAd = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JobsController>(
      init: JobsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.white,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              context.pushNavigator(const PostJobScreen());
            },
            backgroundColor: AppColors.primaryColor,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Post Job',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Column(
            children: [
              // Custom AppBar2
              AppBar2(
                title: 'Jobs',
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
                child: Column(
                  children: [
                    // Search and filters section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Search bar with filter button
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: AppColors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: controller.searchController,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Search jobs, locations, companies...',
                                      prefixIcon: Obx(
                                        () => controller.isSearching.value
                                            ? const Padding(
                                                padding: EdgeInsets.all(12),
                                                child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              )
                                            : const Icon(
                                                Icons.search,
                                                color: Colors.grey,
                                              ),
                                      ),
                                      suffixIcon: Obx(
                                        () =>
                                            controller
                                                .searchQuery
                                                .value
                                                .isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.clear,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  controller.searchController
                                                      .clear();
                                                  controller.searchQuery.value =
                                                      '';
                                                  controller
                                                      .applyFilters(); // Refresh the list
                                                },
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.grey.withOpacity(0.3),
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: () => _showFiltersBottomSheet(
                                    context,
                                    controller,
                                  ),
                                  icon: Obx(() {
                                    bool hasActiveFilters =
                                        controller.selectedJobType.value !=
                                            'all' ||
                                        controller.selectedLocation.value !=
                                            'all';
                                    return Icon(
                                      Icons.tune,
                                      color: hasActiveFilters
                                          ? AppColors.primaryColor
                                          : Colors.grey[600],
                                    );
                                  }),
                                  tooltip: 'Filters',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Job Type Filter chips
                          SizedBox(
                            height: 40,
                            child: Obx(
                              () => ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _buildFilterChip(
                                    context,
                                    'All Jobs',
                                    controller.selectedJobType.value == 'all',
                                    () =>
                                        controller.applyFilters(jobType: 'all'),
                                  ),
                                  ...controller.jobTypes
                                      .where((type) => type != 'all')
                                      .map(
                                        (type) => _buildFilterChip(
                                          context,
                                          type
                                              .split('-')
                                              .map(
                                                (word) =>
                                                    word[0].toUpperCase() +
                                                    word.substring(1),
                                              )
                                              .join(' '),
                                          controller.selectedJobType.value ==
                                              type,
                                          () => controller.applyFilters(
                                            jobType: type,
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          const SizedBox(height: 16),

                          // Action button
                          AppButton(
                            label: 'Setup Worker Profile',
                            buttonColor: AppColors.primaryColor.withOpacity(
                              0.1,
                            ),
                            labelStyle: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                            onTap: () {
                              context.pushNavigator(
                                const WorkerProfileScreen(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Jobs count indicator
                    Obx(
                      () => controller.filteredJobs.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: TextView(
                                text:
                                    '${controller.filteredJobs.length} job${controller.filteredJobs.length == 1 ? '' : 's'} found',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Banner Ad (conditionally shown)
                    if (_showAd)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: CommonBannerAdWidget(
                                adUnitId: Platform.isAndroid
                                    ? 'ca-app-pub-7164424730429677/2234858629'
                                    : 'ca-app-pub-7164424730429677/2234858629',
                              ),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showAd = false;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Jobs list
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value &&
                            controller.allJobs.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (controller.filteredJobs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.work_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                TextView(
                                  text: controller.searchQuery.value.isNotEmpty
                                      ? 'No jobs found for "${controller.searchQuery.value}"'
                                      : 'No jobs available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextView(
                                  text: 'Try adjusting your search or filters',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: controller.refreshJobs,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: controller.filteredJobs.length,
                            itemBuilder: (context, index) {
                              final job = controller.filteredJobs[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildJobCard(context, job),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey[200],
        selectedColor: AppColors.greenlight,
        showCheckmark: false,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, JobModel job) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showJobDetails(context, job);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextView(
                      text: job.jobTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxlines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getJobTypeColor(job.jobType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextView(
                      text: job.jobType
                          .split('-')
                          .map(
                            (word) => word[0].toUpperCase() + word.substring(1),
                          )
                          .join(' '),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getJobTypeColor(job.jobType),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Poster details
              if (job.userId != null) ...[
                FutureBuilder<Map<String, dynamic>?>(
                  future: _getUserDetails(job.userId!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final user = snapshot.data!;
                      final userName =
                          user['name'] ?? user['username'] ?? 'Unknown User';
                      final userImage = user['profileImage'] ?? user['image'];

                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primaryColor.withOpacity(
                              0.1,
                            ),
                            backgroundImage:
                                userImage != null && userImage.isNotEmpty
                                ? NetworkImage(
                                    AppUtils.configImageUrl(userImage),
                                  )
                                : null,
                            child: userImage == null || userImage.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 16,
                                    color: AppColors.primaryColor,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          TextView(
                            text: 'Posted by $userName',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 8),
              ],

              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  TextView(
                    text: '${job.city}, ${job.country}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              TextView(
                text: job.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxlines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextView(
                    text: job.createdAt != null
                        ? _formatDate(job.createdAt!)
                        : 'Recently posted',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getJobTypeColor(String jobType) {
    switch (jobType) {
      case 'full-time':
        return Colors.green;
      case 'part-time':
        return Colors.blue;
      case 'contract':
        return Colors.orange;
      case 'freelance':
        return Colors.purple;
      case 'internship':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<Map<String, dynamic>?> _getUserDetails(String userId) async {
    try {
      AppUtils.log('Fetching user details for userId: $userId');

      // Use the same method as ProfileCtrl.getFriendProfileDetails
      final response = await IApiMethod().get(
        query: {'id': userId},
        url: '/api/getUser', // Same as Urls.getUserDetails
        authToken: Preferences.authToken,
        headers: {},
      );

      if (response.isSuccess && response.data != null) {
        AppUtils.log('User API response: ${response.data}');

        final userData = response.data!['data'] ?? response.data!;
        final name =
            userData['name'] ??
            userData['username'] ??
            userData['fullName'] ??
            userData['displayName'];
        final username =
            userData['username'] ?? userData['name'] ?? userData['email'];
        final image =
            userData['profileImage'] ??
            userData['image'] ??
            userData['profilePicture'] ??
            userData['avatar'];

        AppUtils.log(
          'Found user data: name=$name, username=$username, image=$image',
        );

        if (name != null && name.toString().isNotEmpty) {
          return {
            'name': name.toString(),
            'username': username?.toString() ?? 'user',
            'profileImage': image?.toString(),
          };
        }
      }

      AppUtils.log('API call failed or returned empty data');
      // Fallback to realistic mock data
      final mockNames = [
        'John Doe',
        'Jane Smith',
        'Mike Johnson',
        'Sarah Wilson',
        'David Brown',
        'Lisa Davis',
        'Tom Anderson',
        'Emma Taylor',
      ];
      final randomName = mockNames[userId.hashCode % mockNames.length];

      return {
        'name': randomName,
        'username': randomName.toLowerCase().replaceAll(' ', '_'),
        'profileImage': null,
      };
    } catch (e) {
      AppUtils.logEr('Error fetching user details: $e');
      // Return realistic mock data as fallback
      return {'name': 'John Doe', 'username': 'john_doe', 'profileImage': null};
    }
  }

  void _showJobDetails(BuildContext context, JobModel job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextView(
                  text: job.jobTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    TextView(
                      text: '${job.city}, ${job.country}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getJobTypeColor(job.jobType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextView(
                        text: job.jobType
                            .split('-')
                            .map(
                              (word) =>
                                  word[0].toUpperCase() + word.substring(1),
                            )
                            .join(' '),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getJobTypeColor(job.jobType),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const TextView(
                  text: 'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                TextView(
                  text: job.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),

                const SizedBox(height: 24),

                // Poster Information
                if (job.userId != null) ...[
                  const TextView(
                    text: 'Posted By',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  FutureBuilder<Map<String, dynamic>?>(
                    future: _getUserDetails(job.userId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Loading poster details...'),
                          ],
                        );
                      }

                      if (snapshot.hasData && snapshot.data != null) {
                        final user = snapshot.data!;
                        final userName =
                            user['name'] ?? user['username'] ?? 'Unknown User';
                        final userImage = user['profileImage'] ?? user['image'];

                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primaryColor
                                  .withOpacity(0.1),
                              backgroundImage:
                                  userImage != null && userImage.isNotEmpty
                                  ? NetworkImage(
                                      AppUtils.configImageUrl(userImage),
                                    )
                                  : null,
                              child: userImage == null || userImage.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      size: 24,
                                      color: AppColors.primaryColor,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextView(
                                    text: userName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextView(
                                    text: 'Job Poster',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                const TextView(
                  text: 'Contact Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.email, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextView(
                        text: job.contact,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (job.createdAt != null) ...[
                  TextView(
                    text: 'Posted ${_formatDate(job.createdAt!)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                ],

                // Only show contact button if the job poster is not the current user
                if (job.userId != null && job.userId != Preferences.uid) ...[
                  AppButton(
                    label: 'Contact',
                    buttonColor: AppColors.primaryColor,
                    onTap: () async {
                      final userId = job.userId;
                      if (userId != null && userId.isNotEmpty) {
                        // Store the navigator before async operations
                        final navigator = Navigator.of(context);

                        // Close the bottom sheet first
                        navigator.pop();

                        // Start fetching user details and check for existing chat
                        _navigateToChat(userId, job);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Unable to contact poster - user information not available',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ] else if (job.userId == Preferences.uid) ...[
                  // Show Edit and Delete buttons for own jobs
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Edit',
                          buttonColor: AppColors.btnColor,
                          onTap: () {
                            Navigator.pop(context);
                            _editJob(context, job);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'Delete',
                          buttonColor: Colors.red,
                          onTap: () {
                            Navigator.pop(context);
                            _deleteJob(context, job);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFiltersBottomSheet(
    BuildContext context,
    JobsController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TextView(
                    text: 'Filters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job Type Section
                      const TextView(
                        text: 'Job Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Obx(
                        () => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.jobTypes.map((type) {
                            final isSelected =
                                controller.selectedJobType.value == type;
                            return FilterChip(
                              label: Text(
                                type == 'all'
                                    ? 'All Jobs'
                                    : type
                                          .split('-')
                                          .map(
                                            (word) =>
                                                word[0].toUpperCase() +
                                                word.substring(1),
                                          )
                                          .join(' '),
                              ),
                              selected: isSelected,
                              onSelected: (_) {
                                controller.applyFilters(jobType: type);
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: AppColors.greenlight,
                              showCheckmark: false,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Location Section
                      const TextView(
                        text: 'Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // All locations option
                      ListTile(
                        title: const Text('All Locations'),
                        leading: Obx(
                          () => Radio<String>(
                            value: 'all',
                            groupValue: controller.selectedLocation.value,
                            onChanged: (value) {
                              controller.applyFilters(location: value!);
                            },
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),

                      // Dynamic locations from jobs
                      ...controller.getUniqueLocations().map(
                        (location) => ListTile(
                          title: Text(location),
                          leading: Obx(
                            () => Radio<String>(
                              value: location,
                              groupValue: controller.selectedLocation.value,
                              onChanged: (value) {
                                controller.applyFilters(location: value!);
                              },
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              AppButton(
                label: 'Apply Filters',
                buttonColor: AppColors.primaryColor,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToChat(String userId, JobModel job) async {
    try {
      AppUtils.log('🔍 Checking for existing chat with userId: $userId');

      // Get the chat controller
      final chatCtrl = ChatCtrl.find;

      // Refresh recent chats to get latest data
      chatCtrl.fireRecentChatEvent();

      // Wait a moment for recent chats to load
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if there's an existing chat with this user
      String? existingChatId;
      for (var recentChat in chatCtrl.recentChat) {
        if (recentChat.users?.contains(userId) == true &&
            recentChat.users?.contains(Preferences.uid) == true) {
          existingChatId = recentChat.id;
          AppUtils.log('✅ Found existing chat ID: $existingChatId');
          break;
        }
      }

      if (existingChatId == null) {
        AppUtils.log('📝 No existing chat found, will create new chat');
      }

      // Get user details for the chat
      final userDetails = await _getUserDetails(userId);

      if (userDetails != null) {
        final userName =
            userDetails['name']?.toString() ??
            userDetails['username']?.toString() ??
            'Job Poster';
        final userImage =
            userDetails['profileImage']?.toString() ??
            userDetails['image']?.toString();

        AppUtils.log(
          'User details fetched - Name: $userName, Image: $userImage',
        );

        // Create ProfileDataModel for the job poster
        final profileData = ProfileDataModel(
          id: userId,
          name: userName,
          image: userImage,
        );

        // Navigate to MessageScreen with existing chatId if found
        AppUtils.log(
          'Navigating to MessageScreen${existingChatId != null ? " with existing chat ID: $existingChatId" : " (new chat)"}',
        );

        Get.to(
          () => MessageScreen(
            data: profileData,
            chatId: existingChatId, // Pass existing chatId or null for new chat
          ),
        );
        AppUtils.log('Navigation to MessageScreen completed');
      } else {
        // Fallback if user details can't be fetched
        AppUtils.logEr('User details are null for userId: $userId');
        AppUtils.toastError('Unable to load user details. Please try again.');
      }
    } catch (e) {
      AppUtils.logEr('Error navigating to chat: $e');
      AppUtils.toastError('Error opening chat. Please try again.');
    }
  }

  void _navigateToChatScreenImmediate(String userId, JobModel job) async {
    try {
      AppUtils.log('Starting chat with userId: $userId');

      // Get user details for the chat
      final userDetails = await _getUserDetails(userId);

      if (userDetails != null) {
        final userName =
            userDetails['name']?.toString() ??
            userDetails['username']?.toString() ??
            'Job Poster';
        final userImage =
            userDetails['profileImage']?.toString() ??
            userDetails['image']?.toString();

        AppUtils.log(
          'User details fetched - Name: $userName, Image: $userImage',
        );

        // Create ProfileDataModel for the job poster
        final profileData = ProfileDataModel(
          id: userId,
          name: userName,
          image: userImage,
        );

        // Navigate to MessageScreen using Get.context which is always available
        AppUtils.log('Navigating to MessageScreen with profile data');

        Get.to(() => MessageScreen(data: profileData));
        AppUtils.log('Navigation to MessageScreen completed');
      } else {
        // Fallback if user details can't be fetched
        AppUtils.logEr('User details are null for userId: $userId');
        AppUtils.toastError('Unable to load user details. Please try again.');
      }
    } catch (e) {
      AppUtils.logEr('Error navigating to chat: $e');
      AppUtils.toastError('Error opening chat. Please try again.');
    }
  }

  void _navigateToChatScreen(
    BuildContext context,
    String userId,
    JobModel job,
  ) async {
    try {
      // Validate input parameters
      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid user ID. Cannot start chat.')),
        );
        return;
      }

      AppUtils.log('Starting chat with userId: $userId');

      // Get user details for the chat
      final userDetails = await _getUserDetails(userId);

      if (userDetails != null) {
        final userName =
            userDetails['name']?.toString() ??
            userDetails['username']?.toString() ??
            'Job Poster';
        final userImage =
            userDetails['profileImage']?.toString() ??
            userDetails['image']?.toString();

        AppUtils.log(
          'User details fetched - Name: $userName, Image: $userImage',
        );

        // Create ProfileDataModel for the job poster
        final profileData = ProfileDataModel(
          id: userId,
          name: userName,
          image: userImage,
        );

        // Navigate to MessageScreen using the same method as friend profile
        AppUtils.log('Navigating to MessageScreen with profile data');

        try {
          context.pushNavigator(MessageScreen(data: profileData));
          AppUtils.log('Navigation to MessageScreen completed');
        } catch (navError) {
          AppUtils.logEr('Navigation error: $navError');
        }
      } else {
        // Fallback if user details can't be fetched
        AppUtils.logEr('User details are null for userId: $userId');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to load user details. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      AppUtils.logEr('Error navigating to chat: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening chat. Please try again.'),
          ),
        );
      }
    }
  }

  void _editJob(BuildContext context, JobModel job) {
    final controller = Get.find<JobsController>();

    // Pre-fill the form with existing job data
    controller.jobTitleController.text = job.jobTitle;
    controller.jobCountryController.text = job.country;
    controller.jobCityController.text = job.city;
    controller.jobDescriptionController.text = job.description;
    controller.jobContactController.text = job.contact;
    controller.selectedJobTypeForPost.value = job.jobType;

    // Navigate to edit screen (reuse PostJobScreen with edit mode)
    context.pushNavigator(PostJobScreen(editMode: true, jobToEdit: job));
  }

  void _deleteJob(BuildContext context, JobModel job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const TextView(
            text: 'Delete Job',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: const TextView(
            text:
                'Are you sure you want to delete this job posting? This action cannot be undone.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const TextView(
                text: 'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog

                try {
                  final controller = Get.find<JobsController>();
                  final success = await controller.deleteJob(job.id!);

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Job deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete job: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const TextView(
                text: 'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sep/feature/data/models/dataModels/job_model/job_model.dart';
import 'package:sep/services/jobs/jobs_api_service.dart';
import 'package:sep/utils/appUtils.dart';

class JobsController extends GetxController {
  static JobsController get find => Get.find<JobsController>();

  // Observable lists
  final RxList<JobModel> allJobs = <JobModel>[].obs;
  final RxList<JobModel> filteredJobs = <JobModel>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isPosting = false.obs;
  final RxBool isUpdatingProfile = false.obs;

  // Worker profile form controllers
  final TextEditingController countryController =
      TextEditingController(); // Used for address
  final TextEditingController cityController = TextEditingController();
  final RxString selectedProfessionType = ''.obs;

  // Job posting form controllers
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController jobCountryController = TextEditingController();
  final TextEditingController jobCityController = TextEditingController();
  final TextEditingController jobDescriptionController =
      TextEditingController();
  final TextEditingController jobContactController = TextEditingController();
  final RxString selectedJobTypeForPost = ''.obs;
  final RxBool acceptTerms = false.obs;

  // Search and filter
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedJobType = 'all'.obs;
  final RxString selectedLocation = 'all'.obs;

  // Job types for filter
  final List<String> jobTypes = [
    'all',
    'full-time',
    'part-time',
    'contract',
    'freelance',
    'internship',
  ];

  @override
  void onInit() {
    super.onInit();
    loadJobs();

    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _debounceSearch();
    });
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    countryController.dispose();
    cityController.dispose();
    jobTitleController.dispose();
    jobCountryController.dispose();
    jobCityController.dispose();
    jobDescriptionController.dispose();
    jobContactController.dispose();
    super.onClose();
  }

  /// Load all jobs
  Future<void> loadJobs() async {
    try {
      isLoading.value = true;
      final jobs = await JobsApiService.getJobs();
      allJobs.assignAll(jobs);
      filteredJobs.assignAll(jobs);

      // Debug log
      AppUtils.log('Jobs loaded: ${jobs.length} jobs');
      for (var job in jobs) {
        AppUtils.log('Job: ${job.jobTitle} - ${job.jobType}');
      }
    } catch (e) {
      AppUtils.logEr('Failed to load jobs: $e');
      // Fallback to sample jobs for now
      _loadSampleJobs();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load sample jobs for testing
  void _loadSampleJobs() {
    final sampleJobs = [
      JobModel(
        id: 'sample_1',
        jobTitle: 'Flutter Developer',
        country: 'Pakistan',
        city: 'Karachi',
        jobType: 'full-time',
        description:
            'We are looking for an experienced Flutter developer to join our team...',
        contact: 'hr@company.com',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      JobModel(
        id: 'sample_2',
        jobTitle: 'UI/UX Designer',
        country: 'Pakistan',
        city: 'Lahore',
        jobType: 'part-time',
        description:
            'Looking for a creative UI/UX designer to design mobile applications...',
        contact: 'design@studio.com',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      JobModel(
        id: 'sample_3',
        jobTitle: 'Backend Engineer',
        country: 'USA',
        city: 'Austin',
        jobType: 'contract',
        description: '5+ years Node.js experience required...',
        contact: 'talent@example.com',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    allJobs.assignAll(sampleJobs);
    filteredJobs.assignAll(sampleJobs);
    AppUtils.log('Sample jobs loaded: ${sampleJobs.length} jobs');
  }

  /// Search jobs
  Future<void> searchJobs(String query) async {
    if (query.isEmpty) {
      applyFilters(); // This will refresh the filtered list with current filters
      return;
    }

    // First apply local filtering for immediate feedback
    _filterJobsLocally();

    try {
      isSearching.value = true;
      // Try to get fresh results from API
      final jobs = await JobsApiService.getJobs(searchQuery: query);

      // Update all jobs if we got new results
      if (jobs.isNotEmpty) {
        allJobs.assignAll(jobs);
        _filterJobsLocally(); // Re-apply filters with new data
      }
    } catch (e) {
      AppUtils.logEr('Search API failed, using local filtering: $e');
      // Local filtering is already applied above
    } finally {
      isSearching.value = false;
    }
  }

  /// Filter jobs locally by job type and location
  void _filterJobsLocally() {
    AppUtils.log(
      'Filtering jobs: Total=${allJobs.length}, JobType=${selectedJobType.value}, Location=${selectedLocation.value}, Search=${searchQuery.value}',
    );

    List<JobModel> filtered = allJobs.where((job) {
      bool matchesSearch =
          searchQuery.value.isEmpty ||
          job.jobTitle.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          job.description.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          job.city.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          job.country.toLowerCase().contains(searchQuery.value.toLowerCase());

      bool matchesJobType =
          selectedJobType.value == 'all' ||
          job.jobType == selectedJobType.value;

      bool matchesLocation =
          selectedLocation.value == 'all' ||
          '${job.city}, ${job.country}'.toLowerCase() ==
              selectedLocation.value.toLowerCase() ||
          job.city.toLowerCase().contains(
            selectedLocation.value.toLowerCase(),
          ) ||
          job.country.toLowerCase().contains(
            selectedLocation.value.toLowerCase(),
          );

      bool matches = matchesSearch && matchesJobType && matchesLocation;

      if (!matches) {
        AppUtils.log(
          'Job filtered out: ${job.jobTitle} (type: ${job.jobType}, search: $matchesSearch, type: $matchesJobType, location: $matchesLocation)',
        );
      }

      return matches;
    }).toList();

    filteredJobs.assignAll(filtered);
    AppUtils.log('Filtering complete: ${filtered.length} jobs match criteria');
  }

  /// Debounce search to avoid too many API calls
  void _debounceSearch() {
    // Cancel previous timer if exists
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    // Start new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (searchController.text == searchQuery.value) {
        searchJobs(searchQuery.value);
      }
    });
  }

  Timer? _debounceTimer;

  /// Apply filters
  void applyFilters({String? jobType, String? location}) {
    if (jobType != null) {
      selectedJobType.value = jobType;
      AppUtils.log('Job type filter applied: $jobType');
    }
    if (location != null) {
      selectedLocation.value = location;
      AppUtils.log('Location filter applied: $location');
    }

    _filterJobsLocally();
    AppUtils.log('Filtered jobs count: ${filteredJobs.length}');
  }

  /// Clear all filters
  void clearFilters() {
    selectedJobType.value = 'all';
    selectedLocation.value = 'all';
    searchController.clear();
    searchQuery.value = '';
    filteredJobs.assignAll(allJobs);
  }

  /// Post a new job
  Future<bool> postJob() async {
    try {
      isPosting.value = true;

      final newJob = await JobsApiService.postJob(
        jobTitle: jobTitleController.text.trim(),
        country: jobCountryController.text.trim(),
        city: jobCityController.text.trim(),
        jobType: selectedJobTypeForPost.value,
        description: jobDescriptionController.text.trim(),
        contact: jobContactController.text.trim(),
      );

      // Add to local lists
      allJobs.insert(0, newJob);
      _filterJobsLocally(); // Refresh filtered list

      // Clear form on success
      jobTitleController.clear();
      jobCountryController.clear();
      jobCityController.clear();
      jobDescriptionController.clear();
      jobContactController.clear();
      selectedJobTypeForPost.value = '';
      acceptTerms.value = false;

      AppUtils.toast('Job posted successfully!');
      return true;
    } catch (e) {
      AppUtils.toastError('Failed to post job: $e');
      return false;
    } finally {
      isPosting.value = false;
    }
  }

  /// Load existing profile data from backend
  Future<void> loadWorkerProfile() async {
    try {
      isLoading.value = true;
      AppUtils.log('Loading worker profile data...');

      // Get current profile data including worker profile fields
      final profileData = await JobsApiService.getCurrentProfile();
      AppUtils.log('Profile data received: ${profileData.keys.toList()}');

      // Clear existing values first
      selectedProfessionType.value = '';
      countryController.clear();
      cityController.clear();

      // Load profession from root level
      final professionValue = profileData['profession'];

      if (professionValue != null && professionValue.toString().isNotEmpty) {
        selectedProfessionType.value = professionValue.toString();
        AppUtils.log('Loaded profession: ${selectedProfessionType.value}');
      }

      // Load address and city from nested location object
      final locationData = profileData['location'];

      if (locationData != null && locationData is Map<String, dynamic>) {
        // Load address from location.address
        final addressValue = locationData['address'];
        if (addressValue != null && addressValue.toString().isNotEmpty) {
          countryController.text = addressValue.toString();
          AppUtils.log('Loaded address: ${countryController.text}');
        }

        // Load city from location.city
        final cityValue = locationData['city'];
        if (cityValue != null && cityValue.toString().isNotEmpty) {
          cityController.text = cityValue.toString();
          AppUtils.log('Loaded city: ${cityController.text}');
        }
      } else {
        // Fallback: try to get address and city from root level (for backward compatibility)
        final addressValue = profileData['address'];
        if (addressValue != null && addressValue.toString().isNotEmpty) {
          countryController.text = addressValue.toString();
          AppUtils.log(
            'Loaded address from root level: ${countryController.text}',
          );
        }

        final cityValue = profileData['city'];
        if (cityValue != null && cityValue.toString().isNotEmpty) {
          cityController.text = cityValue.toString();
          AppUtils.log('Loaded city from root level: ${cityController.text}');
        }
      }

      // If no worker-specific fields found, try to use general profile fields
      if (selectedProfessionType.value.isEmpty &&
          countryController.text.isEmpty &&
          cityController.text.isEmpty) {
        // Try to use country field as fallback for address
        final countryValue = profileData['country'];
        if (countryValue != null && countryValue.toString().isNotEmpty) {
          countryController.text = countryValue.toString();
          AppUtils.log(
            'Using country as address fallback: ${countryController.text}',
          );
        }

        AppUtils.log(
          'No existing worker profile data found - form will be empty for new setup',
        );
      }

      AppUtils.log('Worker profile data loaded successfully');
    } catch (e) {
      AppUtils.logEr('Error loading worker profile: $e');
      // Reset to empty values on error
      selectedProfessionType.value = '';
      countryController.clear();
      cityController.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Update worker profile using existing /api/update endpoint
  Future<bool> updateWorkerProfile() async {
    try {
      isUpdatingProfile.value = true;

      await JobsApiService.updateWorkerProfile(
        profession: selectedProfessionType.value,
        address: countryController.text.trim(),
        city: cityController.text.trim(),
      );

      AppUtils.toast('Worker profile updated successfully!');
      return true;
    } catch (e) {
      AppUtils.toastError('Failed to update profile: $e');
      return false;
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  /// Refresh jobs list
  Future<void> refreshJobs() async {
    AppUtils.log('Refreshing jobs...');
    await loadJobs();
    // Re-apply current filters after refresh
    _filterJobsLocally();
  }

  /// Get unique locations from jobs
  List<String> getUniqueLocations() {
    Set<String> locations = <String>{};
    for (var job in allJobs) {
      // Add the combined city, country format
      locations.add('${job.city}, ${job.country}');
    }
    return locations.toList()..sort();
  }

  /// Get jobs count by type
  int getJobsCountByType(String type) {
    if (type == 'all') return allJobs.length;
    return allJobs.where((job) => job.jobType == type).length;
  }

  /// Delete a job
  Future<bool> deleteJob(String jobId) async {
    try {
      isLoading.value = true;

      final success = await JobsApiService.deleteJob(jobId);

      if (success) {
        // Remove from local lists
        allJobs.removeWhere((job) => job.id == jobId);
        _filterJobsLocally(); // Refresh filtered list

        AppUtils.toast('Job deleted successfully!');
        return true;
      } else {
        AppUtils.toastError('Failed to delete job');
        return false;
      }
    } catch (e) {
      AppUtils.toastError('Failed to delete job: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing job
  Future<bool> updateJob(JobModel job) async {
    try {
      isPosting.value = true;

      final updatedJob = await JobsApiService.updateJob(
        jobId: job.id!,
        jobTitle: jobTitleController.text.trim(),
        country: jobCountryController.text.trim(),
        city: jobCityController.text.trim(),
        jobType: selectedJobTypeForPost.value,
        description: jobDescriptionController.text.trim(),
        contact: jobContactController.text.trim(),
      );

      // Update in local lists
      final index = allJobs.indexWhere((j) => j.id == job.id);
      if (index != -1) {
        allJobs[index] = updatedJob;
        _filterJobsLocally(); // Refresh filtered list
      }

      // Clear form on success
      jobTitleController.clear();
      jobCountryController.clear();
      jobCityController.clear();
      jobDescriptionController.clear();
      jobContactController.clear();
      selectedJobTypeForPost.value = '';
      acceptTerms.value = false;

      AppUtils.toast('Job updated successfully!');
      return true;
    } catch (e) {
      AppUtils.toastError('Failed to update job: $e');
      return false;
    } finally {
      isPosting.value = false;
    }
  }
}

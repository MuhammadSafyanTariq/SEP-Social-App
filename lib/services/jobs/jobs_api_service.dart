import 'package:sep/feature/data/models/dataModels/job_model/job_model.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';

class JobsApiService {
  static final IApiMethod _apiMethod = IApiMethod();
  static const String _updateProfilePath = '/api/update';

  /// Get all jobs or search jobs
  static Future<List<JobModel>> getJobs({String? searchQuery}) async {
    try {
      Map<String, String>? query;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = {'search': searchQuery};
      }

      AppUtils.log('Fetching jobs from: ${Urls.appApiBaseUrl}${Urls.jobs}');

      final response = await _apiMethod.get(
        url: Urls.jobs, // /api/jobs
        query: query,
        authToken: Preferences.authToken,
        headers: {},
      );

      if (response.isSuccess && response.data != null) {
        AppUtils.log('Jobs fetched successfully: ${response.data}');

        final responseData = response.data!;

        // Handle standardized response structure
        if (responseData['status'] == true && responseData['data'] is List) {
          final jobsData = responseData['data'] as List<dynamic>;
          return jobsData.map((json) => JobModel.fromJson(json)).toList();
        }

        // Fallback: Handle different response structures
        List<dynamic> jobsData = [];

        if (response.data?['data'] is List) {
          jobsData = response.data?['data'] as List<dynamic>;
        } else if (response.data?['jobs'] is List) {
          jobsData = response.data?['jobs'] as List<dynamic>;
        } else if (response.data is List) {
          jobsData = response.data as List<dynamic>;
        }

        return jobsData.map((json) => JobModel.fromJson(json)).toList();
      } else {
        throw Exception(
          response.getError?.toString() ?? 'Failed to fetch jobs',
        );
      }
    } catch (e) {
      AppUtils.logEr('Error fetching jobs: $e');
      return _getSampleJobs();
    }
  }

  /// Get sample jobs for testing when API is not available
  static List<JobModel> _getSampleJobs() {
    return [
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
    ];
  }

  /// Post a new job
  static Future<JobModel> postJob({
    required String jobTitle,
    required String country,
    required String city,
    required String jobType,
    required String description,
    required String contact,
  }) async {
    try {
      final requestBody = {
        'jobTitle': jobTitle,
        'country': country,
        'city': city,
        'jobType': jobType,
        'description': description,
        'contact': contact,
      };

      // Try different possible endpoints for job posting
      List<String> endpointsToTry = [
        '/api/jobs/create', // Most common pattern
        '/api/job/create', // Singular version
        '/api/job', // Simple singular
        '/api/createJob', // Alternative pattern
        '/api/jobs', // Original endpoint (already failed but keeping for completeness)
      ];

      Exception? lastException;

      for (String endpoint in endpointsToTry) {
        try {
          AppUtils.log(
            'Trying to post job to endpoint: ${Urls.appApiBaseUrl}$endpoint',
          );

          final response = await _apiMethod.post(
            url: endpoint,
            body: requestBody,
            authToken: Preferences.authToken,
            headers: {},
          );

          if (response.isSuccess && response.data != null) {
            // Check for specific success indicators
            final responseData = response.data!;
            final bool isSuccessful =
                responseData['status'] == true &&
                (responseData['code'] == 200 || responseData['code'] == 201);

            if (isSuccessful && responseData['data'] is Map) {
              AppUtils.log(
                'Job posted successfully to $endpoint: ${responseData['message']}',
              );

              final jobData = responseData['data'] as Map<String, dynamic>;
              return JobModel.fromJson(jobData);
            } else {
              AppUtils.log(
                'Unexpected response format from $endpoint: ${response.data}',
              );
              continue;
            }
          } else {
            AppUtils.log('Endpoint $endpoint failed with: ${response.data}');
            continue;
          }
        } catch (e) {
          AppUtils.log('Endpoint $endpoint failed with exception: $e');
          lastException = Exception('$endpoint failed: $e');
          continue;
        }
      }

      // If all endpoints fail, throw the last exception or a generic one
      final errorMessage =
          lastException?.toString() ??
          'All job posting endpoints failed. The backend might not have implemented job creation endpoints yet.';
      AppUtils.logEr('Job posting failed: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      AppUtils.logEr('Error posting job: $e');
      rethrow;
    }
  }

  /// Get current user profile (including worker profile fields)
  static Future<Map<String, dynamic>> getCurrentProfile() async {
    try {
      final response = await _apiMethod.get(
        url: '/api/getUser',
        authToken: Preferences.authToken,
        headers: {},
      );

      if (response.isSuccess && response.data != null) {
        return response.data?['data'] ?? {};
      } else {
        throw Exception(
          response.getError?.toString() ?? 'Failed to get profile',
        );
      }
    } catch (e) {
      AppUtils.logEr('Error getting current profile: $e');
      rethrow;
    }
  }

  /// Update user profile with profession, address, and city
  static Future<Map<String, dynamic>> updateWorkerProfile({
    required String profession,
    required String address,
    required String city,
  }) async {
    try {
      final requestBody = {
        'profession': profession,
        'location': {
          'address': address,
          'city': city,
          'lat': null, // Always pass null for latitude
          'lng': null, // Always pass null for longitude
        },
      };

      AppUtils.log('Updating worker profile with data: $requestBody');

      final response = await _apiMethod.put(
        url: _updateProfilePath,
        body: requestBody,
        authToken: Preferences.authToken,
        headers: {},
      );

      if (response.isSuccess && response.data != null) {
        AppUtils.log('Worker profile updated successfully: ${response.data}');
        return response.data?['data'] ?? {};
      } else {
        AppUtils.logEr('Failed to update worker profile: ${response.data}');
        throw Exception(
          response.getError?.toString() ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      AppUtils.logEr('Error updating worker profile: $e');
      rethrow;
    }
  }
}

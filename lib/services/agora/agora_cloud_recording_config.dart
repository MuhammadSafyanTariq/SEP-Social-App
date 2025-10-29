import 'dart:convert';

/// Agora Cloud Recording Configuration
///
/// SECURITY WARNING:
/// These credentials are visible in the compiled app. For production:
/// 1. Use environment variables or secure storage
/// 2. Implement a backend proxy for API calls
/// 3. Consider using Firebase Remote Config for credential management

class AgoraCloudRecordingConfig {
  // Your Agora App ID (already public in urls.dart)
  static const String appId = '1d34f3c04fe748049d660e3b23206f7a';

  // TODO: Replace with your actual Agora credentials from console.agora.io
  // Go to: Console -> Project -> RESTful API
  static const String customerId = 'YOUR_CUSTOMER_ID_HERE';
  static const String customerSecret = 'YOUR_CUSTOMER_SECRET_HERE';

  // Cloud Storage Configuration
  // Configure this in Agora Console -> Cloud Recording -> Configuration
  static const CloudStorageConfig storageConfig = CloudStorageConfig(
    vendor: CloudStorageVendor.aws, // Change based on your storage
    region: 0, // Your storage region
    bucket: 'YOUR_BUCKET_NAME', // Your S3/Azure/GCS bucket name
    accessKey: 'YOUR_ACCESS_KEY',
    secretKey: 'YOUR_SECRET_KEY',
  );

  // Validate configuration
  static bool get isConfigured {
    return customerId != 'YOUR_CUSTOMER_ID_HERE' &&
        customerSecret != 'YOUR_CUSTOMER_SECRET_HERE' &&
        storageConfig.bucket != 'YOUR_BUCKET_NAME';
  }

  // Get Basic Auth header
  static String get basicAuth {
    final credentials = '$customerId:$customerSecret';
    final bytes = credentials.codeUnits;
    final base64Str = base64Encode(bytes);
    return 'Basic $base64Str';
  }
}

/// Cloud Storage Vendors supported by Agora
enum CloudStorageVendor {
  qiniu(0),
  aws(1),
  alibabaCloud(2),
  tencentCloud(3),
  kingsoftCloud(4),
  azure(5),
  googleCloud(6),
  huaweiCloud(7);

  final int value;
  const CloudStorageVendor(this.value);
}

/// Cloud Storage Configuration
class CloudStorageConfig {
  final CloudStorageVendor vendor;
  final int region;
  final String bucket;
  final String accessKey;
  final String secretKey;

  const CloudStorageConfig({
    required this.vendor,
    required this.region,
    required this.bucket,
    required this.accessKey,
    required this.secretKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendor': vendor.value,
      'region': region,
      'bucket': bucket,
      'accessKey': accessKey,
      'secretKey': secretKey,
      'fileNamePrefix': ['recordings'],
    };
  }
}

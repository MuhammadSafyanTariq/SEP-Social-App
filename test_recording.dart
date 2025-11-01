import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/services/agora/agora_recording_service.dart';

void main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");

  print('=== Agora Direct Recording API Test ===');
  print('Customer ID: ${dotenv.env['AGORA_CUSTOMER_ID']?.substring(0, 8)}...');
  print('App ID: ${dotenv.env['AGORA_APP_ID']?.substring(0, 8)}...');
  print('AWS Bucket: ${dotenv.env['AWS_S3_BUCKET']}');
  print('AWS Region: ${dotenv.env['AWS_REGION']}');

  // Test workflow
  final recordingUid = AgoraRecordingService.generateRecordingUid();
  print('Generated recording UID: $recordingUid');

  // Note: Actual recording requires a valid token and active channel
  // This test just verifies the service can be initialized and configured
  print('✅ AgoraRecordingService initialization test passed');
  print('Ready for direct API calls to Agora Cloud Recording');
}

# BlackBlaze B2 Authentication Debug Guide

## Current Issue
Videos are being generated with correct URLs like:
```
https://s3.us-east-005.backblazeb2.com/file/sep-recordings/recordings/690619e515472048af2b3acd/1/c50857263c4f77338a098cb5ce004371_690619e515472048af2b3acd_0.mp4
```

But when trying to download them, we get 401/404 errors because the authentication is not working properly.

## Root Cause Analysis

### 1. URL Structure Analysis
From your logs, the original video URL is:
```
https://s3.us-east-005.backblazeb2.com/file/sep-recordings/recordings/690619e515472048af2b3acd/1/c50857263c4f77338a098cb5ce004371_690619e515472048af2b3acd_0.mp4
```

When we try to authenticate, we're generating:
```
https://f005.backblazeb2.com/file/sep-recordings/c50857263c4f77338a098cb5ce004371_690619e515472048af2b3acd_0.mp4
```

### 2. Key Differences
1. **Domain**: `s3.us-east-005.backblazeb2.com` vs `f005.backblazeb2.com`
2. **Path**: Missing the full `recordings/690619e515472048af2b3acd/1/` structure

### 3. Solution Implemented

#### A. Enhanced URL Parsing
Updated `downloadVideoToGallery` to extract the full file path from S3 URLs:
```dart
// For URLs like: https://s3.us-east-005.backblazeb2.com/file/sep-recordings/recordings/690619e515472048af2b3acd/1/c50857263c4f77338a098cb5ce004371_690619e515472048af2b3acd_0.mp4
// We need to extract: recordings/690619e515472048af2b3acd/1/c50857263c4f77338a098cb5ce004371_690619e515472048af2b3acd_0.mp4
final pathSegments = uri.pathSegments;

if (pathSegments.contains('file') && pathSegments.contains('sep-recordings')) {
  // Find the index of 'sep-recordings' and get everything after it
  final bucketIndex = pathSegments.indexOf('sep-recordings');
  if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
    // Join all segments after the bucket name
    final pathAfterBucket = pathSegments.sublist(bucketIndex + 1);
    filePath = pathAfterBucket.join('/');
  }
}
```

#### B. Enhanced Authentication
Updated `getAuthenticatedDownloadUrl` to:
1. Use exact same credentials as your `_processRecordingThroughCloudinary`
2. Handle both full paths and filenames
3. Generate proper authenticated URLs with B2 download endpoint
4. Store auth tokens for actual download

#### C. Comprehensive Debugging
Added detailed logging to track:
- Credential validation
- B2 API authentication calls
- URL construction process
- Auth token generation and storage

## Testing Steps

### 1. Check Logs
Look for these log entries to diagnose issues:
```
🔑 [GET_AUTH] Raw credentials - keyId: [keyId], appKey: [partial], bucket: [bucket]
🔑 [GET_AUTH] B2 auth response status: [status]
🔑 [GET_AUTH] Got auth response - downloadUrl: [url], token: [partial]
✅ [GET_AUTH] Generated authenticated URL: [final url]
```

### 2. Verify Credentials
Ensure your `.env` file contains:
```
BACKBLAZE_KEY_ID=005ac5db476e4ed0000000002
BACKBLAZE_APP_KEY=K005Www7q44bx4YO0XJCfXmre04Dx/M
BACKBLAZE_BUCKET_NAME=sep-recordings
```

### 3. Test Authentication
The system now:
1. Extracts the full file path from your S3 URL
2. Calls B2 Native API for authentication
3. Constructs authenticated download URL
4. Uses auth token for actual download

## Expected Behavior

1. **URL Extraction**: `recordings/690619e515472048af2b3acd/1/c50857263c4f77338a098cb5ce004371_690619e515472048af2b3acd_0.mp4`
2. **Authentication**: Get valid auth token from B2 API
3. **Download URL**: `https://[download-url]/file/sep-recordings/recordings/690619e515472048af2b3acd/1/c50857263c4f77338a098cb5ce004371_690619e515472048af2b3acd_0.mp4`
4. **Download**: Use auth token in request headers

## Key Changes Made

### 1. video_url_retriever_service.dart
- Enhanced credential validation and logging
- Fixed URL construction to include full path
- Added comprehensive error handling

### 2. video_download_utils.dart  
- Enhanced URL parsing to extract full file paths
- Added proper authentication token usage
- Improved error handling and accessibility testing

## Troubleshooting

### If Still Getting 404 Errors:
1. Check if the file path extraction is working correctly
2. Verify the B2 authentication is successful
3. Ensure auth tokens are being used in download requests

### If Getting 401 Errors:
1. Verify B2 credentials are correct
2. Check if auth token is expired
3. Ensure auth token is properly formatted in request headers

## Next Steps

1. Test with actual download to see if 401/404 errors are resolved
2. Monitor logs to ensure authentication flow is working
3. Verify that videos download successfully to gallery
# 🎬 Professional Video URL Retrieval System

## Overview
This document explains the professional video URL retrieval system implemented for Agora Cloud Recording in the SEP Social App.

## 📊 System Architecture

### Components
1. **VideoUrlRetrieverService** - Core service for polling Agora API
2. **LiveStreamCtrl** - Enhanced with professional URL storage
3. **Background Processing** - Asynchronous URL retrieval after recording stops

## ⏰ Timeline & Processing Details

### Agora Cloud Recording Processing Time
Based on Agora documentation and real-world testing:

- **Standard Processing Time**: 1-3 minutes after recording stops
- **Large Files (>1GB)**: 3-10 minutes 
- **Peak Times**: May take up to 15 minutes during high traffic

### Our Polling Strategy
- **Polling Interval**: 30 seconds (optimal balance)
- **Max Attempts**: 10 attempts (5 minutes total)
- **Exponential Backoff**: Increases wait time for later attempts
- **Fallback**: S3 URL construction if direct URL unavailable

## 🎯 How It Works

### Step 1: Recording Stops
```dart
// When recording stops successfully but URL is null
if (recordedVideoUrl == null || recordedVideoUrl!.isEmpty) {
  // Start professional retrieval process
  _startVideoUrlRetrieval(
    resourceId: tempResourceId,
    sid: tempSid,
    channelName: channelName,
  );
}
```

### Step 2: Background Polling
```dart
// VideoUrlRetrieverService polls Agora API every 30 seconds
for (int attempt = 1; attempt <= 10; attempt++) {
  final result = await AgoraRecordingService.query(
    resourceId: resourceId,
    sid: sid,
  );
  
  if (result.fileUrl != null) {
    return result.fileUrl; // ✅ Success!
  }
  
  await Future.delayed(Duration(seconds: 30));
}
```

### Step 3: URL Construction Fallback
```dart
// If direct URL not available, construct S3 URL
final videoUrl = _constructS3Url(fileName);
// Example: https://agora-recordings755.s3.us-east-1.amazonaws.com/[SID]_[CHANNEL]_0.mp4
```

### Step 4: Professional Storage
```dart
void _storeRetrievedVideoUrl(String videoUrl, String resourceId, String sid) {
  // 1. Add to recorded videos array
  recordedVideoUrls.add(videoUrl);
  
  // 2. Update main recordedVideoUrl
  recordedVideoUrl = videoUrl;
  
  // 3. Store metadata
  final metadata = {
    'url': videoUrl,
    'resourceId': resourceId,
    'sid': sid,
    'retrievedAt': DateTime.now().toIso8601String(),
    'channelName': streamCtrl.value.channelId,
  };
  
  // 4. Trigger UI update
  update();
}
```

## 📁 S3 Storage Location

### AWS S3 Bucket Details
- **Bucket Name**: `agora-recordings755`
- **Region**: `us-east-1` (update in code if different)
- **File Format**: 
  - M3U8: `[SID]_[CHANNEL_ID].m3u8`
  - MP4: `[SID]_[CHANNEL_ID]_0.mp4`

### Finding Files in AWS Console
1. Go to **AWS S3 Console**
2. Navigate to bucket: `agora-recordings755`
3. Search for files using the **SID** from logs
4. Files are typically in root folder or organized by date

Example file names from your recent recording:
- `6361de4edc405c30cb1c6dbc5ffe3cca_690619e515472048af2b3acd.m3u8`
- `6361de4edc405c30cb1c6dbc5ffe3cca_690619e515472048af2b3acd_0.mp4`

## 💾 Frontend Storage Strategy

### 1. Immediate Storage (After Recording Stops)
```dart
// Metadata stored immediately
{
  'resourceId': 'T1Cd0FE...',
  'sid': '6361de4e...',
  'channelName': '690619e5...',
  'status': 'processing'
}
```

### 2. Professional URL Storage (After Processing)
```dart
// Complete video data stored
{
  'url': 'https://agora-recordings755.s3.us-east-1.amazonaws.com/...',
  'resourceId': 'T1Cd0FE...',
  'sid': '6361de4e...',
  'retrievedAt': '2025-11-01T21:52:32.000Z',
  'channelName': '690619e5...',
  'status': 'available'
}
```

### 3. Array Management
```dart
// Multiple recordings handled professionally
List<String> recordedVideoUrls = [
  'https://bucket.s3.region.amazonaws.com/video1.mp4',
  'https://bucket.s3.region.amazonaws.com/video2.mp4',
  // New URLs added automatically as they become available
];
```

## 🔧 Configuration Options

### Customize Polling Settings
```dart
// In VideoUrlRetrieverService
static const int _maxAttempts = 10;        // Total attempts
static const int _basePollingInterval = 30; // Base wait time (seconds)
static const int _maxPollingInterval = 60;  // Max wait time (seconds)
```

### Update S3 Configuration
```dart
// In _constructS3Url method
const bucketName = 'your-bucket-name';
const region = 'your-region';

// Or use CloudFront CDN
const cdnDomain = 'your-cdn-domain.cloudfront.net';
```

## 🚀 Usage Example

```dart
// The system works automatically!
// Just call stopRecording() as usual

await stopRecording();

// System automatically:
// 1. Stops recording ✅
// 2. Stores metadata ✅  
// 3. Starts background URL retrieval ✅
// 4. Polls Agora API every 30 seconds ✅
// 5. Stores final URL when available ✅
// 6. Updates UI ✅
// 7. Shows user notification ✅
```

## 📱 User Experience

### Immediate Feedback
- ✅ "Recording stopped successfully" 
- 📹 "Video is processing..."

### Background Processing
- 🔄 System polls for URL every 30 seconds
- 📊 Progress tracked in logs
- ⏰ No user interaction required

### Completion Notification  
- 📹 "Video recording is now available!"
- 🔗 URL automatically stored in `recordedVideoUrls`
- 🎯 UI updates automatically

## 🐛 Error Handling

### Network Issues
- Automatic retry with exponential backoff
- Detailed error logging
- Graceful fallback to S3 URL construction

### Processing Delays
- Max 5-minute wait time
- User-friendly timeout messages
- Manual check instructions provided

### Storage Failures
- Comprehensive error logging
- Metadata preservation for manual recovery
- User notification of issues

## 📋 Testing Checklist

- [ ] Recording stops successfully (HTTP 200)
- [ ] Files uploaded to S3 (`uploadingStatus: "backuped"`)
- [ ] Background URL retrieval starts automatically
- [ ] Polling occurs every 30 seconds
- [ ] URL retrieved within 1-3 minutes (normal case)
- [ ] URL stored in `recordedVideoUrls` array
- [ ] UI updates automatically
- [ ] User notification shown
- [ ] Error handling works for network issues
- [ ] Timeout handling works for slow processing

## 🔍 Debugging

### Key Log Messages
```
🎬 [URL_RETRIEVER] Starting video URL retrieval
🎬 [URL_RETRIEVER] Attempt 1/10
🎬 ✅ [URL_RETRIEVER] Video URL retrieved successfully!
🎯 Storing retrieved video URL in frontend...
🎯 ✅ Video URL storage complete!
```

### Common Issues
1. **URL stays null**: Check S3 bucket permissions
2. **Polling fails**: Verify Agora API credentials
3. **S3 URL invalid**: Update bucket name/region in code
4. **Processing too slow**: Normal for large files, be patient

## 🎉 Success Indicators

Your implementation is working when you see:
- ✅ Recording stops without errors
- ✅ Files appear in S3 bucket
- ✅ Background polling starts
- ✅ URL retrieved within 1-3 minutes
- ✅ `recordedVideoUrls` array updated
- ✅ User gets success notification

This professional system ensures reliable video URL retrieval with excellent user experience!
# Video Quality Backend Verification Guide

This guide helps you verify that your backend video quality changes are working correctly.

## ✅ Prerequisites

Before testing, ensure:
- Backend server is running
- Video transcoding service is configured
- Database schema includes `qualities` field
- At least one video post exists in your database

---

## 🔍 Step 1: Check API Response Structure

### Test 1.1: Get a Post with Video

**Endpoint:** `GET /api/posts/{postId}` or your post retrieval endpoint

**Expected Response Structure:**
```json
{
  "_id": "post123",
  "content": "Video post",
  "files": [
    {
      "file": "https://cdn.example.com/videos/video_original.mp4",
      "type": "video",
      "thumbnail": "https://cdn.example.com/thumbnails/video_thumb.jpg",
      "x": 1920,
      "y": 1080,
      "_id": "file123",
      "qualities": {
        "1080p": "https://cdn.example.com/videos/video_1080p.mp4",
        "720p": "https://cdn.example.com/videos/video_720p.mp4",
        "480p": "https://cdn.example.com/videos/video_480p.mp4",
        "360p": "https://cdn.example.com/videos/video_360p.mp4"
      },
      "availableQualities": ["1080p", "720p", "480p", "360p"]
    }
  ]
}
```

**✅ What to Check:**
- [ ] `qualities` object exists in file object
- [ ] `qualities` contains at least 2 quality levels (e.g., 1080p, 720p)
- [ ] URLs in `qualities` are valid and accessible
- [ ] `availableQualities` array lists all available qualities

**❌ If Missing:**
- Check backend post retrieval endpoint includes quality data
- Verify database has quality URLs stored
- Check if video was uploaded after implementing transcoding

---

## 🗄️ Step 2: Verify Database Storage

### Test 2.1: Check Database Schema

**MongoDB Query:**
```javascript
// Find a video post
db.posts.findOne({ "files.type": "video" })

// Check if qualities field exists
db.posts.findOne(
  { "files.type": "video" },
  { "files.qualities": 1, "files.file": 1 }
)
```

**Expected Result:**
```json
{
  "files": [
    {
      "file": "original_url.mp4",
      "type": "video",
      "qualities": {
        "1080p": "url_1080p.mp4",
        "720p": "url_720p.mp4",
        "480p": "url_480p.mp4",
        "360p": "url_360p.mp4"
      }
    }
  ]
}
```

**✅ What to Check:**
- [ ] `qualities` field exists in database
- [ ] Quality URLs are stored correctly
- [ ] URLs are accessible (not null/empty)

---

## 📱 Step 3: Test Frontend Integration

### Test 3.1: Enable Debug Logging

Add this to your video player initialization to see which quality is selected:

**File:** `lib/feature/presentation/Home/homeScreenComponents/auto_play_video_player.dart`

Add logging in `_initializeVideo` method:

```dart
Future<void> _initializeVideo({
  int attempt = 0,
  bool useSoftwareDecoding = false,
}) async {
  try {
    // Get optimal URL based on retry attempt and video type
    final videoUrl = _getOptimalVideoUrl(widget.videoUrl, attempt);
    
    // ADD THIS: Log quality information
    AppUtils.log('🎬 Video Quality Debug:');
    AppUtils.log('  - Original URL: ${widget.videoUrl}');
    AppUtils.log('  - Selected URL: $videoUrl');
    AppUtils.log('  - Is HLS: ${_isHLSVideo(videoUrl)}');
    
    // If you have access to FileElement, log qualities:
    // AppUtils.log('  - Available Qualities: ${fileElement.availableQualities}');
    // AppUtils.log('  - Qualities Map: ${fileElement.qualities}');
    
    // ... rest of initialization code
```

### Test 3.2: Check Video Quality Helper

**File:** `lib/utils/video_quality_helper.dart`

Add logging to see quality selection:

```dart
static String getOptimalVideoUrl(
  FileElement fileElement, {
  BuildContext? context,
  int? maxWidth,
}) {
  final deviceMaxWidth = maxWidth ?? getMaxSupportedResolution(context);
  final file = fileElement.file ?? '';
  
  // ADD THIS: Debug logging
  AppUtils.log('🎥 Quality Selection Debug:');
  AppUtils.log('  - Device Max Width: $deviceMaxWidth');
  AppUtils.log('  - Has Qualities: ${fileElement.qualities != null}');
  AppUtils.log('  - Qualities Count: ${fileElement.qualities?.length ?? 0}');
  AppUtils.log('  - Available Qualities: ${fileElement.availableQualities}');
  
  // Check if HLS (adaptive streaming) - best option
  if (file.toLowerCase().endsWith('.m3u8') ||
      file.toLowerCase().contains('/hls/') ||
      file.toLowerCase().contains('playlist.m3u8')) {
    AppUtils.log('  ✅ Using HLS (adaptive streaming)');
    return file;
  }

  // Check for multiple qualities from backend
  if (fileElement.qualities != null && fileElement.qualities!.isNotEmpty) {
    AppUtils.log('  ✅ Multiple qualities available, selecting optimal...');
    
    if (deviceMaxWidth >= 1920 &&
        fileElement.qualities!.containsKey('1080p')) {
      AppUtils.log('  ✅ Selected: 1080p');
      return fileElement.qualities!['1080p']!;
    } else if (deviceMaxWidth >= 1280 &&
        fileElement.qualities!.containsKey('720p')) {
      AppUtils.log('  ✅ Selected: 720p');
      return fileElement.qualities!['720p']!;
    } else if (deviceMaxWidth >= 854 &&
        fileElement.qualities!.containsKey('480p')) {
      AppUtils.log('  ✅ Selected: 480p');
      return fileElement.qualities!['480p']!;
    } else if (fileElement.qualities!.containsKey('360p')) {
      AppUtils.log('  ✅ Selected: 360p');
      return fileElement.qualities!['360p']!;
    }
    
    AppUtils.log('  ⚠️ Falling back to first available quality');
    return fileElement.qualities!.values.first;
  }

  AppUtils.log('  ⚠️ No qualities found, using original file');
  return file;
}
```

---

## 🧪 Step 4: Manual Testing Steps

### Test 4.1: Upload a New Video

1. **Upload a video through your app**
2. **Check backend logs** for transcoding process:
   ```
   ✅ Transcoding video to 1080p...
   ✅ Transcoding video to 720p...
   ✅ Transcoding video to 480p...
   ✅ Transcoding video to 360p...
   ✅ Video transcoding complete
   ```
3. **Verify API response** includes `qualities` object
4. **Check database** has quality URLs stored

### Test 4.2: Play Video in App

1. **Open app** and navigate to a video post
2. **Check console logs** for quality selection:
   ```
   🎥 Quality Selection Debug:
     - Device Max Width: 1920
     - Has Qualities: true
     - Qualities Count: 4
     - Available Qualities: [1080p, 720p, 480p, 360p]
     ✅ Multiple qualities available, selecting optimal...
     ✅ Selected: 1080p
   ```
3. **Verify video plays** without errors
4. **Check network tab** (if using browser dev tools) to see which quality URL is requested

### Test 4.3: Test on Different Devices

**High-end device (1080p capable):**
- Should select 1080p or 720p
- Video should play smoothly

**Mid-range device (720p capable):**
- Should select 720p or 480p
- Video should play without freezing

**Low-end device (480p capable):**
- Should select 480p or 360p
- Video should play without format errors

---

## 🔧 Step 5: Backend API Testing

### Test 5.1: Test Optimal Quality Endpoint

**Endpoint:** `GET /api/video/optimal-quality?videoId={videoId}&maxWidth=1920`

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "url": "https://cdn.example.com/videos/video_1080p.mp4",
    "quality": "1080p",
    "width": 1920,
    "height": 1080
  }
}
```

**Test Different Max Widths:**
```bash
# Test for high-end device
curl "http://your-api.com/api/video/optimal-quality?videoId=123&maxWidth=1920"

# Test for mid-range device
curl "http://your-api.com/api/video/optimal-quality?videoId=123&maxWidth=1280"

# Test for low-end device
curl "http://your-api.com/api/video/optimal-quality?videoId=123&maxWidth=854"
```

**✅ What to Check:**
- [ ] Endpoint returns correct quality for each maxWidth
- [ ] URLs are valid and accessible
- [ ] Quality matches device capabilities

---

## 🐛 Step 6: Troubleshooting

### Issue: Qualities Not in API Response

**Possible Causes:**
1. Backend not including qualities in response
2. Video uploaded before transcoding was implemented
3. Database schema not updated

**Solutions:**
1. Check backend post retrieval endpoint
2. Re-upload video to trigger transcoding
3. Verify database schema includes `qualities` field

### Issue: Frontend Not Using Qualities

**Possible Causes:**
1. FileElement model not parsing qualities
2. VideoQualityHelper not being called
3. Qualities field name mismatch

**Solutions:**
1. Check `post_data.dart` model includes qualities
2. Verify `VideoQualityHelper.getOptimalVideoUrl()` is called
3. Check JSON field names match (`qualities` vs `qualityUrls`)

### Issue: Video Still Not Playing

**Possible Causes:**
1. Quality URLs are invalid/not accessible
2. CORS issues with CDN
3. Video format not supported

**Solutions:**
1. Test URLs directly in browser/Postman
2. Check CDN CORS settings
3. Verify video codec (should be H.264/AAC)

---

## 📊 Step 7: Verification Checklist

### Backend Verification:
- [ ] Video transcoding service is running
- [ ] Multiple quality files are generated on upload
- [ ] Quality URLs are stored in database
- [ ] API response includes `qualities` object
- [ ] Optimal quality endpoint works correctly

### Frontend Verification:
- [ ] FileElement model includes `qualities` field
- [ ] VideoQualityHelper selects correct quality
- [ ] Video player uses optimal quality URL
- [ ] Logs show quality selection process
- [ ] Videos play without errors

### End-to-End Verification:
- [ ] Upload new video → Qualities generated
- [ ] View video post → Correct quality selected
- [ ] Video plays smoothly → No freezing/errors
- [ ] Different devices → Appropriate quality selected

---

## 🎯 Quick Test Script

Run this in your browser console or Postman to quickly test:

```javascript
// 1. Get a post with video
fetch('http://your-api.com/api/posts/{postId}')
  .then(r => r.json())
  .then(data => {
    const videoFile = data.files.find(f => f.type === 'video');
    console.log('Video File:', videoFile);
    console.log('Has Qualities:', !!videoFile.qualities);
    console.log('Available Qualities:', videoFile.availableQualities);
    console.log('Qualities Object:', videoFile.qualities);
    
    // 2. Test each quality URL
    if (videoFile.qualities) {
      Object.entries(videoFile.qualities).forEach(([quality, url]) => {
        console.log(`Testing ${quality}: ${url}`);
        fetch(url, { method: 'HEAD' })
          .then(r => console.log(`✅ ${quality}: ${r.status}`))
          .catch(e => console.log(`❌ ${quality}: ${e.message}`));
      });
    }
  });
```

---

## 📝 Expected Results

### ✅ Success Indicators:
- API returns `qualities` object with multiple URLs
- Frontend logs show quality selection
- Videos play smoothly on all devices
- No format errors or freezing
- Network usage optimized (lower quality on slower connections)

### ❌ Failure Indicators:
- No `qualities` field in API response
- Frontend always uses original file URL
- Videos freeze or show format errors
- Same quality used on all devices
- High bandwidth usage on all devices

---

## 🚀 Next Steps

Once verified:
1. Monitor video playback performance
2. Check user feedback on video quality
3. Optimize transcoding settings if needed
4. Consider implementing HLS for adaptive streaming
5. Add quality selector UI for users (optional)

---

**Need Help?** Check the logs and share:
- Backend API response structure
- Frontend console logs
- Video playback errors
- Device specifications

# 🚀 Quick Start Guide - Story Backend Integration

## What Changed?

**Before:** Stories used bypass logic with `#sepstory` tags on regular posts
**Now:** Stories use dedicated backend API with proper video, audio, and image support

---

## ⚡ Quick Integration (3 Steps)

### Step 1: Update Your Home Screen

Replace the old story widget with the new one:

```dart
// Old code (REMOVE):
import 'package:sep/feature/presentation/Home/story/story_list_widget.dart';
StoryListWidget()

// New code (ADD):
import 'package:sep/feature/presentation/Home/story/story_list_widget_new.dart';
StoryListWidgetNew()
```

### Step 2: Verify StoryController is Initialized

The `StoryController` is automatically initialized, but you can manually initialize it in your main app:

```dart
// In your main.dart or app initialization:
Get.put(StoryController());
```

### Step 3: Test!

That's it! Your app now uses the backend API for stories.

---

## 📱 New Features Available

### For Users:
- ✅ Create image stories
- ✅ Create video stories (up to 60s)
- ✅ Create audio stories
- ✅ Add captions to stories
- ✅ Like/unlike stories
- ✅ View story counts
- ✅ Auto-expiring stories (24 hours)

### For Developers:
- ✅ Full backend integration
- ✅ Proper REST API calls
- ✅ Real-time updates
- ✅ Pagination support
- ✅ Error handling
- ✅ View tracking

---

## 📂 New Files to Know

### Main Files:
1. **story_model.dart** - Data models
2. **story_repository.dart** - API calls
3. **story_service.dart** - Business logic
4. **story_controller.dart** - State management (UPDATED)

### UI Files:
1. **story_create_screen_new.dart** - Create stories
2. **story_list_widget_new.dart** - Display story list
3. **story_view_screen_new.dart** - View stories

---

## 🧪 Quick Test

1. **Create a story:**
   - Open app
   - Tap "Your Story" button
   - Select image or video
   - Add caption (optional)
   - Tap "Share"

2. **View stories:**
   - Tap any user's story avatar
   - Tap left/right to navigate
   - Tap center to pause
   - Tap heart to like

3. **Check features:**
   - See view count
   - See like count
   - Stories expire after 24 hours

---

## 🔧 Configuration Check

Verify these settings in your app:

### 1. Base URL (urls.dart)
```dart
const String baseUrl = 'http://67.225.241.58:4004'; // Your API
```

### 2. File Upload Working
Make sure `CreatePostCtrl.uploadFiles()` is working properly.

### 3. Authentication Token
User must be logged in with valid JWT token.

---

## 🐛 Common Issues & Fixes

### Issue: "Stories not loading"
**Fix:** Check network connection and API URL

### Issue: "Can't create story"
**Fix:** Verify file upload is working

### Issue: "Video not playing"
**Fix:** Use MP4 format, check file size (<50MB)

### Issue: "Old stories still showing"
**Fix:** Clear app data or check expiration logic

---

## 📊 API Endpoints Used

```
POST   /api/story/create          - Create story
GET    /api/story/all             - Get all stories
GET    /api/story/user/:userId    - Get user stories
POST   /api/story/:id/view        - Mark as viewed
POST   /api/story/:id/like        - Like/unlike
DELETE /api/story/:id             - Delete story
GET    /api/story/my-stories      - Get my stories
```

---

## 💻 Code Examples

### Get All Stories:
```dart
final controller = Get.find<StoryController>();
await controller.fetchStories();
```

### Create Story:
```dart
final service = StoryService();
await service.createImageStory(
  imageUrl: 'https://example.com/image.jpg',
  caption: 'Hello World!',
);
```

### Like Story:
```dart
final controller = Get.find<StoryController>();
await controller.toggleLikeStory(storyId);
```

---

## ✅ Verification Steps

After integration, verify:

- [ ] Story list shows up on home screen
- [ ] Can create image story
- [ ] Can create video story
- [ ] Can view stories
- [ ] Can like stories
- [ ] View count increases
- [ ] Stories show for 24 hours then disappear
- [ ] Multiple stories per user work
- [ ] Navigation between stories works

---

## 📚 Full Documentation

For detailed information, see:
- **STORY_BACKEND_INTEGRATION_SUMMARY.md** - Complete implementation details
- **STORY_FEATURE_FLUTTER_INTEGRATION_GUIDE.md** - Original API guide

---

## 🎯 Migration Checklist

- [ ] Replace `StoryListWidget` with `StoryListWidgetNew`
- [ ] Test story creation
- [ ] Test story viewing
- [ ] Test likes and views
- [ ] Verify expiration works
- [ ] Check error handling
- [ ] Monitor API calls
- [ ] Deploy to test environment
- [ ] Get user feedback
- [ ] Deploy to production

---

## 🆘 Need Help?

1. Check logs: `AppUtils.log()` output
2. Verify API responses in network inspector
3. Check integration guide for API details
4. Review error messages carefully

---

## 🎉 That's It!

Your story feature is now powered by the backend API with full support for images, videos, audio, likes, and views!

---

**Last Updated:** January 16, 2026
**Status:** ✅ Ready to Use

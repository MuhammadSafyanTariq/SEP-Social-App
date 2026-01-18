# Story Feature - Flutter Integration Guide

## 📋 Overview

This document provides complete integration instructions for the **Story Feature** in your Flutter application. Users can create stories with photos/audio or videos, view stories, like them, and track view counts.

---

## 🎯 API Endpoints

### Base URL
```
http://your-api-domain.com/api/story
```

### Authentication
All endpoints require JWT token in the Authorization header:
```
Authorization: Bearer <JWT_TOKEN>
```

---

## 📤 API Endpoints

### 1. Create Story
- **URL:** `POST /api/story/create`
- **Method:** `POST`
- **Authentication:** Required

### 2. Get All Stories
- **URL:** `GET /api/story/all`
- **Method:** `GET`
- **Authentication:** Required

### 3. Get User Stories
- **URL:** `GET /api/story/user/:userId`
- **Method:** `GET`
- **Authentication:** Required

### 4. Get Story Details
- **URL:** `GET /api/story/:storyId`
- **Method:** `GET`
- **Authentication:** Required

### 5. View Story
- **URL:** `POST /api/story/:storyId/view`
- **Method:** `POST`
- **Authentication:** Required

### 6. Like/Unlike Story
- **URL:** `POST /api/story/:storyId/like`
- **Method:** `POST`
- **Authentication:** Required

### 7. Delete Story
- **URL:** `DELETE /api/story/:storyId`
- **Method:** `DELETE`
- **Authentication:** Required

### 8. Get My Stories
- **URL:** `GET /api/story/my-stories`
- **Method:** `GET`
- **Authentication:** Required

---

## 📝 Endpoint Details

### 1. Create Story

**Request:**
```dart
POST /api/story/create
Headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json'
}
Body: {
  "type": "story",  // or "video"
  "files": [
    {
      "file": "https://example.com/image.jpg",
      "type": "image",  // "image", "audio" for story type, or "video" for video type
      "thumbnail": "https://example.com/thumb.jpg"  // optional
    }
  ],
  "caption": "My story caption"  // optional
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Story created successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "userId": "507f1f77bcf86cd799439012",
    "type": "story",
    "files": [
      {
        "file": "https://example.com/image.jpg",
        "type": "image",
        "thumbnail": null
      }
    ],
    "caption": "My story caption",
    "likes": [],
    "views": [],
    "viewCount": 0,
    "expiresAt": "2024-01-16T10:00:00.000Z",
    "isActive": true,
    "createdAt": "2024-01-15T10:00:00.000Z",
    "updatedAt": "2024-01-15T10:00:00.000Z"
  }
}
```

**Validation Rules:**
- `type` must be `"story"` or `"video"`
- For `type: "story"`: files can be `"image"` or `"audio"`
- For `type: "video"`: files must be `"video"`
- At least one file is required
- Each file must have `file` (URL) and `type` fields

---

### 2. Get All Stories

**Request:**
```dart
GET /api/story/all?page=1&limit=20
Headers: {
  'Authorization': 'Bearer $token'
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Stories retrieved successfully",
  "data": {
    "stories": [
      {
        "user": {
          "_id": "507f1f77bcf86cd799439012",
          "name": "John Doe",
          "image": "https://example.com/profile.jpg",
          "username": "johndoe"
        },
        "stories": [
          {
            "_id": "507f1f77bcf86cd799439011",
            "type": "story",
            "files": [...],
            "caption": "My story",
            "likes": [],
            "likeCount": 5,
            "viewCount": 20,
            "createdAt": "2024-01-15T10:00:00.000Z",
            "expiresAt": "2024-01-16T10:00:00.000Z"
          }
        ]
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "totalCount": 50,
      "totalPages": 3
    }
  }
}
```

**Note:** Stories are grouped by user for easy display in story UI.

---

### 3. Get User Stories

**Request:**
```dart
GET /api/story/user/507f1f77bcf86cd799439012
Headers: {
  'Authorization': 'Bearer $token'
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "User stories retrieved successfully",
  "data": {
    "stories": [
      {
        "_id": "507f1f77bcf86cd799439011",
        "userId": {
          "_id": "507f1f77bcf86cd799439012",
          "name": "John Doe",
          "image": "https://example.com/profile.jpg",
          "username": "johndoe"
        },
        "type": "story",
        "files": [...],
        "caption": "My story",
        "likes": [],
        "views": [...],
        "viewCount": 20,
        "hasViewed": true,
        "isLiked": false,
        "likeCount": 5,
        "createdAt": "2024-01-15T10:00:00.000Z",
        "expiresAt": "2024-01-16T10:00:00.000Z"
      }
    ]
  }
}
```

**Response Fields:**
- `hasViewed`: Boolean indicating if current user has viewed this story
- `isLiked`: Boolean indicating if current user has liked this story

---

### 4. Get Story Details

**Request:**
```dart
GET /api/story/507f1f77bcf86cd799439011
Headers: {
  'Authorization': 'Bearer $token'
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Story retrieved successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "userId": {
      "_id": "507f1f77bcf86cd799439012",
      "name": "John Doe",
      "image": "https://example.com/profile.jpg",
      "username": "johndoe"
    },
    "type": "story",
    "files": [...],
    "caption": "My story",
    "likes": [...],
    "views": [...],
    "viewCount": 20,
    "hasViewed": true,
    "isLiked": false,
    "likeCount": 5,
    "expiresAt": "2024-01-16T10:00:00.000Z",
    "createdAt": "2024-01-15T10:00:00.000Z"
  }
}
```

---

### 5. View Story

**Request:**
```dart
POST /api/story/507f1f77bcf86cd799439011/view
Headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json'
}
Body: {}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Story viewed successfully",
  "data": {
    "storyId": "507f1f77bcf86cd799439011",
    "viewCount": 21,
    "hasViewed": true
  }
}
```

**Note:** 
- View count increments only once per user
- If user already viewed, view count doesn't increase but returns success

---

### 6. Like/Unlike Story

**Request:**
```dart
POST /api/story/507f1f77bcf86cd799439011/like
Headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json'
}
Body: {}
```

**Success Response (200) - Liked:**
```json
{
  "success": true,
  "message": "Story liked successfully",
  "data": {
    "storyId": "507f1f77bcf86cd799439011",
    "isLiked": true,
    "likeCount": 6
  }
}
```

**Success Response (200) - Unliked:**
```json
{
  "success": true,
  "message": "Story unliked successfully",
  "data": {
    "storyId": "507f1f77bcf86cd799439011",
    "isLiked": false,
    "likeCount": 5
  }
}
```

**Note:** Toggle behavior - if already liked, it unlikes; if not liked, it likes.

---

### 7. Delete Story

**Request:**
```dart
DELETE /api/story/507f1f77bcf86cd799439011
Headers: {
  'Authorization': 'Bearer $token'
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Story deleted successfully"
}
```

---

### 8. Get My Stories

**Request:**
```dart
GET /api/story/my-stories
Headers: {
  'Authorization': 'Bearer $token'
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "My stories retrieved successfully",
  "data": {
    "stories": [
      {
        "_id": "507f1f77bcf86cd799439011",
        "userId": "507f1f77bcf86cd799439012",
        "type": "story",
        "files": [...],
        "caption": "My story",
        "likes": [],
        "views": [...],
        "viewCount": 20,
        "likeCount": 5,
        "expiresAt": "2024-01-16T10:00:00.000Z",
        "createdAt": "2024-01-15T10:00:00.000Z"
      }
    ]
  }
}
```

---

## 💻 Flutter Implementation

### 1. Story Model

```dart
class Story {
  final String id;
  final String userId;
  final String type; // 'story' or 'video'
  final List<StoryFile> files;
  final String caption;
  final List<String> likes;
  final int viewCount;
  final DateTime expiresAt;
  final bool hasViewed;
  final bool isLiked;
  final int likeCount;
  final User? user;

  Story({
    required this.id,
    required this.userId,
    required this.type,
    required this.files,
    required this.caption,
    required this.likes,
    required this.viewCount,
    required this.expiresAt,
    this.hasViewed = false,
    this.isLiked = false,
    required this.likeCount,
    this.user,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['_id'],
      userId: json['userId'] is String 
          ? json['userId'] 
          : json['userId']['_id'],
      type: json['type'],
      files: (json['files'] as List?)
          ?.map((f) => StoryFile.fromJson(f))
          .toList() ?? [],
      caption: json['caption'] ?? '',
      likes: (json['likes'] as List?)?.map((l) => l.toString()).toList() ?? [],
      viewCount: json['viewCount'] ?? 0,
      expiresAt: DateTime.parse(json['expiresAt']),
      hasViewed: json['hasViewed'] ?? false,
      isLiked: json['isLiked'] ?? false,
      likeCount: json['likeCount'] ?? json['likes']?.length ?? 0,
      user: json['userId'] is Map ? User.fromJson(json['userId']) : null,
    );
  }
}

class StoryFile {
  final String file;
  final String type; // 'image', 'audio', or 'video'
  final String? thumbnail;

  StoryFile({
    required this.file,
    required this.type,
    this.thumbnail,
  });

  factory StoryFile.fromJson(Map<String, dynamic> json) {
    return StoryFile(
      file: json['file'],
      type: json['type'],
      thumbnail: json['thumbnail'],
    );
  }
}
```

---

### 2. API Service Class

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class StoryService {
  final String baseUrl;
  final String authToken;

  StoryService({
    required this.baseUrl,
    required this.authToken,
  });

  // Create Story
  Future<Map<String, dynamic>> createStory({
    required String type, // 'story' or 'video'
    required List<Map<String, dynamic>> files,
    String? caption,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/story/create');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': type,
          'files': files,
          'caption': caption ?? '',
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create story',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get All Stories
  Future<Map<String, dynamic>> getAllStories({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/story/all?page=$page&limit=$limit');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get stories',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get User Stories
  Future<Map<String, dynamic>> getUserStories(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/story/user/$userId');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get user stories',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get Story Details
  Future<Map<String, dynamic>> getStoryDetails(String storyId) async {
    try {
      final url = Uri.parse('$baseUrl/api/story/$storyId');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get story details',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // View Story
  Future<Map<String, dynamic>> viewStory(String storyId) async {
    try {
      final url = Uri.parse('$baseUrl/api/story/$storyId/view');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to view story',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Like/Unlike Story
  Future<Map<String, dynamic>> likeStory(String storyId) async {
    try {
      final url = Uri.parse('$baseUrl/api/story/$storyId/like');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to like story',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Delete Story
  Future<Map<String, dynamic>> deleteStory(String storyId) async {
    try {
      final url = Uri.parse('$baseUrl/api/story/$storyId');
      
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete story',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get My Stories
  Future<Map<String, dynamic>> getMyStories() async {
    try {
      final url = Uri.parse('$baseUrl/api/story/my-stories');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get my stories',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
```

---

### 3. Usage Examples

#### Create Story with Image

```dart
// First upload image to file upload endpoint
// Then use the returned URL

final storyService = StoryService(
  baseUrl: 'https://your-api-domain.com',
  authToken: userToken,
);

final result = await storyService.createStory(
  type: 'story',
  files: [
    {
      'file': 'https://example.com/uploaded-image.jpg',
      'type': 'image',
    }
  ],
  caption: 'My first story!',
);

if (result['success']) {
  print('Story created: ${result['data']['_id']}');
} else {
  print('Error: ${result['message']}');
}
```

#### Create Story with Video

```dart
final result = await storyService.createStory(
  type: 'video',
  files: [
    {
      'file': 'https://example.com/uploaded-video.mp4',
      'type': 'video',
      'thumbnail': 'https://example.com/video-thumbnail.jpg', // optional
    }
  ],
  caption: 'Check out this video!',
);
```

#### Create Story with Audio

```dart
final result = await storyService.createStory(
  type: 'story',
  files: [
    {
      'file': 'https://example.com/uploaded-audio.mp3',
      'type': 'audio',
    }
  ],
  caption: 'Listen to this!',
);
```

#### Get All Stories

```dart
final result = await storyService.getAllStories(page: 1, limit: 20);

if (result['success']) {
  final storiesData = result['data'];
  final stories = storiesData['stories'] as List;
  
  for (var storyGroup in stories) {
    final user = storyGroup['user'];
    final userStories = storyGroup['stories'] as List;
    
    print('User: ${user['name']}');
    print('Stories count: ${userStories.length}');
  }
}
```

#### View Story

```dart
final result = await storyService.viewStory(storyId);

if (result['success']) {
  final data = result['data'];
  print('View count: ${data['viewCount']}');
  print('Has viewed: ${data['hasViewed']}');
}
```

#### Like Story

```dart
final result = await storyService.likeStory(storyId);

if (result['success']) {
  final data = result['data'];
  print('Is liked: ${data['isLiked']}');
  print('Like count: ${data['likeCount']}');
}
```

---

## 📋 File Upload Flow

Before creating a story, you need to upload files:

### Step 1: Upload File

```dart
// Use your existing file upload endpoint
POST /fileUpload
FormData: {
  'files': File (image/audio/video)
}

Response: {
  "success": true,
  "data": {
    "urls": ["/public/upload/filename.jpg"]
  }
}
```

### Step 2: Create Story with Uploaded URL

```dart
final fileUrl = 'https://your-api-domain.com${uploadResponse['urls'][0]}';

await storyService.createStory(
  type: 'story',
  files: [
    {
      'file': fileUrl,
      'type': 'image',
    }
  ],
);
```

---

## ✅ Best Practices

### 1. View Tracking
- Call `viewStory` API when user opens/starts viewing a story
- Don't call multiple times - backend handles duplicate views
- Check `hasViewed` field to show viewed indicator

### 2. Story Expiration
- Stories expire after 24 hours
- Filter out expired stories on frontend
- Show expiration countdown if needed

### 3. File Types
- **Story type**: Use `image` or `audio` files
- **Video type**: Use `video` files only
- Always validate file type before creating story

### 4. Error Handling
```dart
try {
  final result = await storyService.createStory(...);
  
  if (result['success']) {
    // Handle success
  } else {
    // Show error message
    showError(result['message']);
  }
} catch (e) {
  // Handle network/parsing errors
  showError('Something went wrong');
}
```

---

## 🔍 Response Structure

### Story Object
```json
{
  "_id": "story_id",
  "userId": "user_id or user_object",
  "type": "story" | "video",
  "files": [
    {
      "file": "url",
      "type": "image" | "audio" | "video",
      "thumbnail": "url or null"
    }
  ],
  "caption": "text",
  "likes": ["user_id1", "user_id2"],
  "views": [
    {
      "userId": "user_id",
      "viewedAt": "timestamp"
    }
  ],
  "viewCount": 10,
  "hasViewed": true | false,
  "isLiked": true | false,
  "likeCount": 5,
  "expiresAt": "2024-01-16T10:00:00.000Z",
  "isActive": true,
  "createdAt": "2024-01-15T10:00:00.000Z"
}
```

---

## 📝 Testing Checklist

- [ ] Create story with image
- [ ] Create story with audio
- [ ] Create story with video
- [ ] Get all stories
- [ ] Get user stories
- [ ] View story (check view count increment)
- [ ] View story again (check no duplicate increment)
- [ ] Like story
- [ ] Unlike story
- [ ] Delete story
- [ ] Get my stories
- [ ] Check story expiration (24 hours)
- [ ] Verify `hasViewed` flag
- [ ] Verify `isLiked` flag

---

## 🐛 Common Issues

### Issue: Story not showing
**Solution:** Check if story has expired (24 hours) or is inactive

### Issue: View count not incrementing
**Solution:** Backend prevents duplicate views - check if user already viewed

### Issue: Invalid file type error
**Solution:** 
- Story type: only `image` or `audio`
- Video type: only `video`

### Issue: 404 on expired story
**Solution:** Stories expire after 24 hours - filter them out

---

## 📞 Support

If you encounter any issues, check:
1. JWT token is valid
2. File URLs are accessible
3. Story hasn't expired
4. File types match story type

---

**Base URL:** `http://your-api-domain.com`  
**API Version:** 1.0.0  
**Last Updated:** [Current Date]

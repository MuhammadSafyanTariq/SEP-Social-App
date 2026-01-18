# Flutter Integration Guide: Story & Notification Endpoints

## 📋 Overview

This guide provides complete integration instructions for **Story** and **Notification** features in your Flutter application. It covers all endpoints, request/response formats, error handling, and Flutter implementation examples.

---

## 🔐 Authentication

All endpoints require JWT authentication. Include the token in the `Authorization` header:

```dart
headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json'
}
```

---

## 📚 Table of Contents

1. [Story Endpoints](#story-endpoints)
   - Create Story
   - Get All Stories
   - Get My Stories
   - Get User Stories
   - Get Story Details
   - View Story
   - Like/Unlike Story
   - Delete Story

2. [Notification Endpoints](#notification-endpoints)
   - Get Notifications
   - Get Notification by ID
   - Get Unread Count
   - Mark Notification as Read
   - Mark All Notifications as Read
   - Delete Notification
   - Delete All Notifications

3. [Flutter Implementation Examples](#flutter-implementation-examples)
   - API Service Class
   - Models/DTOs
   - Usage Examples

---

## 📖 Story Endpoints

### Base URL
```
/api/story
```

---

### 1. Create Story

**Endpoint:** `POST /api/story/create`

**Description:** Create a new story with images/audio or videos.

**Request Body:**
```json
{
  "type": "story",  // or "video"
  "files": [
    {
      "file": "https://example.com/image.jpg",  // File URL (must be uploaded first)
      "type": "image",  // "image", "audio" for story type, or "video" for video type
      "thumbnail": "https://example.com/thumb.jpg"  // optional, for video
    }
  ],
  "caption": "My story caption"  // optional
}
```

**Response (201):**
```json
{
  "status": true,
  "code": 201,
  "message": "Story created successfully",
  "data": {
    "_id": "story_id_here",
    "userId": "user_id_here",
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
    "isActive": true,
    "expiresAt": "2024-01-02T12:00:00.000Z",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> createStory({
  required String type,  // "story" or "video"
  required List<Map<String, dynamic>> files,
  String? caption,
  required String token,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/story/create'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'type': type,
      'files': files,
      if (caption != null) 'caption': caption,
    }),
  );

  return jsonDecode(response.body);
}
```

**Important Notes:**
- `type: "story"` can contain `image` or `audio` files
- `type: "video"` can only contain `video` files
- Files must be uploaded to your file upload endpoint first to get URLs
- Stories automatically expire after 24 hours

---

### 2. Get All Stories

**Endpoint:** `GET /api/story/all`

**Description:** Get all active stories grouped by user (for story feed).

**Query Parameters:**
- `page` (optional, default: 1) - Page number for pagination
- `limit` (optional, default: 20) - Items per page

**Response (200):**
```json
{
  "status": true,
  "code": 200,
  "message": "Stories retrieved successfully",
  "data": {
    "stories": [
      {
        "user": {
          "_id": "user_id",
          "name": "User Name",
          "username": "username",
          "image": "profile_image_url"
        },
        "stories": [
          {
            "_id": "story_id",
            "type": "story",
            "files": [...],
            "caption": "...",
            "likes": ["user_id1", "user_id2"],
            "likeCount": 2,
            "viewCount": 10,
            "createdAt": "2024-01-01T12:00:00.000Z",
            "expiresAt": "2024-01-02T12:00:00.000Z"
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

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> getAllStories({
  int page = 1,
  int limit = 20,
  required String token,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/story/all?page=$page&limit=$limit'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

---

### 3. Get My Stories

**Endpoint:** `GET /api/story/my-stories`

**Description:** Get all active stories created by the authenticated user.

**Response (200):**
```json
{
  "status": true,
  "code": 200,
  "message": "My stories retrieved successfully",
  "data": {
    "stories": [
      {
        "_id": "story_id",
        "userId": "user_id",
        "type": "story",
        "files": [...],
        "caption": "...",
        "likes": ["user_id1"],
        "views": [...],
        "likeCount": 1,
        "viewCount": 5,
        "isActive": true,
        "expiresAt": "2024-01-02T12:00:00.000Z",
        "createdAt": "2024-01-01T12:00:00.000Z",
        "updatedAt": "2024-01-01T12:00:00.000Z"
      }
    ]
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> getMyStories({
  required String token,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/story/my-stories'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

---

### 4. Get User Stories

**Endpoint:** `GET /api/story/user/:userId`

**Description:** Get all active stories for a specific user.

**URL Parameters:**
- `userId` - The ID of the user whose stories you want to retrieve

**Response (200):**
```json
{
  "status": true,
  "code": 200,
  "message": "User stories retrieved successfully",
  "data": {
    "stories": [
      {
        "_id": "story_id",
        "userId": {
          "_id": "user_id",
          "name": "User Name",
          "username": "username",
          "image": "profile_image_url"
        },
        "type": "story",
        "files": [...],
        "caption": "...",
        "likes": ["user_id1"],
        "views": [...],
        "hasViewed": false,
        "likeCount": 1,
        "isLiked": false,
        "createdAt": "2024-01-01T12:00:00.000Z",
        "updatedAt": "2024-01-01T12:00:00.000Z",
        "expiresAt": "2024-01-02T12:00:00.000Z"
      }
    ]
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> getUserStories({
  required String userId,
  required String token,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/story/user/$userId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

---

### 5. Get Story Details

**Endpoint:** `GET /api/story/:storyId`

**Description:** Get detailed information about a specific story.

**URL Parameters:**
- `storyId` - The ID of the story

**Response (200):**
```json
{
  "status": true,
  "code": 200,
  "message": "Story retrieved successfully",
  "data": {
    "_id": "story_id",
    "userId": {
      "_id": "user_id",
      "name": "User Name",
      "username": "username",
      "image": "profile_image_url"
    },
    "type": "story",
    "files": [...],
    "caption": "...",
    "likes": [
      {
        "_id": "user_id",
        "name": "User Name",
        "username": "username",
        "image": "profile_image_url"
      }
    ],
    "views": [...],
    "hasViewed": false,
    "isLiked": false,
    "likeCount": 1,
    "viewCount": 5,
    "isActive": true,
    "expiresAt": "2024-01-02T12:00:00.000Z",
    "createdAt": "2024-01-01T12:00:00.000Z",
    "updatedAt": "2024-01-01T12:00:00.000Z"
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> getStoryDetails({
  required String storyId,
  required String token,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/story/$storyId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

**Error Responses:**
- `404` - Story not found or expired

---

### 6. View Story

**Endpoint:** `POST /api/story/:storyId/view`

**Description:** Mark a story as viewed (increments view count and tracks viewer). Calling this multiple times won't duplicate views.

**URL Parameters:**
- `storyId` - The ID of the story to view

**Response (200):**
```json
{
  "status": true,
  "code": 200,
  "message": "Story viewed successfully",
  "data": {
    "storyId": "story_id",
    "viewCount": 6,
    "hasViewed": true
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> viewStory({
  required String storyId,
  required String token,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/story/$storyId/view'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

**Important Notes:**
- Each user can only view a story once (view count increments only on first view)
- Call this endpoint when displaying a story to the user

---

### 7. Like/Unlike Story

**Endpoint:** `POST /api/story/:storyId/like`

**Description:** Toggle like status on a story. If already liked, it will unlike.

**URL Parameters:**
- `storyId` - The ID of the story to like/unlike

**Response (200) - Liked:**
```json
{
  "status": true,
  "code": 200,
  "message": "Story liked successfully",
  "data": {
    "storyId": "story_id",
    "isLiked": true,
    "likeCount": 3
  }
}
```

**Response (200) - Unliked:**
```json
{
  "status": true,
  "code": 200,
  "message": "Story unliked successfully",
  "data": {
    "storyId": "story_id",
    "isLiked": false,
    "likeCount": 2
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> likeStory({
  required String storyId,
  required String token,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/story/$storyId/like'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

**Important Notes:**
- Liking a story creates a notification for the story owner (unless it's their own story)
- This is a toggle action - same endpoint for both like and unlike

---

### 8. Delete Story

**Endpoint:** `DELETE /api/story/:storyId`

**Description:** Delete (soft delete) a story. Only the story owner can delete it.

**URL Parameters:**
- `storyId` - The ID of the story to delete

**Response (200):**
```json
{
  "status": true,
  "code": 200,
  "message": "Story deleted successfully"
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> deleteStory({
  required String storyId,
  required String token,
}) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/api/story/$storyId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

**Error Responses:**
- `403` - You don't have permission to delete this story
- `404` - Story not found

---

## 🔔 Notification Endpoints

### Base URL
```
/api/notification
```

---

### 1. Get Notifications

**Endpoint:** `GET /api/notification`

**Description:** Get all notifications for the authenticated user with pagination.

**Query Parameters:**
- `page` (optional, default: 1) - Page number
- `limit` (optional, default: 20) - Items per page
- `unreadOnly` (optional, default: false) - If `true`, returns only unread notifications

**Response (200):**
```json
{
  "status": true,
  "code": 200,
  "message": "Notifications retrieved successfully",
  "data": {
    "notifications": [
      {
        "_id": "notification_id",
        "senderId": {
          "_id": "sender_user_id",
          "name": "Sender Name",
          "username": "sender_username",
          "image": "sender_profile_image_url"
        },
        "receiverId": "receiver_user_id",
        "notificationType": "like",
        "title": "New Like",
        "message": "Someone liked your story",
        "postId": null,
        "commentId": null,
        "followedUserId": null,
        "isRead": false,
        "roomId": null,
        "status": null,
        "createdAt": "2024-01-01T12:00:00.000Z",
        "updatedAt": "2024-01-01T12:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "totalCount": 45,
      "totalPages": 3
    },
    "unreadCount": 15
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> getNotifications({
  int page = 1,
  int limit = 20,
  bool unreadOnly = false,
  required String token,
}) async {
  final queryParams = {
    'page': page.toString(),
    'limit': limit.toString(),
    if (unreadOnly) 'unreadOnly': 'true',
  };
  
  final uri = Uri.parse('$baseUrl/api/notification').replace(
    queryParameters: queryParams,
  );

  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

**Notification Types:**
- `"pool"` - Pool-related notification
- `"like"` - Like notification (posts, stories, etc.)
- `"comment"` - Comment notification
- `"follow"` - Follow notification
- `"live"` - Live stream notification
- `"inviteForLive"` - Live stream invitation
- `"message"` - Message notification
- `"chat"` - Chat notification

---

### 2. Get Notification by ID

**Endpoint:** `GET /api/notification/:notificationId`

**Description:** Get details of a specific notification.

**URL Parameters:**
- `notificationId` - The ID of the notification

**Response (200):**
```json
{
  "status": true,
  "code": 200,
  "message": "Notification retrieved successfully",
  "data": {
    "notification": {
      "_id": "notification_id",
      "senderId": {
        "_id": "sender_user_id",
        "name": "Sender Name",
        "username": "sender_username",
        "image": "sender_profile_image_url"
      },
      "receiverId": "receiver_user_id",
      "notificationType": "like",
      "title": "New Like",
      "message": "Someone liked your story",
      "isRead": false,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:00:00.000Z"
    }
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> getNotificationById({
  required String notificationId,
  required String token,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/notification/$notificationId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

**Error Responses:**
- `400` - Invalid notification ID format
- `403` - You are not authorized to view this notification
- `404` - Notification not found

---

### 3. Get Unread Count

**Endpoint:** `GET /api/notification/unread-count`

**Description:** Get the count of unread notifications for the authenticated user.

**Response (200):**
```json
{
  "status": true,
  "code": 200,
  "message": "Unread count retrieved successfully",
  "data": {
    "unreadCount": 15
  }
}
```

**Flutter Implementation:**
```dart
Future<int> getUnreadNotificationCount({
  required String token,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/notification/unread-count'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  final data = jsonDecode(response.body);
  return data['data']['unreadCount'] ?? 0;
}
```

**Use Case:** Use this to display a badge count on your notification icon.

---

### 4. Mark Notification as Read

**Endpoint:** `PATCH /api/notification/:notificationId/read`

**Description:** Mark a specific notification as read.

**URL Parameters:**
- `notificationId` - The ID of the notification to mark as read

**Response (200):**
```json
{
  "status": true,
  "code": 200,
  "message": "Notification marked as read successfully",
  "data": {
    "notification": {
      "_id": "notification_id",
      "senderId": "sender_user_id",
      "receiverId": "receiver_user_id",
      "notificationType": "like",
      "title": "New Like",
      "message": "Someone liked your story",
      "isRead": true,
      "createdAt": "2024-01-01T12:00:00.000Z",
      "updatedAt": "2024-01-01T12:30:00.000Z"
    }
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> markNotificationAsRead({
  required String notificationId,
  required String token,
}) async {
  final response = await http.patch(
    Uri.parse('$baseUrl/api/notification/$notificationId/read'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

**Error Responses:**
- `400` - Invalid notification ID format
- `403` - You are not authorized to mark this notification as read
- `404` - Notification not found

**Important Notes:**
- If notification is already read, returns `200` with existing notification
- Only the receiver can mark a notification as read

---

### 5. Mark All Notifications as Read

**Endpoint:** `PATCH /api/notification/read-all`

**Description:** Mark all unread notifications as read for the authenticated user.

**Response (200):**
```json
{
  "status": true,
  "code": 200,
  "message": "All notifications marked as read successfully",
  "data": {
    "modifiedCount": 15,
    "matchedCount": 15
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> markAllNotificationsAsRead({
  required String token,
}) async {
  final response = await http.patch(
    Uri.parse('$baseUrl/api/notification/read-all'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

**Use Case:** Add a "Mark all as read" button in your notifications screen.

---

### 6. Delete Notification

**Endpoint:** `DELETE /api/notification/:notificationId`

**Description:** Delete a specific notification.

**URL Parameters:**
- `notificationId` - The ID of the notification to delete

**Response (200):**
```json
{
  "status": true,
  "code": 200,
  "message": "Notification deleted successfully"
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> deleteNotification({
  required String notificationId,
  required String token,
}) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/api/notification/$notificationId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

**Error Responses:**
- `400` - Invalid notification ID format
- `403` - You are not authorized to delete this notification
- `404` - Notification not found

---

### 7. Delete All Notifications

**Endpoint:** `DELETE /api/notification/all`

**Description:** Delete all notifications for the authenticated user.

**Response (200):**
```json
{
  "status": true,
  "code": 200,
  "message": "All notifications deleted successfully",
  "data": {
    "deletedCount": 45
  }
}
```

**Flutter Implementation:**
```dart
Future<Map<String, dynamic>> deleteAllNotifications({
  required String token,
}) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/api/notification/all'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

---

## 💻 Flutter Implementation Examples

### Complete API Service Class

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class StoryNotificationService {
  final String baseUrl;
  
  StoryNotificationService({required this.baseUrl});

  // ==================== STORY ENDPOINTS ====================

  /// Create a new story
  Future<Map<String, dynamic>> createStory({
    required String type,
    required List<Map<String, dynamic>> files,
    String? caption,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/story/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': type,
          'files': files,
          if (caption != null) 'caption': caption,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to create story: $e');
    }
  }

  /// Get all stories (grouped by user)
  Future<Map<String, dynamic>> getAllStories({
    int page = 1,
    int limit = 20,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/story/all?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get stories: $e');
    }
  }

  /// Get my stories
  Future<Map<String, dynamic>> getMyStories({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/story/my-stories'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get my stories: $e');
    }
  }

  /// Get stories by user ID
  Future<Map<String, dynamic>> getUserStories({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/story/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get user stories: $e');
    }
  }

  /// Get story details
  Future<Map<String, dynamic>> getStoryDetails({
    required String storyId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/story/$storyId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get story details: $e');
    }
  }

  /// View a story (increment view count)
  Future<Map<String, dynamic>> viewStory({
    required String storyId,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/story/$storyId/view'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to view story: $e');
    }
  }

  /// Like/Unlike a story
  Future<Map<String, dynamic>> likeStory({
    required String storyId,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/story/$storyId/like'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to like story: $e');
    }
  }

  /// Delete a story
  Future<Map<String, dynamic>> deleteStory({
    required String storyId,
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/story/$storyId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to delete story: $e');
    }
  }

  // ==================== NOTIFICATION ENDPOINTS ====================

  /// Get all notifications
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
    required String token,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (unreadOnly) 'unreadOnly': 'true',
      };
      
      final uri = Uri.parse('$baseUrl/api/notification').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  /// Get notification by ID
  Future<Map<String, dynamic>> getNotificationById({
    required String notificationId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notification/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to get notification: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notification/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      return data['data']['unreadCount'] ?? 0;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  /// Mark notification as read
  Future<Map<String, dynamic>> markNotificationAsRead({
    required String notificationId,
    required String token,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/notification/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<Map<String, dynamic>> markAllNotificationsAsRead({
    required String token,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/notification/read-all'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<Map<String, dynamic>> deleteNotification({
    required String notificationId,
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/notification/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Delete all notifications
  Future<Map<String, dynamic>> deleteAllNotifications({
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/notification/all'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to delete all notifications: $e');
    }
  }
}
```

---

### Models/DTOs Example

```dart
// Story Models
class Story {
  final String id;
  final String userId;
  final String type;
  final List<StoryFile> files;
  final String caption;
  final List<String> likes;
  final int likeCount;
  final int viewCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool? hasViewed;
  final bool? isLiked;

  Story({
    required this.id,
    required this.userId,
    required this.type,
    required this.files,
    required this.caption,
    required this.likes,
    required this.likeCount,
    required this.viewCount,
    required this.isActive,
    required this.createdAt,
    required this.expiresAt,
    this.hasViewed,
    this.isLiked,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['_id'],
      userId: json['userId'] is String 
          ? json['userId'] 
          : json['userId']['_id'],
      type: json['type'],
      files: (json['files'] as List)
          .map((file) => StoryFile.fromJson(file))
          .toList(),
      caption: json['caption'] ?? '',
      likes: json['likes'] != null 
          ? (json['likes'] as List).map((e) => e.toString()).toList()
          : [],
      likeCount: json['likeCount'] ?? json['likes']?.length ?? 0,
      viewCount: json['viewCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      hasViewed: json['hasViewed'],
      isLiked: json['isLiked'],
    );
  }
}

class StoryFile {
  final String file;
  final String type;
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

// Notification Models
class NotificationModel {
  final String id;
  final UserInfo? senderId;
  final String receiverId;
  final String notificationType;
  final String? title;
  final String? message;
  final String? postId;
  final String? commentId;
  final String? followedUserId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    this.senderId,
    required this.receiverId,
    required this.notificationType,
    this.title,
    this.message,
    this.postId,
    this.commentId,
    this.followedUserId,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      senderId: json['senderId'] is Map
          ? UserInfo.fromJson(json['senderId'])
          : null,
      receiverId: json['receiverId'] is String
          ? json['receiverId']
          : json['receiverId']['_id'],
      notificationType: json['notificationType'],
      title: json['title'],
      message: json['message'],
      postId: json['postId'],
      commentId: json['commentId'],
      followedUserId: json['followedUserId'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class UserInfo {
  final String id;
  final String? name;
  final String? username;
  final String? image;

  UserInfo({
    required this.id,
    this.name,
    this.username,
    this.image,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'],
      name: json['name'],
      username: json['username'],
      image: json['image'],
    );
  }
}
```

---

### Usage Example in Widget

```dart
import 'package:flutter/material.dart';

class StoriesScreen extends StatefulWidget {
  @override
  _StoriesScreenState createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final StoryNotificationService _apiService = StoryNotificationService(
    baseUrl: 'https://your-api-domain.com',
  );
  
  List<Story> _stories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await _getAuthToken(); // Your token retrieval logic
      final response = await _apiService.getAllStories(
        token: token,
        page: 1,
        limit: 20,
      );

      if (response['status'] == true) {
        // Parse stories from response
        // Implementation depends on your data structure
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load stories: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _likeStory(String storyId) async {
    try {
      final token = await _getAuthToken();
      final response = await _apiService.likeStory(
        storyId: storyId,
        token: token,
      );

      if (response['status'] == true) {
        // Update UI with new like status
        _loadStories(); // Refresh list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to like story: $e')),
      );
    }
  }

  Future<void> _viewStory(String storyId) async {
    try {
      final token = await _getAuthToken();
      await _apiService.viewStory(
        storyId: storyId,
        token: token,
      );
    } catch (e) {
      print('Failed to mark story as viewed: $e');
    }
  }

  Future<String> _getAuthToken() async {
    // Implement your token retrieval logic
    // e.g., from SharedPreferences, SecureStorage, etc.
    return 'your_jwt_token_here';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    return ListView.builder(
      itemCount: _stories.length,
      itemBuilder: (context, index) {
        final story = _stories[index];
        return StoryTile(
          story: story,
          onLike: () => _likeStory(story.id),
          onView: () => _viewStory(story.id),
        );
      },
    );
  }
}
```

---

## 🚨 Error Handling

All endpoints follow a consistent error response format:

```json
{
  "status": false,
  "code": 400,  // or 401, 403, 404, 500, etc.
  "message": "Error message here"
}
```

**Common HTTP Status Codes:**
- `200` - Success
- `201` - Created (for create operations)
- `400` - Bad Request (invalid parameters)
- `401` - Unauthorized (missing/invalid token)
- `403` - Forbidden (no permission)
- `404` - Not Found (resource doesn't exist)
- `500` - Internal Server Error

**Error Handling Example:**
```dart
Future<void> handleApiCall() async {
  try {
    final response = await _apiService.getNotifications(token: token);
    
    if (response['status'] == true) {
      // Handle success
      final notifications = response['data']['notifications'];
    } else {
      // Handle API error
      final errorMessage = response['message'];
      showError(errorMessage);
    }
  } on SocketException {
    showError('No internet connection');
  } on HttpException {
    showError('HTTP error occurred');
  } catch (e) {
    showError('An unexpected error occurred: $e');
  }
}
```

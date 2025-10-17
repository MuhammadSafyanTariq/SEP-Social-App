import 'dart:convert';
import 'lib/feature/data/models/dataModels/post_data.dart';

void main() {
  // Test data that mimics the backend response with _id instead of id
  final testJson = {
    "_id": "6744c6e7333df0d42544b9a9",
    "userId": "68f0069ef8eb1a7eb676b40b",
    "content": "Test post content",
    "likeCount": 5,
    "commentCount": 2,
    "createdAt": "2024-10-16T10:30:00Z",
  };

  print('Testing PostData.fromJson with _id field...');

  try {
    final postData = PostData.fromJson(testJson);
    print('✅ Success! PostData created successfully');
    print('📊 Post ID: ${postData.id}');
    print('👤 User ID: ${postData.userId}');
    print('💬 Content: ${postData.content}');
    print('❤️ Like Count: ${postData.likeCount}');
    print('💬 Comment Count: ${postData.commentCount}');

    if (postData.id != null && postData.id!.isNotEmpty) {
      print('✅ ID mapping successful: _id -> id');
    } else {
      print('❌ ID mapping failed: id is null or empty');
    }
  } catch (e) {
    print('❌ Error creating PostData: $e');
  }
}

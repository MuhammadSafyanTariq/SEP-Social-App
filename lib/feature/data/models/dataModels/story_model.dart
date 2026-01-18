import 'package:sep/feature/data/models/dataModels/getUserDetailModel.dart';

/// Story File Model
class StoryFile {
  final String file;
  final String type; // 'image', 'audio', or 'video'
  final String? thumbnail;

  StoryFile({required this.file, required this.type, this.thumbnail});

  factory StoryFile.fromJson(Map<String, dynamic> json) {
    return StoryFile(
      file: json['file'] ?? '',
      type: json['type'] ?? 'image',
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'type': type,
      if (thumbnail != null) 'thumbnail': thumbnail,
    };
  }
}

/// Story View Model
class StoryView {
  final String userId;
  final DateTime viewedAt;
  final UserData? user;

  StoryView({required this.userId, required this.viewedAt, this.user});

  factory StoryView.fromJson(Map<String, dynamic> json) {
    return StoryView(
      userId: json['userId'] is String ? json['userId'] : json['userId']['_id'],
      viewedAt: DateTime.parse(json['viewedAt']),
      user: json['userId'] is Map ? UserData.fromJson(json['userId']) : null,
    );
  }
}

/// Story Model
class Story {
  final String id;
  final String userId;
  final String type; // 'story' or 'video'
  final List<StoryFile> files;
  final String caption;
  final List<String> likes;
  final List<StoryView> views;
  final int viewCount;
  final DateTime expiresAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed fields from backend
  final bool hasViewed;
  final bool isLiked;
  final int likeCount;

  // User data (populated in some endpoints)
  final UserData? user;

  Story({
    required this.id,
    required this.userId,
    required this.type,
    required this.files,
    required this.caption,
    required this.likes,
    required this.views,
    required this.viewCount,
    required this.expiresAt,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.hasViewed = false,
    this.isLiked = false,
    required this.likeCount,
    this.user,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] is String
          ? json['userId']
          : json['userId']?['_id'] ?? '',
      type: json['type'] ?? 'story',
      files:
          (json['files'] as List?)
              ?.map((f) => StoryFile.fromJson(f))
              .toList() ??
          [],
      caption: json['caption'] ?? '',
      likes: (json['likes'] as List?)?.map((l) => l.toString()).toList() ?? [],
      views:
          (json['views'] as List?)
              ?.map((v) => StoryView.fromJson(v))
              .toList() ??
          [],
      viewCount: json['viewCount'] ?? 0,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(Duration(hours: 24)),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      hasViewed: json['hasViewed'] ?? false,
      isLiked: json['isLiked'] ?? false,
      likeCount: json['likeCount'] ?? json['likes']?.length ?? 0,
      user: json['userId'] is Map ? UserData.fromJson(json['userId']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'type': type,
      'files': files.map((f) => f.toJson()).toList(),
      'caption': caption,
      'likes': likes,
      'viewCount': viewCount,
      'expiresAt': expiresAt.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'hasViewed': hasViewed,
      'isLiked': isLiked,
      'likeCount': likeCount,
    };
  }

  /// Check if story is expired (more than 24 hours old)
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Get time remaining until expiration
  Duration get timeRemaining {
    return expiresAt.difference(DateTime.now());
  }

  /// Copy with method for immutable updates
  Story copyWith({
    String? id,
    String? userId,
    String? type,
    List<StoryFile>? files,
    String? caption,
    List<String>? likes,
    List<StoryView>? views,
    int? viewCount,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasViewed,
    bool? isLiked,
    int? likeCount,
    UserData? user,
  }) {
    return Story(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      files: files ?? this.files,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      viewCount: viewCount ?? this.viewCount,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasViewed: hasViewed ?? this.hasViewed,
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
      user: user ?? this.user,
    );
  }
}

/// User Story Group Model (for grouped stories by user)
class UserStoryGroup {
  final UserData user;
  final List<Story> stories;

  UserStoryGroup({required this.user, required this.stories});

  factory UserStoryGroup.fromJson(Map<String, dynamic> json) {
    return UserStoryGroup(
      user: UserData.fromJson(json['user']),
      stories: (json['stories'] as List).map((s) => Story.fromJson(s)).toList(),
    );
  }

  /// Check if user has any unviewed stories
  bool get hasUnviewedStories {
    return stories.any((story) => !story.hasViewed);
  }

  /// Get the most recent story
  Story? get latestStory {
    if (stories.isEmpty) return null;
    return stories.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
  }
}

/// Pagination Model
class StoryPagination {
  final int page;
  final int limit;
  final int totalCount;
  final int totalPages;

  StoryPagination({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
  });

  factory StoryPagination.fromJson(Map<String, dynamic> json) {
    return StoryPagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}

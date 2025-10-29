class ChatBotMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatBotMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  /// Convert message to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create message from Map
  factory ChatBotMessage.fromMap(Map<String, dynamic> map) {
    return ChatBotMessage(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: map['timestamp'] is String
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  /// Copy with method for creating modified copies
  ChatBotMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return ChatBotMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'ChatBotMessage(id: $id, content: $content, isUser: $isUser, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatBotMessage &&
        other.id == id &&
        other.content == content &&
        other.isUser == isUser &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        content.hashCode ^
        isUser.hashCode ^
        timestamp.hashCode;
  }
}

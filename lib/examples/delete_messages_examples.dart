import 'package:flutter/material.dart';
import 'package:sep/feature/presentation/controller/chat_ctrl.dart';
import 'package:sep/feature/data/models/dataModels/chat_msg_model/chat_msg_model.dart';

/// Example: How to delete messages in SEP Social App
///
/// This file demonstrates various ways to use the delete messages feature

// Example usage - make sure you're in a chat before calling delete methods
// This is usually handled automatically when you open a chat

// ============================================
// Example 1: Delete a single message for yourself only
// ============================================
void deleteSingleMessageForMe(ChatMsgModel message) {
  ChatCtrl.find.deleteMessage(
    message,
    type: 'one', // 'one' means delete for me only
  );

  print('Message deleted for you only');
}

// ============================================
// Example 2: Delete a single message for everyone
// ============================================
void deleteSingleMessageForEveryone(ChatMsgModel message) {
  ChatCtrl.find.deleteMessage(
    message,
    type: 'all', // 'all' means delete for everyone
  );

  print('Message deleted for everyone in the chat');
}

// ============================================
// Example 3: Delete multiple messages at once
// ============================================
void deleteMultipleMessagesForMe(List<ChatMsgModel> messages) {
  // Extract message IDs
  final messageIds = messages
      .where((msg) => msg.id != null)
      .map((msg) => msg.id!)
      .toList();

  if (messageIds.isEmpty) {
    print('No valid message IDs to delete');
    return;
  }

  ChatCtrl.find.deleteMultipleMessages(
    messageIds,
    type: 'one', // Delete for me only
  );

  print('${messageIds.length} messages deleted for you');
}

// ============================================
// Example 4: Delete multiple messages for everyone
// ============================================
void deleteMultipleMessagesForEveryone(List<ChatMsgModel> messages) {
  // Extract message IDs
  final messageIds = messages
      .where((msg) => msg.id != null)
      .map((msg) => msg.id!)
      .toList();

  if (messageIds.isEmpty) {
    print('No valid message IDs to delete');
    return;
  }

  ChatCtrl.find.deleteMultipleMessages(
    messageIds,
    type: 'all', // Delete for everyone
  );

  print('${messageIds.length} messages deleted for everyone');
}

// ============================================
// Example 5: Delete with user confirmation dialog
// ============================================
void deleteMessageWithConfirmation(
  BuildContext context,
  ChatMsgModel message,
  bool isMyMessage,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete Message'),
      content: Text('How do you want to delete this message?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            deleteSingleMessageForMe(message);
          },
          child: Text('Delete for me'),
        ),
        if (isMyMessage) // Only show if it's user's own message
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteSingleMessageForEveryone(message);
            },
            child: Text('Delete for everyone'),
          ),
      ],
    ),
  );
}

// ============================================
// Example 6: Delete all messages from a specific sender
// ============================================
void deleteAllMessagesFromSender(String senderId) {
  final chatCtrl = ChatCtrl.find;

  // Filter messages from specific sender
  final messagesToDelete = chatCtrl.chatMessages
      .where((msg) => msg.sender?.id == senderId && msg.id != null)
      .map((msg) => msg.id!)
      .toList();

  if (messagesToDelete.isEmpty) {
    print('No messages found from this sender');
    return;
  }

  chatCtrl.deleteMultipleMessages(
    messagesToDelete,
    type: 'one', // Usually you'd delete for yourself only
  );

  print('Deleted ${messagesToDelete.length} messages from sender $senderId');
}

// ============================================
// Example 7: Delete messages older than a date
// ============================================
void deleteOldMessages(DateTime cutoffDate) {
  final chatCtrl = ChatCtrl.find;

  final oldMessageIds = chatCtrl.chatMessages
      .where((msg) {
        if (msg.id == null) return false;

        final messageDate = DateTime.tryParse(
          msg.senderTime ?? msg.createdAt ?? '',
        );

        return messageDate != null && messageDate.isBefore(cutoffDate);
      })
      .map((msg) => msg.id!)
      .toList();

  if (oldMessageIds.isEmpty) {
    print('No old messages to delete');
    return;
  }

  chatCtrl.deleteMultipleMessages(oldMessageIds, type: 'one');

  print('Deleted ${oldMessageIds.length} old messages');
}

// ============================================
// Example 8: Delete messages with specific content
// ============================================
void deleteMessagesContaining(String keyword) {
  final chatCtrl = ChatCtrl.find;

  final matchingMessageIds = chatCtrl.chatMessages
      .where(
        (msg) =>
            msg.id != null &&
            msg.content != null &&
            msg.content!.toLowerCase().contains(keyword.toLowerCase()),
      )
      .map((msg) => msg.id!)
      .toList();

  if (matchingMessageIds.isEmpty) {
    print('No messages found containing "$keyword"');
    return;
  }

  chatCtrl.deleteMultipleMessages(matchingMessageIds, type: 'one');

  print('Deleted ${matchingMessageIds.length} messages containing "$keyword"');
}

// ============================================
// Example 9: Using with proper error handling
// ============================================
void deleteMessageSafely(ChatMsgModel? message, String type) {
  try {
    // Validate message
    if (message == null) {
      print('Error: Message is null');
      return;
    }

    if (message.id == null || message.id!.isEmpty) {
      print('Error: Message ID is invalid');
      return;
    }

    // Validate chat context
    final chatCtrl = ChatCtrl.find;
    if (chatCtrl.singleChatId == null) {
      print('Error: No active chat');
      return;
    }

    // Validate type
    if (type != 'one' && type != 'all') {
      print('Error: Invalid type. Use "one" or "all"');
      return;
    }

    // Perform deletion
    chatCtrl.deleteMessage(message, type: type);
    print('Message deletion initiated successfully');
  } catch (e) {
    print('Error deleting message: $e');
  }
}

// ============================================
// Example 10: Quick helper functions
// ============================================

/// Quick delete for me
void quickDeleteForMe(ChatMsgModel message) {
  ChatCtrl.find.deleteMessage(message, type: 'one');
}

/// Quick delete for everyone
void quickDeleteForAll(ChatMsgModel message) {
  ChatCtrl.find.deleteMessage(message, type: 'all');
}

/// Quick bulk delete for me
void quickBulkDeleteForMe(List<String> messageIds) {
  if (messageIds.isNotEmpty) {
    ChatCtrl.find.deleteMultipleMessages(messageIds, type: 'one');
  }
}

/// Quick bulk delete for everyone
void quickBulkDeleteForAll(List<String> messageIds) {
  if (messageIds.isNotEmpty) {
    ChatCtrl.find.deleteMultipleMessages(messageIds, type: 'all');
  }
}

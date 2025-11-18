# Delete Messages Feature - Usage Guide

This guide explains how to use the delete messages feature in the SEP Social App.

## Overview

The delete messages feature allows users to delete messages in two ways:
- **Delete for me**: Only removes the message from your own view
- **Delete for everyone**: Removes the message for all users in the chat

## Backend API

The backend socket event accepts the following payload:

```javascript
socket.emit('deleteMessages', {
  messageIds: ['<messageId1>', '<messageId2>'],  // Array of message IDs
  userId: '<currentUserId>',                      // ID of user performing delete
  chatId: '<chatId>',                             // ID of the chat
  types: 'all' // 'all' = delete for everyone, any other value = delete for me
});
```

### Backend Response

The backend will emit back a response:

```javascript
{
  code: 200,                    // HTTP status code
  message: "Success message",   // Description
  deletedMessages: [            // Array of deleted message objects
    {
      _id: "messageId1",
      content: "...",
      // ... other message properties
    }
  ]
}
```

## Flutter Client Implementation

### 1. Delete Single Message

Use the `deleteMessage` method in `ChatCtrl`:

```dart
import 'package:sep/feature/presentation/controller/chat_ctrl.dart';

// Get the chat controller
final chatCtrl = ChatCtrl.find;

// Delete message for yourself only
chatCtrl.deleteMessage(
  messageObject,
  type: 'one', // Delete for me only
);

// Delete message for everyone
chatCtrl.deleteMessage(
  messageObject,
  type: 'all', // Delete for everyone in the chat
);
```

### 2. Delete Multiple Messages

Use the `deleteMultipleMessages` method for bulk deletion:

```dart
import 'package:sep/feature/presentation/controller/chat_ctrl.dart';

// Get the chat controller
final chatCtrl = ChatCtrl.find;

// List of message IDs to delete
final List<String> messageIds = ['id1', 'id2', 'id3'];

// Delete multiple messages for yourself only
chatCtrl.deleteMultipleMessages(
  messageIds,
  type: 'one', // Delete for me only
);

// Delete multiple messages for everyone
chatCtrl.deleteMultipleMessages(
  messageIds,
  type: 'all', // Delete for everyone in the chat
);
```

### 3. UI Integration Example

Here's how to integrate delete functionality in a chat UI:

```dart
import 'package:flutter/material.dart';
import 'package:sep/feature/presentation/controller/chat_ctrl.dart';
import 'package:sep/feature/data/models/dataModels/chat_msg_model/chat_msg_model.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMsgModel message;
  final bool isMyMessage;

  const ChatMessageWidget({
    Key? key,
    required this.message,
    required this.isMyMessage,
  }) : super(key: key);

  void _showDeleteOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Delete for me'),
            onTap: () {
              Navigator.pop(context);
              ChatCtrl.find.deleteMessage(message, type: 'one');
            },
          ),
          if (isMyMessage) // Only show if it's the user's own message
            ListTile(
              leading: Icon(Icons.delete_forever),
              title: Text('Delete for everyone'),
              onTap: () {
                Navigator.pop(context);
                ChatCtrl.find.deleteMessage(message, type: 'all');
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showDeleteOptions(context),
      child: Container(
        // Your message widget UI here
        child: Text(message.content ?? ''),
      ),
    );
  }
}
```

### 4. Bulk Delete Example

For selecting and deleting multiple messages:

```dart
import 'package:flutter/material.dart';
import 'package:sep/feature/presentation/controller/chat_ctrl.dart';
import 'package:sep/feature/data/models/dataModels/chat_msg_model/chat_msg_model.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Set<String> selectedMessageIds = {};
  bool isSelectionMode = false;

  void toggleSelection(String messageId) {
    setState(() {
      if (selectedMessageIds.contains(messageId)) {
        selectedMessageIds.remove(messageId);
      } else {
        selectedMessageIds.add(messageId);
      }
      
      // Exit selection mode if no messages selected
      if (selectedMessageIds.isEmpty) {
        isSelectionMode = false;
      }
    });
  }

  void deleteSelectedMessages(String type) {
    if (selectedMessageIds.isEmpty) return;
    
    ChatCtrl.find.deleteMultipleMessages(
      selectedMessageIds.toList(),
      type: type,
    );
    
    setState(() {
      selectedMessageIds.clear();
      isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectionMode 
          ? '${selectedMessageIds.length} selected' 
          : 'Chat'),
        actions: isSelectionMode ? [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => deleteSelectedMessages('one'),
            tooltip: 'Delete for me',
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () => deleteSelectedMessages('all'),
            tooltip: 'Delete for everyone',
          ),
        ] : null,
      ),
      body: ListView.builder(
        // Chat messages list
        itemBuilder: (context, index) {
          final message = ChatCtrl.find.chatMessages[index];
          final isSelected = selectedMessageIds.contains(message.id);
          
          return GestureDetector(
            onLongPress: () {
              setState(() {
                isSelectionMode = true;
                toggleSelection(message.id!);
              });
            },
            onTap: isSelectionMode 
              ? () => toggleSelection(message.id!)
              : null,
            child: Container(
              color: isSelected ? Colors.blue.withOpacity(0.2) : null,
              // Your message widget
              child: Text(message.content ?? ''),
            ),
          );
        },
      ),
    );
  }
}
```

## How It Works

### 1. Socket Communication

When you call `deleteMessage` or `deleteMultipleMessages`:
1. The method validates the inputs (message IDs, chatId, userId)
2. Sends a socket event with the data to the server
3. The server processes the deletion
4. Server broadcasts the deletion to all connected clients in that chat

### 2. Real-time Updates

The `deleteMsgListener` in `ChatCtrl` listens for delete confirmations:
1. Receives the deleted message IDs from the server
2. Removes those messages from the local `chatMessages` list
3. Refreshes the UI automatically using GetX reactive programming

### 3. Delete Types

- **type: 'one'** (Delete for me)
  - Backend sets `isDeleted` field to the userId
  - Message is filtered out for that user only
  - Other users can still see the message

- **type: 'all'** (Delete for everyone)
  - Backend completely removes the message from the database
  - Message is deleted for all users in the chat
  - No one can see the message anymore

## Important Notes

1. **Message Validation**: The system validates:
   - Message IDs must be valid MongoDB ObjectIds
   - User must be authenticated
   - Chat ID must exist

2. **Real-time Sync**: All connected users in the chat will see the deletion in real-time

3. **Error Handling**: If deletion fails, the server will emit an error response with code 400 or 500

4. **Permissions**: 
   - Any user can delete messages for themselves ('one')
   - Typically, only message senders should see "delete for everyone" option

## Troubleshooting

### Messages not deleting
- Check if socket is connected: `ChatCtrl.find._repo.isConnected()`
- Verify chatId is set: `ChatCtrl.find.singleChatId`
- Check browser/app console for error messages

### Deletion not updating UI
- Ensure `deleteMsgListener()` is called in `joinSingleChat()`
- Check if the listener is properly set up before sending delete request

### Server errors
- Verify message IDs are valid
- Ensure user is authenticated
- Check backend logs for specific error messages

## Example Implementation

The current implementation can be found in:
- **Controller**: `lib/feature/presentation/controller/chat_ctrl.dart`
- **Repository Interface**: `lib/feature/domain/respository/chat_repo.dart`
- **Repository Implementation**: `lib/feature/data/repository/i_chat_repo.dart`
- **Socket Helper**: `lib/services/socket/socket_helper.dart`
- **UI Example**: `lib/feature/presentation/chatScreens/Chat_Sample.dart`

## Summary

The delete messages feature is fully integrated and ready to use:

✅ Single message deletion  
✅ Bulk message deletion  
✅ Delete for me only  
✅ Delete for everyone  
✅ Real-time updates  
✅ Error handling  
✅ Socket communication  

Simply call the appropriate method from `ChatCtrl` with the message(s) you want to delete and the deletion type.

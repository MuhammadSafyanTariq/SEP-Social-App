# Socket Communication Flow - Delete Messages

## Backend Socket Event Handler

Your backend listens for the `deleteMessages` event:

```javascript
socket.on("deleteMessages", async (bodyData) => {
  let { messageIds, userId, chatId, types } = bodyData;
  
  // Validate and process deletion
  if (types === "all") {
    // Delete for everyone
    await Message.deleteMany({ _id: { $in: messageIds } });
  } else {
    // Delete for me only
    await Message.updateMany(
      { _id: { $in: messageIds } },
      { isDeleted: userId }
    );
  }
  
  // Broadcast to all users in chat
  io.to(chatId.toString()).emit("deleteMessages", {
    code: 200,
    message: "Success",
    deletedMessages: [...],
  });
});
```

## Flutter Client Implementation

### 1. Emit Event (Client → Server)

When you call:
```dart
ChatCtrl.find.deleteMessage(message, type: 'all');
```

It executes:
```dart
// In i_chat_repo.dart
_socket.callEvent(SocketKey.deleteMessages, {
  'messageIds': [messageId],  // Array format
  'userId': Preferences.uid,  // Current user ID
  'chatId': chatId,           // Chat room ID
  'types': type,              // 'all' or 'one'
});
```

Which translates to:
```dart
// In socket_helper.dart
socket.emit('deleteMessages', {
  'messageIds': ['abc123'],
  'userId': 'user456',
  'chatId': 'chat789',
  'types': 'all'
});
```

### 2. Server Processing

Backend receives the event, validates, and processes:
1. Validates message IDs
2. Validates user ID
3. Checks chat permissions
4. Performs deletion (complete removal or soft delete)
5. Broadcasts result to all chat participants

### 3. Listen for Response (Server → Client)

The client listens for the server response:

```dart
// In chat_ctrl.dart - deleteMsgListener()
_repo.deleteMessageListener(
  data: (data) {
    // data = {
    //   code: 200,
    //   message: "Success",
    //   deletedMessages: [{_id: "abc123", ...}]
    // }
    
    final deletedIds = data['deletedMessages']
        .map((msg) => msg['_id'] ?? msg['id'])
        .toList();
    
    // Remove from UI
    chatMessages.removeWhere((msg) => deletedIds.contains(msg.id));
    chatMessages.refresh();
  }
);
```

## Complete Flow Diagram

```
User Action (Delete Message)
         ↓
ChatCtrl.deleteMessage()
         ↓
_repo.deleteMessage()
         ↓
_socket.callEvent()
         ↓
socket.emit('deleteMessages', data)
         ↓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    SOCKET CONNECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
         ↓
Backend receives event
         ↓
Validates data
         ↓
Processes deletion
         ↓
Broadcasts to chat room
         ↓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    SOCKET CONNECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
         ↓
socket.on('deleteMessages')
         ↓
deleteMsgListener() receives data
         ↓
Removes messages from UI
         ↓
UI updates automatically
```

## Data Format Examples

### Single Message Deletion - Client to Server
```json
{
  "messageIds": ["507f1f77bcf86cd799439011"],
  "userId": "507f191e810c19729de860ea",
  "chatId": "507f191e810c19729de860eb",
  "types": "all"
}
```

### Multiple Message Deletion - Client to Server
```json
{
  "messageIds": [
    "507f1f77bcf86cd799439011",
    "507f1f77bcf86cd799439012",
    "507f1f77bcf86cd799439013"
  ],
  "userId": "507f191e810c19729de860ea",
  "chatId": "507f191e810c19729de860eb",
  "types": "one"
}
```

### Server Response Format
```json
{
  "code": 200,
  "message": "Messages deleted for all users successfully",
  "deletedMessages": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "content": "Hello",
      "senderId": "507f191e810c19729de860ea",
      "chatId": "507f191e810c19729de860eb",
      "mediaType": "text",
      "senderTime": "2024-01-15T10:30:00.000Z",
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ]
}
```

## Socket Event Names

Both client and server must use the exact same event name: `deleteMessages`

### Client Side (Flutter)
```dart
enum SocketKey {
  deleteMessages,  // Maps to 'deleteMessages' string
  // ...
}

// Emit
_socket.callEvent(SocketKey.deleteMessages, data);

// Listen
_socket.listen(SocketKey.deleteMessages, handler);
```

### Server Side (Node.js)
```javascript
// Listen
socket.on("deleteMessages", async (bodyData) => {
  // ...
});

// Emit
io.to(chatId).emit("deleteMessages", responseData);
// or
socket.emit("deleteMessages", responseData);
```

## Room Management

The backend emits to the chat room, so **all participants** receive the deletion event:

```javascript
io.to(chatId.toString()).emit("deleteMessages", {
  code: 200,
  message: "Success",
  deletedMessages: [...]
});
```

This means:
- If User A deletes a message for everyone
- Users B, C, D in the same chat will all receive the event
- All clients will update their UI automatically

## Error Handling

### Client Errors
```dart
if (messageId.isEmpty) {
  AppUtils.logEr('❌ Cannot delete: message ID is empty');
  return;
}

if (singleChatId == null) {
  AppUtils.logEr('❌ Cannot delete: chatId is null');
  return;
}
```

### Server Errors
```javascript
// Invalid ObjectId
socket.emit("deleteMessages", {
  code: 400,
  message: "Invalid message ID"
});

// Server error
socket.emit("deleteMessages", {
  code: 500,
  message: "An error occurred: ..."
});
```

### Client Error Handling
```dart
try {
  final code = data['code'];
  if (code != 200) {
    AppUtils.logEr('Delete failed: ${data['message']}');
    return;
  }
  // Process successful deletion
} catch (e) {
  AppUtils.logEr('Error processing delete response: $e');
}
```

## Debug Logging

The implementation includes comprehensive logging:

```dart
// When sending delete request
AppUtils.log('🗑️ Deleting message: $messageId, Type: $type');
AppUtils.log('Socket calling deleteMessage: $messageId, $chatId, $type');

// When receiving response
AppUtils.log('🗑️ Delete message listener called');
AppUtils.log('📥 Delete response data: $data');
AppUtils.log('📊 Response code: $code, message: $message');
AppUtils.log('🗑️ Processing ${deletedIds.length} deleted message(s)');
AppUtils.log('✅ Messages removed from UI. Remaining: ${chatMessages.length}');
```

## Connection State

Before deleting, ensure socket is connected:

```dart
// In chat_ctrl.dart
if (!_repo.isConnected()) {
  AppUtils.logEr('❌ Socket not connected');
  // Attempt reconnection or show error
  return;
}
```

## Summary

The delete messages feature uses WebSocket communication:

1. **Client emits** `deleteMessages` with message IDs
2. **Server processes** the deletion
3. **Server broadcasts** result to all chat participants  
4. **All clients receive** and update their UI

This ensures real-time synchronization across all connected users.

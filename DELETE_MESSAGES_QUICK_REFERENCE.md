# Delete Messages - Quick Reference Card

## 🚀 Quick Start

### Import
```dart
import 'package:sep/feature/presentation/controller/chat_ctrl.dart';
```

### Basic Usage

#### Delete Single Message
```dart
// For me only
ChatCtrl.find.deleteMessage(message, type: 'one');

// For everyone
ChatCtrl.find.deleteMessage(message, type: 'all');
```

#### Delete Multiple Messages
```dart
// For me only
ChatCtrl.find.deleteMultipleMessages(['id1', 'id2'], type: 'one');

// For everyone
ChatCtrl.find.deleteMultipleMessages(['id1', 'id2'], type: 'all');
```

## 📋 Parameter Reference

| Parameter | Type | Values | Description |
|-----------|------|--------|-------------|
| `message` | `ChatMsgModel` | Message object | The message to delete |
| `messageIds` | `List<String>` | Array of IDs | Message IDs for bulk delete |
| `type` | `String` | `'one'` or `'all'` | Deletion scope |

## 🎯 Type Values

| Type | Effect | Backend Action |
|------|--------|----------------|
| `'one'` | Delete for me only | Sets `isDeleted` field to userId |
| `'all'` | Delete for everyone | Removes message from database |

## 📡 Socket Event Details

### Event Name
```
'deleteMessages'
```

### Client → Server Payload
```json
{
  "messageIds": ["<id1>", "<id2>"],
  "userId": "<currentUserId>",
  "chatId": "<chatId>",
  "types": "all" or "one"
}
```

### Server → Client Response
```json
{
  "code": 200,
  "message": "Success message",
  "deletedMessages": [{...message objects...}]
}
```

## ✅ Validation Checklist

Before deleting, ensure:
- ✅ Message ID is not null/empty
- ✅ Chat ID is available (`singleChatId != null`)
- ✅ Socket is connected
- ✅ User is authenticated

## 🎨 UI Integration Example

```dart
GestureDetector(
  onLongPress: () {
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
  },
  child: MessageWidget(message: message),
)
```

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| Messages not deleting | Check socket connection: `_repo.isConnected()` |
| UI not updating | Ensure `deleteMsgListener()` is called |
| "Invalid ID" error | Verify message ID is valid MongoDB ObjectId |
| "Chat ID null" error | Ensure you're inside an active chat |

## 📁 Key Files

| File | Purpose |
|------|---------|
| `chat_ctrl.dart` | Controller with delete methods |
| `i_chat_repo.dart` | Repository implementation |
| `socket_helper.dart` | Socket communication |
| `Chat_Sample.dart` | Example UI implementation |

## 🎓 Code Examples

See these files for detailed examples:
- `DELETE_MESSAGES_USAGE_GUIDE.md` - Full documentation
- `lib/examples/delete_messages_examples.dart` - 10+ examples
- `SOCKET_COMMUNICATION_DELETE_MESSAGES.md` - Socket details

## ⚡ Quick Tips

1. **Always validate before delete**
   ```dart
   if (message.id != null && singleChatId != null) {
     ChatCtrl.find.deleteMessage(message, type: 'one');
   }
   ```

2. **Use bulk delete for multiple messages**
   ```dart
   final ids = selectedMessages.map((m) => m.id!).toList();
   ChatCtrl.find.deleteMultipleMessages(ids, type: 'one');
   ```

3. **Show confirmation for "delete for everyone"**
   ```dart
   if (type == 'all') {
     showDialog(...); // Confirm before deleting
   }
   ```

4. **Only show "delete for everyone" for own messages**
   ```dart
   if (message.sender?.id == Preferences.uid) {
     // Show delete for everyone option
   }
   ```

## 🚨 Important Notes

- ⚠️ "Delete for everyone" is **permanent** and cannot be undone
- ⚠️ All chat participants will see the deletion in real-time
- ⚠️ "Delete for me" only hides the message for you
- ⚠️ Message IDs must be valid MongoDB ObjectIds

## 📊 Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 400 | Invalid request (bad message ID, etc.) |
| 500 | Server error |

## 🔗 Related Methods

```dart
// Join chat (prerequisite)
ChatCtrl.find.joinSingleChat(userId, chatId);

// Send message
ChatCtrl.find.sendTextMsg("Hello");

// Leave chat (cleanup)
ChatCtrl.find.onLeaveChatRoom();
```

---

**Need help?** Check the detailed documentation in:
- DELETE_MESSAGES_USAGE_GUIDE.md
- SOCKET_COMMUNICATION_DELETE_MESSAGES.md

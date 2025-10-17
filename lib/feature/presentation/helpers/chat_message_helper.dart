import '../../../services/storage/preferences.dart';
import '../../data/models/dataModels/chat_msg_model/chat_msg_model.dart';
import '../controller/auth_Controller/profileCtrl.dart';

class ChatMessageHelper {
  /// Determines if a message was sent by the current user
  static bool isMessageSentByCurrentUser(ChatMsgModel message) {
    final currentUserId = Preferences.uid;
    final currentProfileId = ProfileCtrl.find.profileData.value.id;
    final messageSenderId = message.sender?.id;

    // Log for debugging
    print('🔍 ChatMessageHelper Debug:');
    print('  Current User ID: $currentUserId');
    print('  Current Profile ID: $currentProfileId');
    print('  Message Sender ID: $messageSenderId');
    print('  Message Sender Name: ${message.sender?.name}');
    print('  Message Content: ${message.content}');

    if (messageSenderId == null || currentUserId == null) {
      print('  ❌ Null IDs detected, returning false');
      return false;
    }

    // Primary check with preferences uid
    if (messageSenderId == currentUserId) {
      print('  ✅ Match with Preferences.uid');
      return true;
    }

    // Secondary check with profile id
    if (currentProfileId != null && messageSenderId == currentProfileId) {
      print('  ✅ Match with Profile ID');
      return true;
    }

    // Check if the message ID starts with temp_ (our temporary messages)
    if (message.id?.startsWith('temp_') == true) {
      print('  ✅ Temporary message detected');
      return true;
    }

    print('  ❌ No match found, returning false');
    return false;
  }

  /// Creates a proper sender object for outgoing messages
  static Sender createCurrentUserSender() {
    return Sender(
      id: Preferences.uid,
      name: ProfileCtrl.find.profileData.value.name,
    );
  }
}

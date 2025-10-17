import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/feature/presentation/controller/chat_ctrl.dart';
import 'package:sep/feature/presentation/helpers/chat_message_helper.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import '../controller/auth_Controller/profileCtrl.dart';

class ChatDebugScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Debug Info'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current User Info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: 'Current User Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Obx(() {
                    final profile = ProfileCtrl.find.profileData.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: 'Preferences UID: ${Preferences.uid ?? "null"}',
                        ),
                        TextView(text: 'Profile ID: ${profile.id ?? "null"}'),
                        TextView(
                          text: 'Profile Name: ${profile.name ?? "null"}',
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Recent Messages Analysis
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: 'Recent Messages Analysis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Obx(() {
                    final messages = ChatCtrl.find.chatMessages
                        .take(5)
                        .toList();
                    if (messages.isEmpty) {
                      return TextView(text: 'No messages available');
                    }

                    return Column(
                      children: messages.map((message) {
                        final isSentByUser =
                            ChatMessageHelper.isMessageSentByCurrentUser(
                              message,
                            );
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSentByUser
                                ? Colors.blue[100]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextView(
                                text: 'Content: ${message.content ?? "null"}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextView(
                                text:
                                    'Sender ID: ${message.sender?.id ?? "null"}',
                              ),
                              TextView(
                                text:
                                    'Sender Name: ${message.sender?.name ?? "null"}',
                              ),
                              TextView(
                                text: 'Is Sent By User: $isSentByUser',
                                style: TextStyle(
                                  color: isSentByUser
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextView(
                                text:
                                    'Should align: ${isSentByUser ? "RIGHT" : "LEFT"}',
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Test Actions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: 'Test Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      AppUtils.log('=== CHAT DEBUG INFO ===');
                      AppUtils.log('Preferences UID: ${Preferences.uid}');
                      AppUtils.log(
                        'Profile ID: ${ProfileCtrl.find.profileData.value.id}',
                      );
                      AppUtils.log(
                        'Profile Name: ${ProfileCtrl.find.profileData.value.name}',
                      );
                      AppUtils.log(
                        'Recent messages count: ${ChatCtrl.find.chatMessages.length}',
                      );

                      for (
                        int i = 0;
                        i < ChatCtrl.find.chatMessages.length && i < 3;
                        i++
                      ) {
                        final msg = ChatCtrl.find.chatMessages[i];
                        final isSentByUser =
                            ChatMessageHelper.isMessageSentByCurrentUser(msg);
                        AppUtils.log('Message $i:');
                        AppUtils.log('  Content: ${msg.content}');
                        AppUtils.log('  Sender ID: ${msg.sender?.id}');
                        AppUtils.log('  Is sent by user: $isSentByUser');
                      }
                    },
                    child: Text('Log Debug Info to Console'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppBar2.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/chatbot_message_model.dart';
import 'package:sep/feature/presentation/controller/chatbot_controller.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with TickerProviderStateMixin {
  late ChatBotController controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Initialize controller
    controller = Get.put(ChatBotController());

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // App Bar
          AppBar2(
            title: "AI Assistant",
            titleStyle: 18.txtMediumBlack,
            prefixImage: "back",
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: Colors.white,
            hasTopSafe: true,
            suffixWidget: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppColors.primaryColor),
              onSelected: (value) {
                if (value == 'clear') {
                  _showClearChatDialog();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: AppColors.grey),
                      SizedBox(width: 8),
                      Text('Clear Chat'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: Obx(
              () => controller.messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: controller.scrollController,
                      padding: EdgeInsets.all(16.sdp),
                      itemCount:
                          controller.messages.length +
                          (controller.isTyping.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.messages.length) {
                          return _buildTypingIndicator();
                        }

                        final message = controller.messages[index];
                        return _buildMessageBubble(message);
                      },
                    ),
            ),
          ),

          // Input Field
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.sdp,
            height: 80.sdp,
            decoration: BoxDecoration(
              color: AppColors.btnColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              size: 40.sdp,
              color: AppColors.btnColor,
            ),
          ),
          SizedBox(height: 16.sdp),
          TextView(text: "AI Assistant", style: 24.txtSBoldprimary),
          SizedBox(height: 8.sdp),
          TextView(
            text: "Ask me anything! I'm here to help.",
            style: 16.txtMediumgrey,
            textAlign: TextAlign.center,
            margin: EdgeInsets.symmetric(horizontal: 32.sdp),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatBotMessage message) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.sdp),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            // Bot Avatar
            Container(
              width: 32.sdp,
              height: 32.sdp,
              decoration: BoxDecoration(
                color: AppColors.btnColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: Colors.white, size: 18.sdp),
            ),
            SizedBox(width: 8.sdp),
          ],

          // Message Content
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16.sdp,
                vertical: 12.sdp,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.btnColor
                    : AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.sdp),
                  topRight: Radius.circular(16.sdp),
                  bottomLeft: Radius.circular(message.isUser ? 16.sdp : 4.sdp),
                  bottomRight: Radius.circular(message.isUser ? 4.sdp : 16.sdp),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: message.content,
                    style: message.isUser
                        ? 14.txtMediumWhite
                        : 14.txtMediumBlack,
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 4.sdp),
                  TextView(
                    text: controller.getMessageTime(message.timestamp),
                    style: message.isUser
                        ? 10.txtRegularWhite.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          )
                        : 10.txtRegularGrey.copyWith(
                            color: AppColors.grey.withOpacity(0.7),
                          ),
                  ),
                ],
              ),
            ),
          ),

          if (message.isUser) ...[
            SizedBox(width: 8.sdp),
            // User Avatar
            Container(
              width: 32.sdp,
              height: 32.sdp,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.white, size: 18.sdp),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.sdp),
      child: Row(
        children: [
          // Bot Avatar
          Container(
            width: 32.sdp,
            height: 32.sdp,
            decoration: BoxDecoration(
              color: AppColors.btnColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.smart_toy, color: Colors.white, size: 18.sdp),
          ),
          SizedBox(width: 8.sdp),

          // Typing Animation
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.sdp, vertical: 12.sdp),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.sdp),
                topRight: Radius.circular(16.sdp),
                bottomLeft: Radius.circular(4.sdp),
                bottomRight: Radius.circular(16.sdp),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                SizedBox(width: 4.sdp),
                _buildTypingDot(1),
                SizedBox(width: 4.sdp),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale:
              (0.5 +
              0.5 *
                  (_animationController.value * 3 - index).abs().clamp(
                    0.0,
                    1.0,
                  )),
          child: Container(
            width: 6.sdp,
            height: 6.sdp,
            decoration: BoxDecoration(
              color: AppColors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.all(16.sdp),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24.sdp),
                  border: Border.all(color: AppColors.grey.withOpacity(0.2)),
                ),
                child: TextField(
                  controller: controller.messageController,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    hintStyle: 14.txtMediumgrey,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.sdp,
                      vertical: 12.sdp,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.sdp),
            Obx(
              () => GestureDetector(
                onTap: controller.isTyping.value ? null : _sendMessage,
                child: Container(
                  width: 48.sdp,
                  height: 48.sdp,
                  decoration: BoxDecoration(
                    color: controller.isTyping.value
                        ? AppColors.grey
                        : AppColors.btnColor,
                    shape: BoxShape.circle,
                  ),
                  child: controller.isTyping.value
                      ? SizedBox(
                          width: 20.sdp,
                          height: 20.sdp,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(Icons.send, color: Colors.white, size: 20.sdp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final message = controller.messageController.text.trim();
    if (message.isNotEmpty && !controller.isTyping.value) {
      controller.sendMessage(message);
    }
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear Chat"),
        content: Text("Are you sure you want to clear all messages?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              controller.clearChat();
              Navigator.pop(context);
              AppUtils.toast("Chat cleared");
            },
            child: Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

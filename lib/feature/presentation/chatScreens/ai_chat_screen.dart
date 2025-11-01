import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/AppBar2.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/services/database/ai_chat_database.dart';
import 'package:sep/services/openai/openai_service.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';

class AIChatScreen extends StatefulWidget {
  final String chatType; // 'inbox' or 'contact'

  const AIChatScreen({Key? key, this.chatType = 'inbox'}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OpenAIService _openAIService = OpenAIService.instance;
  final AIChatDatabase _database = AIChatDatabase.instance;

  List<AIChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);

    try {
      _openAIService.initialize();

      // Load existing messages from database
      final messages = await _database.getMessages(widget.chatType);

      if (messages.isEmpty) {
        // Add welcome message if it's a new chat
        final welcomeMessage = AIChatMessage(
          message: _openAIService.getWelcomeMessage(),
          isUser: false,
          timestamp: DateTime.now(),
          chatType: widget.chatType,
        );
        await _database.insertMessage(welcomeMessage);
        messages.add(welcomeMessage);
      }

      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      AppUtils.log('Error initializing chat: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    AppUtils.log('Sending message: $text');

    setState(() {
      _isSending = true;
    });

    try {
      // Add user message
      final userMessage = AIChatMessage(
        message: text,
        isUser: true,
        timestamp: DateTime.now(),
        chatType: widget.chatType,
      );

      final messageId = await _database.insertMessage(userMessage);
      AppUtils.log('User message saved with ID: $messageId');

      setState(() {
        _messages.add(userMessage);
        _messageController.clear();
      });

      AppUtils.log('Total messages after user message: ${_messages.length}');
      _scrollToBottom();

      // Prepare conversation history for context
      final conversationHistory = _messages
          .where((msg) => msg.message != _openAIService.getWelcomeMessage())
          .map(
            (msg) => {
              'role': msg.isUser ? 'user' : 'assistant',
              'content': msg.message,
            },
          )
          .toList();

      // Get AI response
      final aiResponse = await _openAIService.sendMessage(
        text,
        conversationHistory,
      );

      AppUtils.log('AI response received: $aiResponse');

      // Add AI message
      final aiMessage = AIChatMessage(
        message: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
        chatType: widget.chatType,
      );

      final aiMessageId = await _database.insertMessage(aiMessage);
      AppUtils.log('AI message saved with ID: $aiMessageId');

      setState(() {
        _messages.add(aiMessage);
        _isSending = false;
      });

      AppUtils.log('Total messages after AI response: ${_messages.length}');
      _scrollToBottom();
    } catch (e) {
      AppUtils.log('Error sending message: $e');
      AppUtils.toastError('Failed to send message');
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSuggestedQuestions() {
    final suggestions = _openAIService.getSuggestedQuestions();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sdp)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20.sdp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Suggested Questions', style: 18.txtSBoldprimary),
              16.height,
              ...suggestions.map((question) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _messageController.text = question;
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.sdp),
                    margin: EdgeInsets.only(bottom: 8.sdp),
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.sdp),
                      border: Border.all(
                        color: AppColors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(question, style: 14.txtRegularprimary),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppBar2(
              prefixImage: AppImages.backBtn,
              leadIconSize: 16,
              onPrefixTap: () => Navigator.pop(context),
              title: 'AI Assistant',
              titleAlign: TextAlign.center,
              titleStyle: 20.txtSBoldprimary,
              backgroundColor: AppColors.white,
              suffixWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.help_outline, color: AppColors.btnColor),
                    onPressed: _showSuggestedQuestions,
                    tooltip: 'Suggested Questions',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: AppColors.red),
                    onPressed: _confirmClearChat,
                    tooltip: 'Clear Chat',
                  ),
                ],
              ),
            ),

            // Bot info
            Container(
              padding: EdgeInsets.all(12.sdp),
              color: AppColors.btnColor.withOpacity(0.1),
              child: Row(
                children: [
                  ImageView(url: AppImages.bot, size: 40.sdp),
                  12.width,
                  Expanded(
                    child: Text(
                      'Your AI Assistant for SEP Social App',
                      style: 14.txtMediumgrey,
                    ),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                  ? Center(
                      child: Text('No messages yet', style: 14.txtMediumgrey),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16.sdp),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        AppUtils.log(
                          'Rendering message $index: isUser=${message.isUser}, text=${message.message.substring(0, message.message.length > 20 ? 20 : message.message.length)}...',
                        );
                        return _buildMessageBubble(message);
                      },
                    ),
            ),

            // Typing indicator
            if (_isSending)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.sdp),
                child: Row(
                  children: [
                    ImageView(url: AppImages.bot, size: 24.sdp),
                    8.width,
                    Text('AI is typing...', style: 12.txtMediumgrey),
                  ],
                ),
              ),

            // Input field
            Container(
              padding: EdgeInsets.all(12.sdp),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.sdp),
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25.sdp),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          hintStyle: 14.txtRegularGrey,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  8.width,
                  InkWell(
                    onTap: _isSending ? null : _sendMessage,
                    child: Container(
                      padding: EdgeInsets.all(12.sdp),
                      decoration: BoxDecoration(
                        color: _isSending ? AppColors.grey : AppColors.btnColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send,
                        color: AppColors.white,
                        size: 20.sdp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AIChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.sdp),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              ImageView(url: AppImages.bot, size: 32.sdp),
              8.width,
            ],
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
                      : AppColors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.sdp),
                    topRight: Radius.circular(16.sdp),
                    bottomLeft: message.isUser
                        ? Radius.circular(16.sdp)
                        : Radius.circular(4.sdp),
                    bottomRight: message.isUser
                        ? Radius.circular(4.sdp)
                        : Radius.circular(16.sdp),
                  ),
                  boxShadow: message.isUser
                      ? [
                          BoxShadow(
                            color: AppColors.btnColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.message,
                      style: message.isUser
                          ? TextStyle(
                              color: Colors.white,
                              fontSize: 14.sdp,
                              fontWeight: FontWeight.w500,
                            )
                          : 14.txtRegularprimary,
                    ),
                    4.height,
                    Text(
                      _formatTime(message.timestamp),
                      style: message.isUser
                          ? TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10.sdp,
                            )
                          : 10.txtMediumgrey,
                    ),
                  ],
                ),
              ),
            ),
            if (message.isUser) ...[
              8.width,
              Container(
                width: 32.sdp,
                height: 32.sdp,
                decoration: BoxDecoration(
                  color: AppColors.btnColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 20.sdp,
                  color: AppColors.btnColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _confirmClearChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat', style: 18.txtSBoldprimary),
        content: Text(
          'Are you sure you want to clear all messages? This action cannot be undone.',
          style: 14.txtRegularprimary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: 14.txtMediumbtncolor),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Clear',
              style: 14.txtMediumWhite.copyWith(color: AppColors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _database.deleteAllMessages(widget.chatType);
      await _initializeChat();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

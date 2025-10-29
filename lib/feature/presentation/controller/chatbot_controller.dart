import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sep/feature/data/models/dataModels/chatbot_message_model.dart';
import 'package:sep/services/openai_service.dart';
import 'package:sep/utils/appUtils.dart';

class ChatBotController extends GetxController {
  static ChatBotController get find => Get.find<ChatBotController>();

  // Observable list of messages
  final RxList<ChatBotMessage> messages = <ChatBotMessage>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool isTyping = false.obs;

  // Text controller for input field
  final TextEditingController messageController = TextEditingController();

  // Scroll controller for message list
  final ScrollController scrollController = ScrollController();

  // Storage key for chat history
  static const String _storageKey = 'chatbot_messages';

  @override
  void onInit() {
    super.onInit();
    _loadChatHistory();
    _addGreetingMessage();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Load chat history from local storage
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? messagesJson = prefs.getString(_storageKey);

      if (messagesJson != null) {
        final List<dynamic> messagesList = json.decode(messagesJson);
        final List<ChatBotMessage> loadedMessages = messagesList
            .map((messageMap) => ChatBotMessage.fromMap(messageMap))
            .toList();

        messages.assignAll(loadedMessages);
        AppUtils.log('Loaded ${loadedMessages.length} messages from storage');
      }
    } catch (e) {
      AppUtils.log('Error loading chat history: $e');
    }
  }

  /// Save chat history to local storage
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> messagesMap = messages
          .map((message) => message.toMap())
          .toList();

      await prefs.setString(_storageKey, json.encode(messagesMap));
      AppUtils.log('Saved ${messages.length} messages to storage');
    } catch (e) {
      AppUtils.log('Error saving messages: $e');
    }
  }

  /// Add greeting message if no messages exist
  void _addGreetingMessage() {
    if (messages.isEmpty) {
      final greetingMessage = ChatBotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: OpenAIService.getGreetingMessage(),
        isUser: false,
        timestamp: DateTime.now(),
      );

      messages.add(greetingMessage);
      _saveMessages();
    }
  }

  /// Send a message to the chatbot
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatBotMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    messages.add(userMessage);
    messageController.clear();

    // Add typing indicator
    isTyping.value = true;

    // Scroll to bottom
    _scrollToBottom();

    try {
      // Prepare messages for API
      final apiMessages = OpenAIService.formatMessagesForAPI(messages);

      // Get response from OpenAI
      final response = await OpenAIService.sendMessage(apiMessages);

      // Add bot response
      final botMessage = ChatBotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      messages.add(botMessage);
    } catch (e) {
      AppUtils.log('Error sending message: $e');

      // Add error message
      final errorMessage = ChatBotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            'Sorry, I\'m having trouble responding right now. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      messages.add(errorMessage);
    } finally {
      isTyping.value = false;
      _saveMessages();
      _scrollToBottom();
    }
  }

  /// Clear all chat messages
  Future<void> clearChat() async {
    messages.clear();
    _addGreetingMessage();
    await _saveMessages();
  }

  /// Scroll to bottom of message list
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Get formatted time for message
  String getMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Get total message count
  int get messageCount => messages.length;

  /// Get user message count
  int get userMessageCount => messages.where((m) => m.isUser).length;

  /// Get bot message count
  int get botMessageCount => messages.where((m) => !m.isUser).length;
}

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sep/utils/appUtils.dart';

class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();

  static OpenAIService get instance => _instance;

  late OpenAI _openAI;
  bool _initialized = false;

  // Get API Key from environment variables
  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  // System prompt for the AI assistant
  static const String _systemPrompt = '''
You are a helpful AI assistant for the SEP Social App. Your role is to:

1. Help users understand how to use the app
2. Answer questions about app features including:
   - Social networking features (posts, likes, comments, sharing)
   - Messaging and chat functionality
   - Profile management
   - Live streaming
   - Wallet and coins system
   - Gaming features
   - Sports products
   - Settings and privacy options
3. Provide friendly and concise responses
4. Guide users through app navigation
5. Help troubleshoot common issues

Key App Features:
- Home Feed: View and interact with posts from friends
- Messages: Chat with other users in real-time
- Profile: Manage your personal information and settings
- Live Streaming: Go live or watch others' streams
- Wallet: Manage your coins and transactions
- Games: Play various mini-games within the app
- Sports Products: Browse and purchase sports-related items
- Notifications: Stay updated with activity notifications

Be friendly, helpful, and provide clear step-by-step guidance when needed.
''';

  void initialize() {
    if (!_initialized) {
      if (_apiKey.isEmpty) {
        AppUtils.log('ERROR: OpenAI API Key not found in .env file');
        throw Exception(
          'OpenAI API Key is missing. Please add OPENAI_API_KEY to your .env file',
        );
      }

      // Debug API key format
      AppUtils.log('API Key loaded: ${_apiKey.substring(0, 15)}...');
      AppUtils.log(
        'API Key format: ${_apiKey.startsWith('sk-proj-') ? 'Project API Key ✅' : 'Legacy/Invalid format ❌'}',
      );
      AppUtils.log('API Key length: ${_apiKey.length}');

      _openAI = OpenAI.instance.build(
        token: _apiKey,
        baseOption: HttpSetup(
          receiveTimeout: const Duration(seconds: 30),
          connectTimeout: const Duration(seconds: 30),
        ),
        enableLog: true,
      );
      _initialized = true;
      AppUtils.log('OpenAI Service initialized successfully');
    }
  }

  Future<String> sendMessage(
    String userMessage,
    List<Map<String, String>> conversationHistory,
  ) async {
    try {
      if (!_initialized) {
        initialize();
      }

      AppUtils.log('Sending message to OpenAI: $userMessage');
      AppUtils.log('API Key (first 10 chars): ${_apiKey.substring(0, 10)}...');

      // Filter out duplicate consecutive messages and limit history
      final filteredHistory = <Map<String, String>>[];
      String? lastRole;
      String? lastContent;

      for (final msg in conversationHistory) {
        final role = msg['role'];
        final content = msg['content'];

        // Skip if it's the same as the last message
        if (role == lastRole && content == lastContent) {
          continue;
        }

        lastRole = role;
        lastContent = content;
        filteredHistory.add(msg);
      }

      // Keep only the last 10 messages for context (5 exchanges)
      final recentHistory = filteredHistory.length > 10
          ? filteredHistory.sublist(filteredHistory.length - 10)
          : filteredHistory;

      // Build messages list with system prompt and conversation history
      final List<Map<String, String>> messages = [
        {'role': 'system', 'content': _systemPrompt},
        ...recentHistory,
      ];

      AppUtils.log('Conversation history: ${messages.length} messages');

      // Use GPT-3.5-turbo model (current supported version)
      final request = ChatCompleteText(
        messages: messages,
        maxToken: 500,
        model: GptTurboChatModel(), // Using the current GPT-3.5-turbo model
        temperature: 0.7,
      );

      AppUtils.log('Making API request to OpenAI...');
      final response = await _openAI.onChatCompletion(request: request);

      if (response != null && response.choices.isNotEmpty) {
        final message = response.choices.first.message;
        final content = message?.content;

        if (content != null && content.trim().isNotEmpty) {
          AppUtils.log('AI Response received: ${content.trim()}');
          return content.trim();
        } else {
          AppUtils.log('OpenAI response content was empty');
          return 'Sorry, I could not generate a response. Please try again.';
        }
      } else {
        AppUtils.log('OpenAI response was null or empty');
        return 'Sorry, I could not generate a response. Please try again.';
      }
    } catch (e) {
      AppUtils.log('Error sending message to OpenAI: $e');
      AppUtils.log('Error type: ${e.runtimeType}');

      // Return simple user-friendly messages instead of detailed error logs
      if (e.toString().contains('401') ||
          e.toString().contains('invalid_api_key')) {
        return '⚠️ API Key Error: Please check your OpenAI API key in the .env file and make sure it\'s valid.';
      } else if (e.toString().contains('429')) {
        return 'Sorry, I\'m a bit busy right now. Please wait a moment and try again.';
      } else if (e.toString().contains('insufficient_quota')) {
        return 'Sorry, the API quota has been exceeded. Please check your OpenAI account.';
      } else if (e.toString().contains('404') ||
          e.toString().contains('model_not_found') ||
          e.toString().contains('deprecated')) {
        return 'Sorry, I\'m experiencing some technical difficulties. Please try again later.';
      } else {
        return 'Sorry, I couldn\'t process your message right now. Please try again later.';
      }
    }
  }

  /// Test the API key and connection
  Future<bool> testConnection() async {
    try {
      if (!_initialized) {
        initialize();
      }

      AppUtils.log('Testing OpenAI connection...');
      AppUtils.log(
        'API Key format: ${_apiKey.startsWith('sk-proj-') ? 'Project key (correct)' : 'Legacy key (might cause issues)'}',
      );

      final testRequest = ChatCompleteText(
        messages: [
          {'role': 'user', 'content': 'Hello, just testing the connection.'},
        ],
        maxToken: 10,
        model: GptTurboChatModel(), // Using the same current model
        temperature: 0.1,
      );

      final response = await _openAI.onChatCompletion(request: testRequest);

      if (response != null && response.choices.isNotEmpty) {
        AppUtils.log('✅ OpenAI connection test successful');
        return true;
      } else {
        AppUtils.log('❌ OpenAI connection test failed - empty response');
        return false;
      }
    } catch (e) {
      AppUtils.log('❌ OpenAI connection test failed: $e');
      return false;
    }
  }

  String getWelcomeMessage() {
    return '''
👋 Hello! I'm your SEP Social App assistant!

I'm here to help you with:
• Understanding app features
• Navigation guidance
• Troubleshooting issues
• Answering your questions

How can I assist you today?
''';
  }

  List<String> getSuggestedQuestions() {
    return [
      'How do I create a post?',
      'How does the wallet system work?',
      'How can I start a live stream?',
      'How do I change my profile settings?',
      'What games are available?',
      'How do I report a bug?',
    ];
  }
}

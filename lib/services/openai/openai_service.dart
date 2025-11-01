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

      // Build messages list with system prompt and conversation history
      final List<Map<String, String>> messages = [
        {'role': 'system', 'content': _systemPrompt},
        ...conversationHistory,
        {'role': 'user', 'content': userMessage},
      ];

      final request = ChatCompleteText(
        messages: messages,
        maxToken: 500,
        model: Gpt4ChatModel(),
        temperature: 0.7,
      );

      final response = await _openAI.onChatCompletion(request: request);

      if (response != null && response.choices.isNotEmpty) {
        final content =
            response.choices.first.message?.content ??
            'Sorry, I could not generate a response.';
        AppUtils.log('AI Response: $content');
        return content;
      } else {
        return 'Sorry, I could not generate a response. Please try again.';
      }
    } catch (e) {
      AppUtils.log('Error sending message to OpenAI: $e');
      return 'Sorry, there was an error processing your request. Please try again later.';
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

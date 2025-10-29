import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sep/feature/data/models/dataModels/chatbot_message_model.dart';
import 'package:sep/utils/appUtils.dart';

class OpenAIService {
  // TODO: Replace with your actual OpenAI API key
  // You should store this in a secure way (environment variables, secure storage, etc.)
  static const String _apiKey = "";
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-3.5-turbo';

  /// Get the initial greeting message
  static String getGreetingMessage() {
    return "Hello! I'm your AI assistant. How can I help you today?";
  }

  /// Format messages for OpenAI API
  static List<Map<String, dynamic>> formatMessagesForAPI(
    List<ChatBotMessage> messages,
  ) {
    // Add system message first
    final apiMessages = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content':
            'You are a helpful AI assistant. Provide clear, concise, and friendly responses.',
      },
    ];

    // Convert chat messages to API format
    for (final message in messages) {
      apiMessages.add({
        'role': message.isUser ? 'user' : 'assistant',
        'content': message.content,
      });
    }

    return apiMessages;
  }

  /// Send message to OpenAI and get response
  static Future<String> sendMessage(List<Map<String, dynamic>> messages) async {
    try {
      // Check if API key is configured
      if (_apiKey == 'YOUR_OPENAI_API_KEY') {
        AppUtils.log('OpenAI API key not configured');
        return _getMockResponse(messages);
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': _model,
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        return content.toString().trim();
      } else {
        AppUtils.log(
          'OpenAI API Error: ${response.statusCode} - ${response.body}',
        );
        return _getMockResponse(messages);
      }
    } catch (e) {
      AppUtils.log('OpenAI Service Error: $e');
      return _getMockResponse(messages);
    }
  }

  /// Get mock response for testing or when API is unavailable
  static String _getMockResponse(List<Map<String, dynamic>> messages) {
    // Get the last user message
    final lastUserMessage = messages.lastWhere(
      (msg) => msg['role'] == 'user',
      orElse: () => {'content': ''},
    );

    final userMessage =
        lastUserMessage['content']?.toString().toLowerCase() ?? '';

    // Simple mock responses based on keywords
    if (userMessage.contains('hello') || userMessage.contains('hi')) {
      return "Hello! How can I assist you today?";
    } else if (userMessage.contains('how are you')) {
      return "I'm doing great, thank you for asking! How can I help you?";
    } else if (userMessage.contains('help')) {
      return "I'm here to help! You can ask me questions, and I'll do my best to provide useful answers.";
    } else if (userMessage.contains('thank')) {
      return "You're welcome! Is there anything else I can help you with?";
    } else if (userMessage.contains('bye') || userMessage.contains('goodbye')) {
      return "Goodbye! Feel free to come back anytime you need assistance.";
    } else if (userMessage.contains('weather')) {
      return "I don't have access to real-time weather data, but you can check your local weather service for accurate information.";
    } else if (userMessage.contains('time') || userMessage.contains('date')) {
      final now = DateTime.now();
      return "The current time is ${now.hour}:${now.minute.toString().padLeft(2, '0')} and today's date is ${now.day}/${now.month}/${now.year}.";
    } else {
      return "Thank you for your message. I understand you said: \"${lastUserMessage['content']}\". "
          "How can I assist you with that? (Note: This is a mock response. Configure your OpenAI API key for real AI responses.)";
    }
  }

  /// Validate API key format
  static bool isApiKeyValid() {
    return _apiKey != 'YOUR_OPENAI_API_KEY' &&
        _apiKey.isNotEmpty &&
        _apiKey.startsWith('sk-');
  }

  /// Get API configuration status
  static Map<String, dynamic> getStatus() {
    return {
      'apiKeyConfigured': isApiKeyValid(),
      'model': _model,
      'apiUrl': _apiUrl,
    };
  }
}

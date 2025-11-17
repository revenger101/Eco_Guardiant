import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

/// Service for interacting with local Ollama LLM server
/// Handles chat completions, streaming responses, and error handling
class OllamaService {
  static final OllamaService _instance = OllamaService._internal();
  factory OllamaService() => _instance;
  OllamaService._internal();

  // Ollama server configuration
  // Use 10.0.2.2 for Android emulator to access host machine's localhost
  // Use localhost for other platforms
  static String get _baseUrl {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:11434';
      }
    } catch (e) {
      // If Platform is not available (web), use localhost
    }
    return 'http://localhost:11434';
  }

  static const String _modelName = 'llama3:8b';
  static const Duration _timeout = Duration(seconds: 60);

  // System prompt for eco-friendly context
  static const String _systemPrompt = '''You are an Eco Guardian AI assistant for an environmental protection app called "Eco Guardians". 
Your role is to:
1. Provide helpful eco-friendly tips and sustainability advice
2. Answer questions about environmental protection and conservation
3. Give guidance on the app's eco-games (Beach Cleanup, Forest Guardian, Ocean Savior, Climate Warrior, Eco City Builder, Wildlife Rescue)
4. Encourage users to take action for the environment
5. Be friendly, encouraging, and educational

Keep responses concise (2-3 sentences max), use emojis occasionally 🌱🌍♻️, and focus on actionable advice.
If asked about game strategies, provide specific tips for earning points and completing challenges , also you can use arabic language.''';

  /// Check if Ollama server is running and accessible
  Future<bool> isServerAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tags'),
      ).timeout(_timeout);
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Check if the specified model is available
  Future<bool> isModelAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tags'),
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models = data['models'] as List<dynamic>?;
        
        if (models != null) {
          return models.any((model) => 
            (model['name'] as String).startsWith(_modelName)
          );
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Send a chat message and get a response (non-streaming)
  /// Returns the AI response text or null if failed
  Future<String?> sendMessage(String userMessage, {List<Map<String, String>>? conversationHistory}) async {
    try {
      // Build messages array with system prompt and conversation history
      final messages = <Map<String, String>>[
        {'role': 'system', 'content': _systemPrompt},
      ];

      // Add conversation history if provided
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        messages.addAll(conversationHistory);
      }

      // Add current user message
      messages.add({'role': 'user', 'content': userMessage});

      final response = await http.post(
        Uri.parse('$_baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'model': _modelName,
          'messages': messages,
          'stream': false,
          'options': {
            'temperature': 0.7,
            'top_p': 0.9,
            'num_predict': 150, // Limit response length for concise answers
          },
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messageContent = data['message']?['content'] as String?;
        return messageContent?.trim();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Send a chat message and get a streaming response
  /// Calls onChunk for each piece of text received
  /// Calls onComplete when done, onError if failed
  Future<void> sendMessageStreaming({
    required String userMessage,
    List<Map<String, String>>? conversationHistory,
    required Function(String chunk) onChunk,
    required Function(String fullResponse) onComplete,
    required Function(String error) onError,
  }) async {
    try {
      // Build messages array
      final messages = <Map<String, String>>[
        {'role': 'system', 'content': _systemPrompt},
      ];

      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        messages.addAll(conversationHistory);
      }

      messages.add({'role': 'user', 'content': userMessage});

      final request = http.Request(
        'POST',
        Uri.parse('$_baseUrl/api/chat'),
      );
      
      request.headers['Content-Type'] = 'application/json';
      request.body = json.encode({
        'model': _modelName,
        'messages': messages,
        'stream': true,
        'options': {
          'temperature': 0.7,
          'top_p': 0.9,
          'num_predict': 150,
        },
      });

      final client = http.Client();
      final streamedResponse = await client.send(request).timeout(_timeout);

      if (streamedResponse.statusCode == 200) {
        final fullResponse = StringBuffer();
        
        await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
          // Each line is a separate JSON object
          final lines = chunk.split('\n').where((line) => line.trim().isNotEmpty);
          
          for (var line in lines) {
            try {
              final data = json.decode(line);
              final messageContent = data['message']?['content'] as String?;
              
              if (messageContent != null && messageContent.isNotEmpty) {
                fullResponse.write(messageContent);
                onChunk(messageContent);
              }

              // Check if this is the final message
              if (data['done'] == true) {
                onComplete(fullResponse.toString());
                client.close();
                return;
              }
            } catch (e) {
              // Skip malformed JSON lines
              continue;
            }
          }
        }
        
        client.close();
        onComplete(fullResponse.toString());
      } else {
        client.close();
        onError('Server returned status code: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      onError('Failed to connect to Ollama: ${e.toString()}');
    }
  }

  /// Get a fallback response when Ollama is unavailable
  String getFallbackResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('tip') || lowerMessage.contains('advice')) {
      return "🌱 Great question! Here's an eco-tip: Try using reusable bags instead of plastic ones. A single reusable bag can replace hundreds of plastic bags over its lifetime!";
    } else if (lowerMessage.contains('game') || lowerMessage.contains('play')) {
      return "🎮 For the Beach Cleanup game, focus on clearing all trash quickly to earn bonus time. Plastic items give 10 points, while bottles give 15 points!";
    } else if (lowerMessage.contains('recycle') || lowerMessage.contains('recycling')) {
      return "♻️ Remember the recycling rules: Clean containers before recycling, separate materials properly, and check your local guidelines. Every recycled item helps our planet!";
    } else if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return "👋 Hello! I'm your Eco Assistant. How can I help you with environmental tips or game strategies today?";
    } else if (lowerMessage.contains('forest') || lowerMessage.contains('tree')) {
      return "🌲 Forests are Earth's lungs! They absorb CO2 and produce oxygen. Plant a tree, support reforestation, or play our Forest Guardian game to learn more!";
    } else if (lowerMessage.contains('ocean') || lowerMessage.contains('sea')) {
      return "🌊 Our oceans need protection! Reduce plastic use, support ocean cleanup initiatives, and try our Ocean Savior game to learn about marine conservation!";
    } else if (lowerMessage.contains('climate') || lowerMessage.contains('warming')) {
      return "🌡️ Climate action starts with you! Reduce energy use, choose sustainable transport, and play Climate Warrior to learn about fighting climate change!";
    } else if (lowerMessage.contains('wildlife') || lowerMessage.contains('animal')) {
      return "🦁 Wildlife conservation is crucial! Support habitat protection, avoid products from endangered species, and try our Wildlife Rescue game!";
    } else if (lowerMessage.contains('city') || lowerMessage.contains('urban')) {
      return "🏙️ Build sustainable cities! Support green spaces, use public transport, and play Eco City Builder to learn about sustainable urban planning!";
    } else {
      return "🌍 That's an interesting question! As your Eco Assistant, I can help with environmental tips, game strategies, recycling advice, and sustainability information. What would you like to know?";
    }
  }

  /// Get server status information
  Future<Map<String, dynamic>> getServerStatus() async {
    final isAvailable = await isServerAvailable();
    final hasModel = isAvailable ? await isModelAvailable() : false;

    return {
      'serverAvailable': isAvailable,
      'modelAvailable': hasModel,
      'serverUrl': _baseUrl,
      'modelName': _modelName,
    };
  }
}


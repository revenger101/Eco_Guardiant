import 'package:flutter/material.dart';
import '../services/ollama_service.dart';

class ChatbotFAB extends StatefulWidget {
  const ChatbotFAB({super.key});

  @override
  State<ChatbotFAB> createState() => _ChatbotFABState();
}

class _ChatbotFABState extends State<ChatbotFAB> {
  bool _isChatOpen = false;
  bool _isTyping = false;
  bool _useOllama = true; // Toggle to use Ollama or fallback
  final OllamaService _ollamaService = OllamaService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessageData> _messages = [
    ChatMessageData(
      text: "🌿 Hello! I'm your Eco Guardian AI powered by Llama 3. I'm here to help you learn about environmental protection, share sustainability tips, and guide you through our eco-games!",
      isUser: false,
      timestamp: "Just now",
    ),
    ChatMessageData(
      text: "💡 Ask me anything about sustainability, recycling, climate action, or get tips for our eco-games!",
      isUser: false,
      timestamp: "Just now",
    ),
  ];

  // Conversation history for context (last 10 messages)
  final List<Map<String, String>> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _checkOllamaAvailability();
  }

  /// Check if Ollama server is available on startup
  Future<void> _checkOllamaAvailability() async {
    final status = await _ollamaService.getServerStatus();
    setState(() {
      _useOllama = status['serverAvailable'] == true && status['modelAvailable'] == true;
    });

    // Show status message if Ollama is not available
    if (!_useOllama && mounted) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _messages.add(ChatMessageData(
              text: "⚠️ Note: Running in offline mode. For enhanced AI responses, make sure Ollama is running with llama3:8b model.",
              isUser: false,
              timestamp: "Just now",
            ));
          });
        }
      });
    }
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isTyping) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessageData(
        text: message,
        isUser: true,
        timestamp: "Now",
      ));
    });

    // Add to conversation history
    _conversationHistory.add({'role': 'user', 'content': message});

    // Keep only last 10 messages for context
    if (_conversationHistory.length > 10) {
      _conversationHistory.removeAt(0);
    }

    // Clear input
    _messageController.clear();
    _scrollToBottom();

    // Show typing indicator
    setState(() {
      _isTyping = true;
    });

    if (_useOllama) {
      // Try to get response from Ollama
      await _getOllamaResponse(message);
    } else {
      // Use fallback response
      await _getFallbackResponse(message);
    }

    setState(() {
      _isTyping = false;
    });

    _scrollToBottom();
  }

  Future<void> _getOllamaResponse(String message) async {
    try {
      final response = await _ollamaService.sendMessage(
        message,
        conversationHistory: _conversationHistory.take(_conversationHistory.length - 1).toList(),
      );

      if (response != null && response.isNotEmpty) {
        setState(() {
          _messages.add(ChatMessageData(
            text: response,
            isUser: false,
            timestamp: "Just now",
          ));
        });

        // Add to conversation history
        _conversationHistory.add({'role': 'assistant', 'content': response});
      } else {
        // Fallback if Ollama fails
        await _getFallbackResponse(message);
      }
    } catch (e) {
      // Fallback on error
      await _getFallbackResponse(message);
    }
  }

  Future<void> _getFallbackResponse(String message) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final response = _ollamaService.getFallbackResponse(message);

    setState(() {
      _messages.add(ChatMessageData(
        text: response,
        isUser: false,
        timestamp: "Just now",
      ));
    });

    // Add to conversation history
    _conversationHistory.add({'role': 'assistant', 'content': response});
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Chat Window with Close Button Above
        if (_isChatOpen) _buildChatWindowWithCloseButton(),

        // Floating Action Button
        Positioned(
          bottom: 20,
          right: 20,
          child: _buildChatbotFAB(),
        ),
      ],
    );
  }

  Widget _buildChatbotFAB() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: _isChatOpen
            ? const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _isChatOpen
                ? Colors.green.shade400
                : Colors.blue.shade400,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _toggleChat,
          borderRadius: BorderRadius.circular(30),
          child: Icon(
            _isChatOpen ? Icons.close : Icons.eco,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildChatWindowWithCloseButton() {
    return Positioned(
      bottom: 90,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close Button Above Chat Window
          _buildFloatingCloseButton(),
          const SizedBox(height: 8),
          _buildChatWindow(),
        ],
      ),
    );
  }

  Widget _buildFloatingCloseButton() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _toggleChat,
          borderRadius: BorderRadius.circular(18),
          child: const Icon(
            Icons.close,
            color: Colors.grey,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildChatWindow() {
    return Container(
      width: 320,
      height: 420,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(
          color: Colors.green.shade100,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Chat Header
          _buildChatHeader(),
          // Chat Messages
          Expanded(child: _buildChatMessages()),
          // Chat Input
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade800.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated Eco Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.eco,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Assistant Info
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eco Guardian AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.circle, color: Colors.lightGreenAccent, size: 8),
                    SizedBox(width: 4),
                    Text(
                      'Online • Eco Expert',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                SizedBox(width: 4),
                Text(
                  'AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.green.shade50.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: ListView(
        controller: _scrollController,
        children: [
          ..._messages.map((message) => ChatMessageWidget(
            text: message.text,
            isUser: message.isUser,
            timestamp: message.timestamp,
          )).toList(),
          // Typing indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildTypingIndicator(),
            ),
          const SizedBox(height: 12),
          const QuickActionChips(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypingDot(0),
            const SizedBox(width: 4),
            _buildTypingDot(1),
            const SizedBox(width: 4),
            _buildTypingDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = ((value + delay) % 1.0);
        final opacity = (animValue < 0.5) ? animValue * 2 : (1 - animValue) * 2;

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.green.shade600.withValues(alpha: 0.3 + (opacity * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        if (_isTyping && mounted) {
          setState(() {}); // Restart animation
        }
      },
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(color: Colors.green.shade100, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Icon(
                  Icons.emoji_emotions_outlined,
                  color: Colors.green.shade600,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Input Field - NOW EDITABLE
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Ask about eco-tips or games...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade400,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _sendMessage,
                borderRadius: BorderRadius.circular(20),
                child: const Icon(
                  Icons.north_east,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Data model for chat messages
class ChatMessageData {
  final String text;
  final bool isUser;
  final String timestamp;

  const ChatMessageData({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// Widget for displaying chat messages
class ChatMessageWidget extends StatelessWidget {
  final String text;
  final bool isUser;
  final String timestamp;

  const ChatMessageWidget({
    super.key,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Message Bubble
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [Colors.green.shade50, Colors.green.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(6),
                  bottomRight: isUser ? const Radius.circular(6) : const Radius.circular(18),
                ),
                border: Border.all(
                  color: isUser
                      ? Colors.blue.shade100
                      : Colors.green.shade100,
                  width: 1,
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.green.shade900,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            // Timestamp
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.only(
                left: isUser ? 0 : 8,
                right: isUser ? 8 : 0,
              ),
              child: Text(
                timestamp,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionChips extends StatelessWidget {
  const QuickActionChips({super.key});

  @override
  Widget build(BuildContext context) {
    final quickActions = [
      {'icon': Icons.tips_and_updates, 'text': 'Eco Tips'},
      {'icon': Icons.games, 'text': 'Game Help'},
      {'icon': Icons.recycling, 'text': 'Recycling'},
      {'icon': Icons.help, 'text': 'FAQ'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickActions.map((action) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      color: Colors.green.shade600,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      action['text'] as String,
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
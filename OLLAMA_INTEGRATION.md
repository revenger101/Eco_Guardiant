# Ollama LLM Integration Guide

## Overview

The Eco Guardians app now integrates with **Ollama** to provide AI-powered chatbot responses using the **Llama 3 8B** model running locally on your machine.

---

## Features

✅ **Local LLM Integration** - Uses Ollama's local server (no cloud API needed)  
✅ **Llama 3 8B Model** - Powered by Meta's Llama 3 language model  
✅ **Eco-Friendly Context** - System prompt optimized for environmental topics  
✅ **Conversation History** - Maintains context for up to 10 messages  
✅ **Fallback Mode** - Automatically switches to rule-based responses if Ollama is unavailable  
✅ **Typing Indicator** - Shows animated dots while AI is generating response  
✅ **Error Handling** - Graceful degradation when server is offline  

---

## Prerequisites

### 1. Install Ollama

Download and install Ollama from: https://ollama.ai/

**Windows Installation:**
```bash
# Download the installer from https://ollama.ai/download/windows
# Run the installer
# Ollama will start automatically as a service
```

### 2. Download Llama 3 Model

After installing Ollama, open a terminal and run:

```bash
ollama pull llama3:8b
```

This will download the Llama 3 8B model (~4.7 GB).

### 3. Verify Installation

Check that Ollama is running and the model is available:

```bash
# List available models
ollama list

# Expected output:
# NAME                     ID              SIZE      MODIFIED
# llama3:8b                365c0bd3c000    4.7 GB    X days ago
```

### 4. Test Ollama Server

Verify the server is accessible:

```bash
# Windows PowerShell
curl http://localhost:11434/api/tags

# Or in browser, navigate to:
# http://localhost:11434
```

You should see a response indicating Ollama is running.

---

## How It Works

### Architecture

```
Flutter App (chatbot_fab.dart)
    ↓
OllamaService (ollama_service.dart)
    ↓
HTTP Client (http package)
    ↓
Ollama Server (localhost:11434 or 10.0.2.2:11434 for Android emulator)
    ↓
Llama 3:8b Model
```

**Note:** The service automatically detects the platform:
- **Android Emulator**: Uses `http://10.0.2.2:11434` (special IP to access host machine)
- **Other Platforms**: Uses `http://localhost:11434`

### Key Components

#### 1. **OllamaService** (`lib/services/ollama_service.dart`)

Main service class that handles:
- Server availability checks
- Model availability verification
- Sending messages to Ollama API
- Streaming responses (for future use)
- Fallback responses when offline
- Error handling

**Key Methods:**
- `isServerAvailable()` - Checks if Ollama server is running
- `isModelAvailable()` - Verifies llama3:8b model is installed
- `sendMessage()` - Sends a message and gets AI response
- `sendMessageStreaming()` - Streams response chunks (for real-time typing effect)
- `getFallbackResponse()` - Returns rule-based response when offline
- `getServerStatus()` - Gets comprehensive server status

#### 2. **ChatbotFAB** (`lib/Widget/chatbot_fab.dart`)

Updated chatbot widget with:
- Ollama integration
- Conversation history tracking (last 10 messages)
- Typing indicator animation
- Auto-scroll to latest message
- Automatic fallback to offline mode

**Key Features:**
- Checks Ollama availability on startup
- Shows warning if Ollama is offline
- Maintains conversation context
- Smooth animations and UX

---

## Configuration

### Changing the Model

To use a different Ollama model, edit `lib/services/ollama_service.dart`:

```dart
// Line 14
static const String _modelName = 'llama3:8b';  // Change this

// Available alternatives:
// - 'llama3:70b' (larger, more capable, requires more RAM)
// - 'phi3:3.8b' (smaller, faster, less capable)
// - 'mistral:7b' (alternative 7B model)
```

### Adjusting Response Length

To change response length, edit the `num_predict` parameter:

```dart
// In sendMessage() method, line 95
'options': {
  'temperature': 0.7,
  'top_p': 0.9,
  'num_predict': 150,  // Increase for longer responses (default: 150)
},
```

### Modifying System Prompt

To customize the AI's behavior, edit the system prompt:

```dart
// Lines 18-28 in ollama_service.dart
static const String _systemPrompt = '''Your custom prompt here...''';
```

---

## Usage

### Starting the App

1. **Make sure Ollama is running:**
   ```bash
   # Check if Ollama service is running
   ollama list
   ```

2. **Run the Flutter app:**
   ```bash
   flutter run
   ```

3. **Open the chatbot:**
   - Click the green eco icon (FAB) in the bottom-right corner
   - The chatbot will check Ollama availability on startup
   - If available: "🌿 Hello! I'm your Eco Guardian AI powered by Llama 3..."
   - If unavailable: Shows warning message about offline mode

### Testing the Integration

**Test 1: Basic Question**
```
User: "What are some eco-friendly tips?"
AI: "🌱 Here are some eco-friendly tips: Use reusable bags, reduce single-use plastics, conserve water, and choose sustainable products. Small changes make a big impact! 🌍"
```

**Test 2: Game Strategy**
```
User: "How do I get high scores in Beach Cleanup?"
AI: "🎮 To excel in Beach Cleanup: Focus on collecting high-value items like bottles (15 pts), clear trash quickly for time bonuses, and prioritize plastic items. Speed and efficiency are key! 🏖️"
```

**Test 3: Environmental Question**
```
User: "Why is recycling important?"
AI: "♻️ Recycling is crucial because it reduces landfill waste, conserves natural resources, saves energy, and decreases pollution. Every recycled item helps protect our planet for future generations! 🌍"
```

---

## Troubleshooting

### Issue 1: "Running in offline mode" message

**Cause:** Ollama server is not running or model is not installed

**Solution:**
```bash
# Check if Ollama is running
ollama list

# If not running, start Ollama service (Windows)
# Ollama should auto-start, but you can restart it from Services

# Verify model is installed
ollama pull llama3:8b
```

### Issue 2: Slow responses

**Cause:** Model is large and requires significant compute

**Solutions:**
- Use a smaller model like `phi3:3.8b`
- Reduce `num_predict` parameter
- Ensure your machine has sufficient RAM (8GB+ recommended)
- Close other resource-intensive applications

### Issue 3: Connection timeout

**Cause:** Ollama server is slow to respond

**Solution:**
```dart
// Increase timeout in ollama_service.dart, line 15
static const Duration _timeout = Duration(seconds: 120); // Increase from 60
```

### Issue 4: Responses are too long/short

**Solution:**
```dart
// Adjust num_predict in ollama_service.dart
'num_predict': 200,  // Increase for longer responses
'num_predict': 100,  // Decrease for shorter responses
```

### Issue 5: Android emulator can't connect to Ollama

**Cause:** Android emulator uses `10.0.2.2` to access host machine's localhost

**Solution:**
The service automatically handles this! It uses:
- `http://10.0.2.2:11434` for Android emulator
- `http://localhost:11434` for other platforms

If still not working:
1. Verify Ollama is running on host machine: `ollama list`
2. Check firewall isn't blocking port 11434
3. Restart the app after starting Ollama

### Issue 6: Physical Android device can't connect

**Cause:** Physical devices need the host machine's actual IP address

**Solution:**
1. Find your PC's IP address (e.g., `192.168.1.100`)
2. Update `ollama_service.dart` line 18:
```dart
if (Platform.isAndroid) {
  return 'http://192.168.1.100:11434';  // Use your PC's IP
}
```
3. Ensure both devices are on the same WiFi network

---

## API Reference

### OllamaService Methods

#### `isServerAvailable()`
```dart
Future<bool> isServerAvailable()
```
Returns `true` if Ollama server is running and accessible.

#### `isModelAvailable()`
```dart
Future<bool> isModelAvailable()
```
Returns `true` if the llama3:8b model is installed.

#### `sendMessage()`
```dart
Future<String?> sendMessage(
  String userMessage, 
  {List<Map<String, String>>? conversationHistory}
)
```
Sends a message and returns the AI response. Returns `null` if failed.

#### `getServerStatus()`
```dart
Future<Map<String, dynamic>> getServerStatus()
```
Returns server status information:
```dart
{
  'serverAvailable': true/false,
  'modelAvailable': true/false,
  'serverUrl': 'http://localhost:11434',
  'modelName': 'llama3:8b',
}
```

---

## Performance Considerations

### Memory Usage
- **Llama 3 8B**: Requires ~8GB RAM
- **Phi3 3.8B**: Requires ~4GB RAM (lighter alternative)

### Response Time
- **First response**: 2-5 seconds (model loading)
- **Subsequent responses**: 1-3 seconds
- **Depends on**: CPU/GPU, RAM, prompt length

### Optimization Tips
1. Keep conversation history limited (currently 10 messages)
2. Use concise prompts
3. Limit `num_predict` for faster responses
4. Consider using GPU acceleration if available

---

## Future Enhancements

Potential improvements for the integration:

- [ ] **Streaming responses** - Show text as it's generated (real-time typing effect)
- [ ] **Model selection** - Allow users to choose different models
- [ ] **Temperature control** - Let users adjust creativity level
- [ ] **Conversation export** - Save chat history
- [ ] **Voice input** - Speak questions instead of typing
- [ ] **Multi-language support** - Detect and respond in user's language
- [ ] **Offline caching** - Cache common responses for instant replies

---

## Credits

- **Ollama**: https://ollama.ai/
- **Llama 3**: Meta AI (https://ai.meta.com/llama/)
- **Flutter HTTP Package**: https://pub.dev/packages/http

---

## Support

For issues or questions:
1. Check Ollama documentation: https://github.com/ollama/ollama
2. Verify Ollama is running: `ollama list`
3. Check Flutter logs for error messages
4. Ensure model is downloaded: `ollama pull llama3:8b`

---

**Last Updated:** 2025-11-05  
**Ollama Version:** Latest  
**Model:** llama3:8b (4.7 GB)  
**Flutter SDK:** 3.9.2+


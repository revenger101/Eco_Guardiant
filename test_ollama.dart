/// Test script to verify Ollama integration
/// Run this with: dart test_ollama.dart

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧪 Testing Ollama Integration...\n');
  
  // Test 1: Check if Ollama server is running
  print('Test 1: Checking Ollama server...');
  final serverRunning = await testOllamaServer();
  
  if (!serverRunning) {
    print('❌ Ollama server is not running!');
    print('   Please start Ollama and try again.');
    print('   Run: ollama list');
    exit(1);
  }
  
  print('✅ Ollama server is running!\n');
  
  // Test 2: Check if llama3:8b model is available
  print('Test 2: Checking for llama3:8b model...');
  final modelAvailable = await testModelAvailability();
  
  if (!modelAvailable) {
    print('❌ llama3:8b model not found!');
    print('   Please install the model:');
    print('   Run: ollama pull llama3:8b');
    exit(1);
  }
  
  print('✅ llama3:8b model is available!\n');
  
  // Test 3: Send a test message
  print('Test 3: Sending test message...');
  final response = await testChatCompletion();
  
  if (response == null) {
    print('❌ Failed to get response from Ollama!');
    exit(1);
  }
  
  print('✅ Successfully received response!');
  print('   Response: $response\n');
  
  // All tests passed
  print('🎉 All tests passed! Ollama integration is working correctly.');
  print('\nYou can now run the Flutter app:');
  print('   flutter run');
}

/// Test if Ollama server is accessible
Future<bool> testOllamaServer() async {
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:11434/api/tags'));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      await response.drain();
      client.close();
      return true;
    }
    
    client.close();
    return false;
  } catch (e) {
    return false;
  }
}

/// Test if llama3:8b model is available
Future<bool> testModelAvailability() async {
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:11434/api/tags'));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = json.decode(responseBody);
      final models = data['models'] as List<dynamic>?;
      
      if (models != null) {
        final hasLlama3 = models.any((model) => 
          (model['name'] as String).startsWith('llama3:8b')
        );
        client.close();
        return hasLlama3;
      }
    }
    
    client.close();
    return false;
  } catch (e) {
    return false;
  }
}

/// Test sending a chat completion request
Future<String?> testChatCompletion() async {
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('http://localhost:11434/api/chat'));
    
    request.headers.set('Content-Type', 'application/json');
    
    final body = json.encode({
      'model': 'llama3:8b',
      'messages': [
        {
          'role': 'system',
          'content': 'You are a helpful assistant. Respond in one short sentence.',
        },
        {
          'role': 'user',
          'content': 'Say hello and confirm you are working.',
        },
      ],
      'stream': false,
      'options': {
        'temperature': 0.7,
        'num_predict': 50,
      },
    });
    
    request.write(body);
    
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = json.decode(responseBody);
      final message = data['message']?['content'] as String?;
      client.close();
      return message?.trim();
    }
    
    client.close();
    return null;
  } catch (e) {
    print('   Error: $e');
    return null;
  }
}


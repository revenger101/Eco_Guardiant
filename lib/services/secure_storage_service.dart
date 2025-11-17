import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing sensitive data like authentication tokens
/// Uses flutter_secure_storage for encrypted storage on device
class SecureStorageService {
  // Singleton pattern
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // Secure storage instance
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Storage keys
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyAuthToken = 'auth_token';

  /// Save user credentials for persistent login
  Future<void> saveUserCredentials({
    required int userId,
    required String email,
  }) async {
    try {
      await _storage.write(key: _keyUserId, value: userId.toString());
      await _storage.write(key: _keyUserEmail, value: email);
      await _storage.write(key: _keyRememberMe, value: 'true');
      // Generate a simple auth token (in production, this should come from backend)
      final token = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
      await _storage.write(key: _keyAuthToken, value: token);
    } catch (e) {
      throw Exception('Failed to save credentials: $e');
    }
  }

  /// Get stored user ID
  Future<int?> getUserId() async {
    try {
      final userIdStr = await _storage.read(key: _keyUserId);
      if (userIdStr != null) {
        return int.tryParse(userIdStr);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get stored user email
  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _keyUserEmail);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has enabled "Remember Me"
  Future<bool> isRememberMeEnabled() async {
    try {
      final rememberMe = await _storage.read(key: _keyRememberMe);
      return rememberMe == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Get stored auth token
  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _keyAuthToken);
    } catch (e) {
      return null;
    }
  }

  /// Check if valid credentials are stored
  Future<bool> hasStoredCredentials() async {
    try {
      final userId = await getUserId();
      final email = await getUserEmail();
      final rememberMe = await isRememberMeEnabled();
      final token = await getAuthToken();
      
      return userId != null && 
             email != null && 
             rememberMe && 
             token != null;
    } catch (e) {
      return false;
    }
  }

  /// Clear all stored credentials (on logout)
  Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: _keyUserId);
      await _storage.delete(key: _keyUserEmail);
      await _storage.delete(key: _keyRememberMe);
      await _storage.delete(key: _keyAuthToken);
    } catch (e) {
      throw Exception('Failed to clear credentials: $e');
    }
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }

  /// Get all stored credentials as a map
  Future<Map<String, dynamic>> getStoredCredentials() async {
    try {
      final userId = await getUserId();
      final email = await getUserEmail();
      final token = await getAuthToken();
      
      return {
        'userId': userId,
        'email': email,
        'token': token,
      };
    } catch (e) {
      return {};
    }
  }
}


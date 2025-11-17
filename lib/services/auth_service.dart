import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import 'database_helper.dart';
import 'secure_storage_service.dart';
import 'daily_rewards_service.dart';

/// AuthService class to handle authentication logic
/// Manages user signup, login, logout, and session management
class AuthService {
  static final AuthService _instance = AuthService._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SecureStorageService _secureStorage = SecureStorageService();

  // Lazy initialization to avoid circular dependency
  DailyRewardsService? _dailyRewards;
  DailyRewardsService get dailyRewards {
    _dailyRewards ??= DailyRewardsService();
    return _dailyRewards!;
  }

  // Current logged-in user
  User? _currentUser;

  // Private constructor
  AuthService._internal();

  // Factory constructor returns the same instance
  factory AuthService() {
    return _instance;
  }

  /// Get current logged-in user
  User? get currentUser => _currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  /// Password must be at least 6 characters
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Sign up a new user
  /// Returns a map with 'success' boolean and 'message' string
  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (fullName.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Full name is required',
        };
      }

      if (!_isValidEmail(email)) {
        return {
          'success': false,
          'message': 'Please enter a valid email address',
        };
      }

      if (!_isValidPassword(password)) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters long',
        };
      }

      // Check if email already exists
      final emailExists = await _dbHelper.emailExists(email.toLowerCase());
      if (emailExists) {
        return {
          'success': false,
          'message': 'An account with this email already exists',
        };
      }

      // Hash the password
      final hashedPassword = _hashPassword(password);

      // Create new user
      final user = User(
        fullName: fullName.trim(),
        email: email.toLowerCase().trim(),
        password: hashedPassword,
      );

      // Insert user into database
      final userId = await _dbHelper.insertUser(user);

      if (userId > 0) {
        return {
          'success': true,
          'message': 'Account created successfully!',
          'userId': userId,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create account. Please try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  /// Login user
  /// Returns a map with 'success' boolean, 'message' string, and 'user' object if successful
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // Validate inputs
      if (email.trim().isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Please enter both email and password',
        };
      }

      // Get user from database
      final user = await _dbHelper.getUserByEmail(email.toLowerCase().trim());

      if (user == null) {
        return {
          'success': false,
          'message': 'No account found with this email',
        };
      }

      // Verify password
      final hashedPassword = _hashPassword(password);
      if (user.password != hashedPassword) {
        return {
          'success': false,
          'message': 'Incorrect password',
        };
      }

      // Update last login time
      await _dbHelper.updateLastLogin(user.id!);

      // Set current user
      _currentUser = user.copyWith(lastLogin: DateTime.now());

      // Save credentials if remember me is enabled
      if (rememberMe) {
        await _secureStorage.saveUserCredentials(
          userId: user.id!,
          email: user.email,
        );
      }

      // Check and award daily login rewards
      final dailyRewardResult = await dailyRewards.checkDailyLogin();

      return {
        'success': true,
        'message': 'Login successful!',
        'user': _currentUser,
        'dailyReward': dailyRewardResult,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  /// Auto-login using stored credentials
  /// Returns a map with 'success' boolean and 'user' object if successful
  Future<Map<String, dynamic>> autoLogin() async {
    try {
      // Check if credentials are stored
      final hasCredentials = await _secureStorage.hasStoredCredentials();
      if (!hasCredentials) {
        return {
          'success': false,
          'message': 'No stored credentials found',
        };
      }

      // Get stored user ID
      final userId = await _secureStorage.getUserId();
      if (userId == null) {
        return {
          'success': false,
          'message': 'Invalid stored credentials',
        };
      }

      // Get user from database
      final user = await _dbHelper.getUserById(userId);
      if (user == null) {
        // Clear invalid credentials
        await _secureStorage.clearCredentials();
        return {
          'success': false,
          'message': 'User not found',
        };
      }

      // Update last login time
      await _dbHelper.updateLastLogin(user.id!);

      // Set current user
      _currentUser = user.copyWith(lastLogin: DateTime.now());

      // Check and award daily login rewards
      final dailyRewardResult = await dailyRewards.checkDailyLogin();

      return {
        'success': true,
        'message': 'Auto-login successful!',
        'user': _currentUser,
        'dailyReward': dailyRewardResult,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Auto-login failed: ${e.toString()}',
      };
    }
  }

  /// Logout current user and clear stored credentials
  Future<void> logout({bool clearStoredCredentials = true}) async {
    _currentUser = null;
    if (clearStoredCredentials) {
      await _secureStorage.clearCredentials();
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? email,
  }) async {
    try {
      if (_currentUser == null) {
        return {
          'success': false,
          'message': 'No user is currently logged in',
        };
      }

      if (fullName.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Full name is required',
        };
      }

      // If email is being updated, check if it's valid and not already taken
      if (email != null && email != _currentUser!.email) {
        if (!_isValidEmail(email)) {
          return {
            'success': false,
            'message': 'Please enter a valid email address',
          };
        }

        final emailExists = await _dbHelper.emailExists(email.toLowerCase());
        if (emailExists) {
          return {
            'success': false,
            'message': 'This email is already in use',
          };
        }
      }

      // Update user
      final updatedUser = _currentUser!.copyWith(
        fullName: fullName.trim(),
        email: email?.toLowerCase().trim() ?? _currentUser!.email,
      );

      await _dbHelper.updateUser(updatedUser);
      _currentUser = updatedUser;

      return {
        'success': true,
        'message': 'Profile updated successfully!',
        'user': _currentUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  /// Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_currentUser == null) {
        return {
          'success': false,
          'message': 'No user is currently logged in',
        };
      }

      // Verify current password
      final hashedCurrentPassword = _hashPassword(currentPassword);
      if (_currentUser!.password != hashedCurrentPassword) {
        return {
          'success': false,
          'message': 'Current password is incorrect',
        };
      }

      // Validate new password
      if (!_isValidPassword(newPassword)) {
        return {
          'success': false,
          'message': 'New password must be at least 6 characters long',
        };
      }

      // Hash and update password
      final hashedNewPassword = _hashPassword(newPassword);
      final updatedUser = _currentUser!.copyWith(password: hashedNewPassword);

      await _dbHelper.updateUser(updatedUser);
      _currentUser = updatedUser;

      return {
        'success': true,
        'message': 'Password changed successfully!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }
}


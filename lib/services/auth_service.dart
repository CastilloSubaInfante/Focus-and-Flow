import '../data_store.dart';

class AuthService {
  /// Register a new user with email and password
  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if email already exists
      if (DataStore.registeredUsers.containsKey(email)) {
        throw Exception('Email already registered');
      }
      
      return {
        'uid': email.hashCode.toString(),
        'email': email,
        'password': password,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Save user profile to local storage
  static Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      // Save to DataStore
      DataStore.registeredUsers[email] = {
        'password': '', // Don't store password
        'name': name,
        'verified': false,
        'uid': uid,
        'email': email,
        'createdAt': DateTime.now().toString(),
      };
      
      await DataStore.saveRegisteredUsers();
    } catch (e) {
      rethrow;
    }
  }

  /// Send email verification (simulated)
  static Future<void> sendEmailVerification(Map<String, dynamic> user) async {
    try {
      // Simulate sending verification email
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      rethrow;
    }
  }

  /// Update email verified status in local storage
  static Future<void> updateEmailVerified(String email) async {
    try {
      if (DataStore.registeredUsers.containsKey(email)) {
        DataStore.registeredUsers[email]!['verified'] = true;
        await DataStore.saveRegisteredUsers();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user from DataStore
  static Map<String, dynamic>? getCurrentUser() {
    if (DataStore.currentUserEmail != null && 
        DataStore.registeredUsers.containsKey(DataStore.currentUserEmail)) {
      return DataStore.registeredUsers[DataStore.currentUserEmail];
    }
    return null;
  }

  /// Sign out user
  static Future<void> signOut() async {
    try {
      DataStore.currentUserEmail = null;
      DataStore.currentUserUsername = null;
      await DataStore.saveCurrentUserEmail();
      await DataStore.saveCurrentUserUsername();
    } catch (e) {
      rethrow;
    }
  }
}

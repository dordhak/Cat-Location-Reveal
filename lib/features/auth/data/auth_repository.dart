import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/errors/app_exception.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client}) : _client = client ?? SupabaseConfig.client;

  User? get currentUser => _client.auth.currentUser;

  /// Emits on every sign-in, sign-out, and session restore (including the
  /// initial event on app start, so UI watching this always ends up correct).
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signUp({required String email, required String password}) async {
    try {
      final response = await _client.auth.signUp(email: email, password: password);
      if (response.user == null) {
        throw const AppException('Could not create your account. Please try again.');
      }
    } on AuthException catch (e) {
      throw AppException(_friendlyMessage(e));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw AppException(_friendlyMessage(e));
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  Future<void> updateAccount({String? email, String? password}) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(email: email, password: password),
      );
    } on AuthException catch (e) {
      throw AppException(_friendlyMessage(e));
    }
  }


  /// Supabase's raw AuthException messages are written for logs, not users.
  String _friendlyMessage(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (msg.contains('already registered')) {
      return 'An account with this email already exists — try signing in instead.';
    }
    if (msg.contains('password') && (msg.contains('least') || msg.contains('short'))) {
      return 'Password must be at least 6 characters.';
    }
    if (msg.contains('valid email')) {
      return 'Please enter a valid email address.';
    }
    return e.message;
  }
}
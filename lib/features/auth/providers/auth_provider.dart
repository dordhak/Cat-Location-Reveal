import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/errors/app_exception.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  Future<User> build() async {
    final client = SupabaseConfig.client;

    final existingUser = client.auth.currentUser;
    if (existingUser != null) return existingUser;

    try {
      final response = await client.auth.signInAnonymously();
      final user = response.user;
      if (user == null) {
        throw const AppException('Could not start a session. Please restart the app.');
      }
      return user;
    } on AuthException catch (e) {
      throw AppException('Sign-in failed: ${e.message}');
    }
  }
}

@riverpod
String? currentUserId(Ref ref) {
  return ref.watch(authControllerProvider).value?.id;
}
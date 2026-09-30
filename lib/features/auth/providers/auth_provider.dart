import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository();

@Riverpod(keepAlive: true)
Stream<Session?> authSessionChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges.map(
        (authState) => authState.session,
      );
}

@riverpod
User? currentUser(Ref ref) {
  final streamed = ref.watch(authSessionChangesProvider).value?.user;
  return streamed ?? ref.watch(authRepositoryProvider).currentUser;
}

@riverpod
String? currentUserId(Ref ref) => ref.watch(currentUserProvider)?.id;

@riverpod
bool isSignedIn(Ref ref) => ref.watch(currentUserProvider) != null;

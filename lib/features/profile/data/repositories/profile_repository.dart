import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  ProfileRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;
  static const _table = 'profiles';
  static const _avatarsBucket = 'avatars';

  Future<UserProfile> fetchProfile(String userId) async {
    try {
      final row = await _client.from(_table).select().eq('id', userId).single();
      return UserProfile.fromJson(row);
    } on PostgrestException catch (e) {
      throw AppException('Failed to load your profile: ${e.message}');
    }
  }

  Future<UserProfile> updateProfile({
    required String userId,
    required String username,
    String? avatarUrl,
  }) async {
    try {
      final row = await _client
          .from(_table)
          .update({
            'username': username.trim(),
            if (avatarUrl != null) 'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();
      return UserProfile.fromJson(row);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const AppException('That username is already taken.');
      }
      throw AppException('Failed to save your profile: ${e.message}');
    }
  }

  Future<String> uploadAvatar({required File imageFile, required String userId}) async {
    try {
      final extension = imageFile.path.split('.').last.toLowerCase();
      final path = '$userId/avatar.$extension';
      await _client.storage.from(_avatarsBucket).upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      // Bust image caches when the user replaces their photo at the same path.
      return '${_client.storage.from(_avatarsBucket).getPublicUrl(path)}?v=${DateTime.now().millisecondsSinceEpoch}';
    } on StorageException catch (e) {
      throw AppException('Failed to upload avatar: ${e.message}');
    }
  }
}
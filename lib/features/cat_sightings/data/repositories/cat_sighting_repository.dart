import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/cat_sighting_model.dart';

class CatSightingRepository {
  final SupabaseClient _client;
  final _uuid = const Uuid();

  CatSightingRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  /// Fetches all cat sightings, newest first, with each row's uploader
  ///username and avatar embedded with 'profiles' foreign key
  Future<List<CatSighting>> fetchAllSightings() async {
    try {
      final response = await _client
          .from(AppConstants.catSightingsTable)
          .select('*, profiles:user_id(username, avatar_url)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((row) => CatSighting.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AppException('Failed to load cat sightings: ${e.message}');
    } catch (e) {
      throw AppException('Something went wrong loading sightings.');
    }
  }

  Future<String> uploadCatPhoto({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${_uuid.v4()}.$fileExt';
      final storagePath = '$userId/$fileName';

      await _client.storage.from(AppConstants.catPhotosBucket).upload(
            storagePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      return _client.storage
          .from(AppConstants.catPhotosBucket)
          .getPublicUrl(storagePath);
    } on StorageException catch (e) {
      throw AppException('Failed to upload photo: ${e.message}');
    } catch (e) {
      throw AppException('Something went wrong uploading the photo.');
    }
  }

  Future<CatSighting> createSighting(CatSighting sighting) async {
    try {
      final response = await _client
          .from(AppConstants.catSightingsTable)
          .insert(sighting.toInsertJson())
          .select()
          .single();

      return CatSighting.fromJson(response);
    } on PostgrestException catch (e) {
      throw AppException('Failed to save cat sighting: ${e.message}');
    } catch (e) {
      throw AppException('Something went wrong saving the sighting.');
    }
  }

  Future<void> deleteSighting(String sightingId) async {
    try {
      await _client
          .from(AppConstants.catSightingsTable)
          .delete()
          .eq('id', sightingId);
    } on PostgrestException catch (e) {
      throw AppException('Failed to delete sighting: ${e.message}');
    }
  }
}
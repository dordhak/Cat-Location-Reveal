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

  /// Fetches all cat sightings, newest first.
  Future<List<CatSighting>> fetchAllSightings() async {
    try {
      final response = await _client
          .from(AppConstants.catSightingsTable)
          .select()
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

  /// Uploads an image file to Storage and returns its public URL.
  /// Path convention: {userId}/{uuid}.jpg — matches the RLS folder policy.
  Future<String> uploadCatPhoto({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${_uuid.v4()}.$fileExt';
      final storagePath = '$userId/$fileName';

      await _client.storage
          .from(AppConstants.catPhotosBucket)
          .upload(
            storagePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
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

  /// Inserts a new cat sighting record and returns the saved row
  /// (including the DB-generated id and created_at).
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

  /// Deletes a sighting — RLS ensures a user can only delete their own.
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
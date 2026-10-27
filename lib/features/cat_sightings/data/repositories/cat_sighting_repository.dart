import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

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
          .select(
            '*, profiles!cat_sightings_user_id_fkey(username, avatar_url)',
          )
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
    required XFile imageFile,
    required String userId,
  }) async {
    try {
      final fileExt = _fileExtension(imageFile);
      final fileName = '${_uuid.v4()}.$fileExt';
      final storagePath = '$userId/$fileName';

      await _client.storage
          .from(AppConstants.catPhotosBucket)
          .uploadBinary(
            storagePath,
            await imageFile.readAsBytes(),
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: imageFile.mimeType ?? 'image/jpeg',
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

  String _fileExtension(XFile imageFile) {
    final extension = imageFile.path.split('.').last.toLowerCase();
    if (extension.length <= 4 && extension != imageFile.path.toLowerCase()) {
      return extension;
    }
    final mimeType = imageFile.mimeType?.split('/').last.toLowerCase();
    return mimeType == 'jpeg' ? 'jpg' : (mimeType ?? 'jpg');
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
    } catch (e) {
      throw const AppException('Something went wrong deleting the sighting.');
    }
  }

  Future<List<CatSighting>> fetchUserSightings(String userId) async {
    try {
      final response = await _client
          .from(AppConstants.catSightingsTable)
          .select(
            '*, profiles!cat_sightings_user_id_fkey(username, avatar_url)',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (response as List)
          .map((row) => CatSighting.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AppException('Failed to load your postings: ${e.message}');
    } catch (e) {
      throw const AppException('Something went wrong loading your postings.');
    }
  }

  Future<void> submitReport({
    required String sightingId,
    required String reporterId,
    required String reason,
    String? details,
  }) async {
    try {
      await _client.from(AppConstants.sightingReportsTable).insert({
        'sighting_id': sightingId,
        'reporter_id': reporterId,
        'reason': reason,
        'details': details,
      });
    } on PostgrestException catch (e) {
      throw AppException('Failed to submit report: ${e.message}');
    } catch (e) {
      throw const AppException('Something went wrong submitting the report.');
    }
  }
}

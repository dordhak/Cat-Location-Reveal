import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/models/cat_sighting_model.dart';
import '../data/repositories/cat_sighting_repository.dart';

part 'cat_sighting_providers.g.dart';

/// Single shared instance of the repository.
@Riverpod(keepAlive: true)
CatSightingRepository catSightingRepository(Ref ref) {
  return CatSightingRepository();
}

/// The live list of all cat sightings, for the map to render as markers.
@riverpod
class CatSightingsList extends _$CatSightingsList {
  @override
  Future<List<CatSighting>> build() {
    return ref.watch(catSightingRepositoryProvider).fetchAllSightings();
  }

  /// Call after a successful submission to refresh the map immediately.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(catSightingRepositoryProvider).fetchAllSightings(),
    );
  }
}

/// Handles the submit flow: upload photo -> insert row -> refresh the list.
@riverpod
class SightingSubmission extends _$SightingSubmission {
  @override
  FutureOr<void> build() {
    // No-op initial state; this notifier only does something when submit() is called.
  }

  Future<void> submit({
    required File photoFile,
    required String name,
    required String catType,
    required String primaryColor,
    required int friendlinessRating,
    required double latitude,
    required double longitude,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        throw Exception('No signed-in user. Please restart the app.');
      }

      final repository = ref.read(catSightingRepositoryProvider);

      final photoUrl = await repository.uploadCatPhoto(
        imageFile: photoFile,
        userId: userId,
      );

      final sighting = CatSighting(
        id: '', // ignored by toInsertJson(); DB generates the real one
        userId: userId,
        name: name,
        catType: catType,
        primaryColor: primaryColor,
        friendlinessRating: friendlinessRating,
        latitude: latitude,
        longitude: longitude,
        photoUrl: photoUrl,
        createdAt: DateTime.now(), // also ignored by toInsertJson()
      );

      await repository.createSighting(sighting);

      // Refresh the map's sighting list so the new marker appears immediately.
      ref.invalidate(catSightingsListProvider);
    });
  }
}
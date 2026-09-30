import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_exception.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/models/cat_sighting_model.dart';
import '../data/repositories/cat_sighting_repository.dart';

part 'cat_sighting_providers.g.dart';

@Riverpod(keepAlive: true)
CatSightingRepository catSightingRepository(Ref ref) {
  return CatSightingRepository();
}

@riverpod
class CatSightingsList extends _$CatSightingsList {
  @override
  Future<List<CatSighting>> build() {
    return ref.watch(catSightingRepositoryProvider).fetchAllSightings();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(catSightingRepositoryProvider).fetchAllSightings(),
    );
  }
}

@riverpod
class SightingSubmission extends _$SightingSubmission {
  @override
  FutureOr<void> build() {
    // No-op initial state; submit() does the real work.
  }

  Future<void> submit({
    required File photoFile,
    required String name,
    required String catType,
    required String primaryColor,
    String? description,
    required int friendlinessRating,
    required double latitude,
    required double longitude,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        throw const AppException('Please sign in to post a sighting.');
      }

      final repository = ref.read(catSightingRepositoryProvider);

      final photoUrl = await repository.uploadCatPhoto(
        imageFile: photoFile,
        userId: userId,
      );

      final trimmedDescription = description?.trim();

      final sighting = CatSighting(
        id: '', // ignored by toInsertJson(); DB generates the real one
        userId: userId,
        name: name,
        catType: catType,
        primaryColor: primaryColor,
        description:
            (trimmedDescription == null || trimmedDescription.isEmpty)
                ? null
                : trimmedDescription,
        friendlinessRating: friendlinessRating,
        latitude: latitude,
        longitude: longitude,
        photoUrl: photoUrl,
        createdAt: DateTime.now(), // also ignored by toInsertJson()
      );

      await repository.createSighting(sighting);

      ref.invalidate(catSightingsListProvider);
    });
  }
}
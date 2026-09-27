// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cat_sighting_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Single shared instance of the repository.

@ProviderFor(catSightingRepository)
final catSightingRepositoryProvider = CatSightingRepositoryProvider._();

/// Single shared instance of the repository.

final class CatSightingRepositoryProvider
    extends
        $FunctionalProvider<
          CatSightingRepository,
          CatSightingRepository,
          CatSightingRepository
        >
    with $Provider<CatSightingRepository> {
  /// Single shared instance of the repository.
  CatSightingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catSightingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catSightingRepositoryHash();

  @$internal
  @override
  $ProviderElement<CatSightingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CatSightingRepository create(Ref ref) {
    return catSightingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatSightingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatSightingRepository>(value),
    );
  }
}

String _$catSightingRepositoryHash() =>
    r'71621324e442de8e55b6e332937b1f1f7b1ccc38';

/// The live list of all cat sightings, for the map to render as markers.

@ProviderFor(CatSightingsList)
final catSightingsListProvider = CatSightingsListProvider._();

/// The live list of all cat sightings, for the map to render as markers.
final class CatSightingsListProvider
    extends $AsyncNotifierProvider<CatSightingsList, List<CatSighting>> {
  /// The live list of all cat sightings, for the map to render as markers.
  CatSightingsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catSightingsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catSightingsListHash();

  @$internal
  @override
  CatSightingsList create() => CatSightingsList();
}

String _$catSightingsListHash() => r'48575150705e3ca2802b560338fb06f0458cee10';

/// The live list of all cat sightings, for the map to render as markers.

abstract class _$CatSightingsList extends $AsyncNotifier<List<CatSighting>> {
  FutureOr<List<CatSighting>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CatSighting>>, List<CatSighting>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CatSighting>>, List<CatSighting>>,
              AsyncValue<List<CatSighting>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Handles the submit flow: upload photo -> insert row -> refresh the list.

@ProviderFor(SightingSubmission)
final sightingSubmissionProvider = SightingSubmissionProvider._();

/// Handles the submit flow: upload photo -> insert row -> refresh the list.
final class SightingSubmissionProvider
    extends $AsyncNotifierProvider<SightingSubmission, void> {
  /// Handles the submit flow: upload photo -> insert row -> refresh the list.
  SightingSubmissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sightingSubmissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sightingSubmissionHash();

  @$internal
  @override
  SightingSubmission create() => SightingSubmission();
}

String _$sightingSubmissionHash() =>
    r'7493aba802a8ea4a08fc4360b3b003baa24c70fe';

/// Handles the submit flow: upload photo -> insert row -> refresh the list.

abstract class _$SightingSubmission extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

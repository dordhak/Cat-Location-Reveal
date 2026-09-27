// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentLocation)
final currentLocationProvider = CurrentLocationProvider._();

final class CurrentLocationProvider
    extends $AsyncNotifierProvider<CurrentLocation, Position> {
  CurrentLocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentLocationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentLocationHash();

  @$internal
  @override
  CurrentLocation create() => CurrentLocation();
}

String _$currentLocationHash() => r'7e72fca02b1fa557662d6b1a77fdb573024b970f';

abstract class _$CurrentLocation extends $AsyncNotifier<Position> {
  FutureOr<Position> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Position>, Position>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Position>, Position>,
              AsyncValue<Position>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

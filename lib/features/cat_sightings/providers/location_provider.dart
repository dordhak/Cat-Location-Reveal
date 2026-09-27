import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/utils/location_utils.dart';

part 'location_provider.g.dart';

@riverpod
class CurrentLocation extends _$CurrentLocation {
  @override
  Future<Position> build() {
    return LocationUtils.getCurrentPosition();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => LocationUtils.getCurrentPosition());
  }
}
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/cat_sighting_model.dart';

class CatMarkerBuilder {
  CatMarkerBuilder._();

  static Marker build({
    required CatSighting sighting,
    required VoidCallback onTap,
  }) {
    return Marker(
      markerId: MarkerId(sighting.id),
      position: LatLng(sighting.latitude, sighting.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: onTap,
    );
  }
}
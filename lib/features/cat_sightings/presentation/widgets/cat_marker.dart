import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/cat_sighting_model.dart';

/// Draws the paw-print pin once and caches it. Needs a google_maps_flutter
/// version that has `BitmapDescriptor.bytes` (2.10 or newer).
class CatMarkerIcon {
  CatMarkerIcon._();

  static const double _width = 48;
  static const double _height = 60;
  static const double _pixelScale = 3;

  /// The pin's tip sits at y = 56 of 60, so anchor there instead of the bottom.
  static const Offset anchor = Offset(0.5, 56 / 60);

  static Future<BitmapDescriptor>? _cache;

  static Future<BitmapDescriptor> load() => _cache ??= _draw();

  static Future<BitmapDescriptor> _draw() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(_pixelScale);

    final pin = Path.combine(
      PathOperation.union,
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(24, 24), radius: 20)),
      Path()
        ..moveTo(12.5, 37)
        ..lineTo(24, 56)
        ..lineTo(35.5, 37)
        ..close(),
    );

    canvas.drawShadow(pin, Colors.black, 2.5, true);
    canvas.drawPath(pin, Paint()..color = AppColors.marmalade);
    canvas.drawPath(
      pin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );

    final paw = Paint()..color = AppColors.ink;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(24, 28), width: 15, height: 11),
      paw,
    );
    for (final toe in const [
      Offset(15.5, 21),
      Offset(20.5, 16),
      Offset(27.5, 16),
      Offset(32.5, 21),
    ]) {
      canvas.drawCircle(toe, 3.1, paw);
    }

    final image = await recorder.endRecording().toImage(
          (_width * _pixelScale).round(),
          (_height * _pixelScale).round(),
        );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
    return BitmapDescriptor.bytes(
      data.buffer.asUint8List(),
      width: _width,
      height: _height,
    );
  }
}

class CatMarkerBuilder {
  CatMarkerBuilder._();

  static Marker build({
    required CatSighting sighting,
    required BitmapDescriptor icon,
    required VoidCallback onTap,
  }) {
    return Marker(
      markerId: MarkerId(sighting.id),
      position: LatLng(sighting.latitude, sighting.longitude),
      icon: icon,
      anchor: CatMarkerIcon.anchor,
      onTap: onTap,
    );
  }
}
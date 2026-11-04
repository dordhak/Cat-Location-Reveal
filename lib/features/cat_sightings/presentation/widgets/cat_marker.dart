import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/cat_sighting_model.dart';

class CatMarkerIcon {
  CatMarkerIcon._();

  static const double _width = 52;
  static const double _height = 64;
  static const double _pixelScale = 3;

  static const Offset anchor = Offset(0.5, 62 / _height);

  static Future<BitmapDescriptor> load([String? photoUrl]) async {
    if (kIsWeb) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }

    if (photoUrl == null || photoUrl.isEmpty) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }

    final sourceImage = await _loadImage(photoUrl);
    if (sourceImage == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(_pixelScale);

    final circle = Path()
      ..addOval(const Rect.fromLTWH(2, 2, _width - 4, _width - 4));
    final pin = Path.combine(
      PathOperation.union,
      circle,
      Path()
        ..moveTo(13, 38)
        ..lineTo(_width / 2, 62)
        ..lineTo(39, 38)
        ..close(),
    );
    canvas.drawShadow(pin, Colors.black, 2, true);
    canvas.drawPath(pin, Paint()..color = AppColors.sage);
    canvas.save();
    canvas.clipPath(circle);
    final source = Rect.fromLTWH(
      0,
      0,
      sourceImage.width.toDouble(),
      sourceImage.height.toDouble(),
    );
    canvas.drawImageRect(
      sourceImage,
      source,
      const Rect.fromLTWH(2, 2, 48, 48),
      Paint(),
    );
    canvas.restore();
    canvas.drawPath(
      circle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.paper,
    );

    final generatedImage = await recorder.endRecording().toImage(
      (_width * _pixelScale).round(),
      (_height * _pixelScale).round(),
    );
    final data = await generatedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (data == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
    return BitmapDescriptor.bytes(
      data.buffer.asUint8List(),
      width: _width,
      height: _height,
    );
  }

  static Future<ui.Image?> _loadImage(String url) async {
    final completer = Completer<ui.Image?>();
    final stream = NetworkImage(url).resolve(const ImageConfiguration());
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (_, _) {
        if (!completer.isCompleted) completer.complete(null);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../providers/cat_sighting_providers.dart';
import '../../providers/location_provider.dart';
import '../widgets/cat_detail_sheet.dart';
import '../widgets/cat_marker.dart';
import 'submit_sighting_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentLocationProvider);
    final sightingsAsync = ref.watch(catSightingsListProvider);

    return Scaffold(
      body: locationAsync.when(
        data: (position) {
          final initialCameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: AppConstants.defaultZoom,
          );

          final markers = sightingsAsync.maybeWhen(
            data: (sightings) => sightings
                .map((sighting) => CatMarkerBuilder.build(
                      sighting: sighting,
                      onTap: () => CatDetailSheet.show(context, sighting),
                    ))
                .toSet(),
            orElse: () => <Marker>{},
          );

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: initialCameraPosition,
                onMapCreated: (controller) => _mapController = controller,
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
              if (sightingsAsync.isLoading)
                const Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (sightingsAsync.hasError)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Could not load cat sightings.',
                        style: TextStyle(color: Colors.red[900]),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SubmitSightingScreen()),
        ),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Spot a Cat'),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/map_style.dart';
import '../../data/models/cat_sighting_model.dart';
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
  BitmapDescriptor? _catIcon;

  @override
  void initState() {
    super.initState();
    CatMarkerIcon.load().then((icon) {
      if (mounted) setState(() => _catIcon = icon);
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locationAsync = ref.watch(currentLocationProvider);
    final sightingsAsync = ref.watch(catSightingsListProvider);
    final position = locationAsync.value;

    return Scaffold(
      body: locationAsync.when(
        data: (position) {
          final icon = _catIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
          final sightings = sightingsAsync.value ?? const <CatSighting>[];

          final markers = sightings
              .map((sighting) => CatMarkerBuilder.build(
                    sighting: sighting,
                    icon: icon,
                    onTap: () => CatDetailSheet.show(context, sighting),
                  ))
              .toSet();

          final pill = sightingsAsync.when(
            data: (list) => _StatusPill(
              icon: Icons.pets_rounded,
              label: list.isEmpty
                  ? 'No cats yet. Be the first to spot one.'
                  : '${list.length} ${list.length == 1 ? 'cat' : 'cats'} on the map',
            ),
            loading: () =>
                const _StatusPill(loading: true, label: 'Finding cats...'),
            error: (_, __) => _StatusPill(
              icon: Icons.refresh_rounded,
              isError: true,
              label: "Couldn't load cats. Tap to retry.",
              onTap: () =>
                  ref.read(catSightingsListProvider.notifier).refresh(),
            ),
          );

          return Stack(
            children: [
              GoogleMap(
                style: kCatMapStyle,
                initialCameraPosition: CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: AppConstants.defaultZoom,
                ),
                onMapCreated: (controller) => _mapController = controller,
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Align(alignment: Alignment.centerLeft, child: pill),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Finding your location...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_off_rounded, size: 48, color: scheme.outline),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(160, 48),
                  ),
                  onPressed: () =>
                      ref.read(currentLocationProvider.notifier).refresh(),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Two FABs on one screen need distinct hero tags, or navigating to
          // another route throws a "multiple heroes share the same tag" error.
          FloatingActionButton.small(
            heroTag: 'recenter',
            tooltip: 'Center on my location',
            backgroundColor: Colors.white,
            foregroundColor: scheme.secondary,
            elevation: 2,
            onPressed: position == null
                ? null
                : () => _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(position.latitude, position.longitude),
                        AppConstants.defaultZoom,
                      ),
                    ),
            child: const Icon(Icons.my_location_rounded),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'spot_cat',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SubmitSightingScreen()),
            ),
            icon: const Icon(Icons.pets_rounded),
            label: const Text('Spot a cat'),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool loading;
  final bool isError;
  final VoidCallback? onTap;

  const _StatusPill({
    required this.label,
    this.icon,
    this.loading = false,
    this.isError = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground =
        isError ? scheme.onErrorContainer : scheme.onSurface;

    return Material(
      color: isError ? scheme.errorContainer : Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      surfaceTintColor: Colors.transparent,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (icon != null)
                Icon(
                  icon,
                  size: 18,
                  color: isError ? scheme.onErrorContainer : scheme.secondary,
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
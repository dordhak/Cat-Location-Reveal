import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/map_style.dart';
import '../../providers/cat_sighting_providers.dart';
import '../../providers/location_provider.dart';
import '../../providers/submission_form_provider.dart';
import '../widgets/cat_marker.dart';
import '../widgets/submission_form.dart';

class SubmitSightingScreen extends ConsumerStatefulWidget {
  const SubmitSightingScreen({super.key});

  @override
  ConsumerState<SubmitSightingScreen> createState() =>
      _SubmitSightingScreenState();
}

class _SubmitSightingScreenState extends ConsumerState<SubmitSightingScreen> {
  SubmissionFormData? _formData;
  BitmapDescriptor? _pinIcon;
  bool _positionSeeded = false;

  @override
  void initState() {
    super.initState();
    CatMarkerIcon.load().then((icon) {
      if (mounted) setState(() => _pinIcon = icon);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: AppConstants.imageQuality,
      maxWidth: AppConstants.maxImageDimension,
    );
    if (picked != null) {
      ref
          .read(submissionFormControllerProvider.notifier)
          .setPhoto(File(picked.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final formState = ref.read(submissionFormControllerProvider);
    final data = _formData;

    if (formState.photo == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Add a photo of the cat first.')),
      );
      return;
    }
    if (formState.position == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Still finding your location. Try again in a moment.'),
        ),
      );
      return;
    }
    if (data == null ||
        data.name.isEmpty ||
        data.catType.isEmpty ||
        data.primaryColor.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Fill in the name, type and fur color.')),
      );
      return;
    }

    await ref.read(sightingSubmissionProvider.notifier).submit(
          photoFile: formState.photo!,
          name: data.name,
          catType: data.catType,
          primaryColor: data.primaryColor,
          description: data.description,
          friendlinessRating: data.friendlinessRating,
          latitude: formState.position!.latitude,
          longitude: formState.position!.longitude,
        );

    if (!mounted) return;
    final result = ref.read(sightingSubmissionProvider);

    if (result.hasError) {
      messenger.showSnackBar(SnackBar(content: Text(result.error.toString())));
      return;
    }

    ref.read(submissionFormControllerProvider.notifier).reset();
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Sighting posted. Thanks for spotting it!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locationAsync = ref.watch(currentLocationProvider);
    final formState = ref.watch(submissionFormControllerProvider);
    final isSubmitting = ref.watch(sightingSubmissionProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Spot a cat')),
      body: locationAsync.when(
        data: (position) {
          if (!_positionSeeded) {
            _positionSeeded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ref
                  .read(submissionFormControllerProvider.notifier)
                  .setPosition(LatLng(position.latitude, position.longitude));
            });
          }
          final pin = formState.position ??
              LatLng(position.latitude, position.longitude);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              _PhotoPicker(photo: formState.photo, onTap: _showImageSourceSheet),
              const SizedBox(height: 28),
              const _SectionHeader(
                title: 'Where was it?',
                subtitle: 'Drag the pin to the exact spot.',
              ),
              const SizedBox(height: 12),
              Container(
                height: 220,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: GoogleMap(
                  style: kCatMapStyle,
                  initialCameraPosition: CameraPosition(target: pin, zoom: 16),
                  markers: {
                    Marker(
                      markerId: const MarkerId('new_sighting'),
                      position: pin,
                      draggable: true,
                      icon: _pinIcon ??
                          BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueOrange,
                          ),
                      anchor: CatMarkerIcon.anchor,
                      onDragEnd: (newPosition) => ref
                          .read(submissionFormControllerProvider.notifier)
                          .setPosition(newPosition),
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                ),
              ),
              const SizedBox(height: 28),
              const _SectionHeader(title: 'About the cat'),
              const SizedBox(height: 14),
              SubmissionForm(onChanged: (data) => _formData = data),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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
                  style: theme.textTheme.bodyMedium,
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: isSubmitting ? null : _submit,
            child: isSubmitting
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                : const Text('Post sighting'),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final File? photo;
  final VoidCallback onTap;

  const _PhotoPicker({required this.photo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          child: photo == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_a_photo_rounded,
                          size: 28,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Add a photo', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Take one now or pick from your gallery',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(photo!, fit: BoxFit.cover),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded,
                                  size: 16, color: scheme.onSurface),
                              const SizedBox(width: 6),
                              Text(
                                'Change photo',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
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
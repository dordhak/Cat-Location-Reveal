import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../providers/cat_sighting_providers.dart';
import '../../providers/location_provider.dart';
import '../../providers/submission_form_provider.dart';
import '../widgets/submission_form.dart';

class SubmitSightingScreen extends ConsumerStatefulWidget {
  const SubmitSightingScreen({super.key});

  @override
  ConsumerState<SubmitSightingScreen> createState() => _SubmitSightingScreenState();
}

class _SubmitSightingScreenState extends ConsumerState<SubmitSightingScreen> {
  SubmissionFormData? _formData;
  bool _positionInitialized = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: AppConstants.imageQuality,
    );
    if (picked != null) {
      ref.read(submissionFormControllerProvider.notifier).setPhoto(File(picked.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final formState = ref.read(submissionFormControllerProvider);
    final data = _formData;

    if (formState.photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo of the cat.')),
      );
      return;
    }
    if (formState.position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not ready yet. Please wait a moment.')),
      );
      return;
    }
    if (data == null || data.name.isEmpty || data.catType.isEmpty || data.primaryColor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    await ref.read(sightingSubmissionProvider.notifier).submit(
          photoFile: formState.photo!,
          name: data.name,
          catType: data.catType,
          primaryColor: data.primaryColor,
          friendlinessRating: data.friendlinessRating,
          latitude: formState.position!.latitude,
          longitude: formState.position!.longitude,
        );

    final result = ref.read(sightingSubmissionProvider);
    if (!mounted) return;

    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error.toString())),
      );
    } else {
      ref.read(submissionFormControllerProvider.notifier).reset();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cat sighting submitted! 🐱')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentLocationProvider);
    final formState = ref.watch(submissionFormControllerProvider);
    final submissionState = ref.watch(sightingSubmissionProvider);

    ref.listen(currentLocationProvider, (previous, next) {
      next.whenData((position) {
        if (!_positionInitialized) {
          _positionInitialized = true;
          ref.read(submissionFormControllerProvider.notifier).setPosition(
                LatLng(position.latitude, position.longitude),
              );
        }
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Spot a Cat')),
      body: locationAsync.when(
        data: (position) {
          if (!_positionInitialized) {
            _positionInitialized = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(submissionFormControllerProvider.notifier).setPosition(
                    LatLng(position.latitude, position.longitude),
                  );
            });
          }

          final pinPosition = formState.position ??
              LatLng(position.latitude, position.longitude);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: formState.photo != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(formState.photo!, fit: BoxFit.cover),
                          )
                        : const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Tap to add a photo'),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Drag the pin to adjust the exact spot',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: pinPosition,
                        zoom: AppConstants.defaultZoom,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('new_sighting'),
                          position: pinPosition,
                          draggable: true,
                          onDragEnd: (newPosition) {
                            ref.read(submissionFormControllerProvider.notifier).setPosition(newPosition);
                          },
                        ),
                      },
                      myLocationEnabled: true,
                      zoomControlsEnabled: false,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SubmissionForm(onChanged: (data) => _formData = data),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: submissionState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  child: submissionState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Sighting'),
                ),
              ],
            ),
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
    );
  }
}
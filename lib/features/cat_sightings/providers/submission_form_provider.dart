import 'dart:typed_data';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'submission_form_provider.g.dart';

class SubmissionFormState {
  final XFile? photo;
  final Uint8List? photoBytes;
  final LatLng? position;

  const SubmissionFormState({this.photo, this.photoBytes, this.position});

  SubmissionFormState copyWith({
    XFile? photo,
    Uint8List? photoBytes,
    LatLng? position,
  }) {
    return SubmissionFormState(
      photo: photo ?? this.photo,
      photoBytes: photoBytes ?? this.photoBytes,
      position: position ?? this.position,
    );
  }
}

@riverpod
class SubmissionFormController extends _$SubmissionFormController {
  @override
  SubmissionFormState build() => const SubmissionFormState();

  void setPhoto(XFile photo, Uint8List photoBytes) {
    state = state.copyWith(photo: photo, photoBytes: photoBytes);
  }

  void setPosition(LatLng position) {
    state = state.copyWith(position: position);
  }

  void reset() {
    state = const SubmissionFormState();
  }
}

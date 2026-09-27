import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'submission_form_provider.g.dart';

class SubmissionFormState {
  final File? photo;
  final LatLng? position;

  const SubmissionFormState({this.photo, this.position});

  SubmissionFormState copyWith({File? photo, LatLng? position}) {
    return SubmissionFormState(
      photo: photo ?? this.photo,
      position: position ?? this.position,
    );
  }
}

@riverpod
class SubmissionFormController extends _$SubmissionFormController {
  @override
  SubmissionFormState build() => const SubmissionFormState();

  void setPhoto(File photo) {
    state = state.copyWith(photo: photo);
  }

  void setPosition(LatLng position) {
    state = state.copyWith(position: position);
  }

  void reset() {
    state = const SubmissionFormState();
  }
}
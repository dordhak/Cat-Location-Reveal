import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import 'friendliness_rating_bar.dart';

class SubmissionFormData {
  final String name;
  final String catType;
  final String primaryColor;
  final int friendlinessRating;

  const SubmissionFormData({
    required this.name,
    required this.catType,
    required this.primaryColor,
    required this.friendlinessRating,
  });
}

class SubmissionForm extends StatefulWidget {
  final void Function(SubmissionFormData data) onChanged;

  const SubmissionForm({super.key, required this.onChanged});

  @override
  State<SubmissionForm> createState() => _SubmissionFormState();
}

class _SubmissionFormState extends State<SubmissionForm> {
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _colorController = TextEditingController();
  int _rating = 3;

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(SubmissionFormData(
      name: _nameController.text.trim(),
      catType: _typeController.text.trim(),
      primaryColor: _colorController.text.trim(),
      friendlinessRating: _rating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          maxLength: AppConstants.maxNameLength,
          decoration: const InputDecoration(
            labelText: 'Cat Name',
            hintText: 'e.g. Whiskers, Mochi, Ginger',
          ),
          onChanged: (_) => _notifyChange(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _typeController,
          decoration: const InputDecoration(
            labelText: 'Type / Breed',
            hintText: 'e.g. Tabby, Siamese, Mixed',
          ),
          onChanged: (_) => _notifyChange(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _colorController,
          decoration: const InputDecoration(
            labelText: 'Primary Color',
            hintText: 'e.g. Orange, Black, White',
          ),
          onChanged: (_) => _notifyChange(),
        ),
        const SizedBox(height: 16),
        const Text('Friendliness'),
        const SizedBox(height: 4),
        FriendlinessRatingBar(
          rating: _rating,
          readOnly: false,
          onRatingChanged: (value) {
            setState(() => _rating = value);
            _notifyChange();
          },
        ),
      ],
    );
  }
}
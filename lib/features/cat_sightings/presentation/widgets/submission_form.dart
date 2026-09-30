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
  static const _swatches = <(String, Color)>[
    ('Orange', Color(0xFFE8892B)),
    ('Black', Color(0xFF2B2530)),
    ('White', Color(0xFFFFFFFF)),
    ('Grey', Color(0xFF9A9AA5)),
    ('Brown', Color(0xFF8A5A3C)),
    ('Cream', Color(0xFFF1DDBB)),
  ];

  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _colorController = TextEditingController();
  int _rating = 3;

  @override
  void initState() {
    super.initState();
    // Report the default rating even if the user never touches the stars.
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyChange());
  }

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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final typedColor = _colorController.text.trim().toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          maxLength: AppConstants.maxNameLength,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g. Mochi',
            helperText: 'No tag? Make one up.',
            counterText: '',
            prefixIcon: Icon(Icons.local_offer_outlined),
          ),
          onChanged: (_) => _notifyChange(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _typeController,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Type or breed',
            hintText: 'Tabby, Siamese, mixed',
            prefixIcon: Icon(Icons.pets_rounded),
          ),
          onChanged: (_) => _notifyChange(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _colorController,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Fur color',
            hintText: 'Pick one below or type your own',
            prefixIcon: Icon(Icons.palette_outlined),
          ),
          onChanged: (_) {
            setState(() {});
            _notifyChange();
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final swatch in _swatches)
              ChoiceChip(
                avatar: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: swatch.$2,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                ),
                label: Text(swatch.$1),
                selected: typedColor == swatch.$1.toLowerCase(),
                onSelected: (_) {
                  setState(() => _colorController.text = swatch.$1);
                  _notifyChange();
                },
              ),
          ],
        ),
        const SizedBox(height: 28),
        Text('How friendly was it?', style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        FriendlinessRatingBar(
          rating: _rating,
          readOnly: false,
          itemSize: 40,
          onRatingChanged: (value) {
            setState(() => _rating = value);
            _notifyChange();
          },
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            friendlinessLabel(_rating),
            key: ValueKey(_rating),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
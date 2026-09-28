import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../core/theme/app_theme.dart';

/// Plain-language meaning for each star count.
String friendlinessLabel(int rating) {
  switch (rating) {
    case 1:
      return 'Keeps its distance';
    case 2:
      return 'Shy but curious';
    case 3:
      return 'Friendly enough';
    case 4:
      return 'Loves attention';
    case 5:
      return 'Total sweetheart';
    default:
      return '';
  }
}

class FriendlinessRatingBar extends StatelessWidget {
  final int rating;
  final bool readOnly;
  final ValueChanged<int>? onRatingChanged;
  final double itemSize;

  const FriendlinessRatingBar({
    super.key,
    required this.rating,
    this.readOnly = true,
    this.onRatingChanged,
    this.itemSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final unrated = Theme.of(context).colorScheme.outlineVariant;
    const star = Icon(Icons.star_rounded, color: AppColors.gold);

    if (readOnly) {
      return RatingBarIndicator(
        rating: rating.toDouble(),
        itemCount: 5,
        itemSize: itemSize,
        unratedColor: unrated,
        itemBuilder: (_, __) => star,
      );
    }

    return RatingBar.builder(
      initialRating: rating.toDouble(),
      minRating: 1,
      itemCount: 5,
      itemSize: itemSize,
      allowHalfRating: false,
      glow: false,
      unratedColor: unrated,
      itemPadding: const EdgeInsets.only(right: 6),
      itemBuilder: (_, __) => star,
      onRatingUpdate: (value) => onRatingChanged?.call(value.round()),
    );
  }
}
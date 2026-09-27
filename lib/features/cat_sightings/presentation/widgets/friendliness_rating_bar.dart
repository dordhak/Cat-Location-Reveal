import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
    if (readOnly) {
      return RatingBarIndicator(
        rating: rating.toDouble(),
        itemCount: 5,
        itemSize: itemSize,
        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
      );
    }

    return RatingBar.builder(
      initialRating: rating.toDouble(),
      minRating: 1,
      itemCount: 5,
      itemSize: itemSize,
      allowHalfRating: false,
      itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
      onRatingUpdate: (value) => onRatingChanged?.call(value.round()),
    );
  }
}
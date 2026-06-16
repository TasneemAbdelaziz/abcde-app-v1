import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A row of 5 stars. Filled stars are amber; empty stars are grey.
///
/// - [rating] = how many stars are filled (0..5).
/// - [onTap]  = optional; if given, tapping a star reports its value (1..5)
///   so a parent can make it interactive. If null, the row is display-only.
class StarRow extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onTap;
  final double size;

  const StarRow({
    super.key,
    required this.rating,
    this.onTap,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final filled = starValue <= rating;
        final icon = Icon(
          filled ? Icons.star : Icons.star_border,
          color: filled ? AppColors.amber : Colors.grey,
          size: size,
        );
        if (onTap == null) return icon;
        return GestureDetector(
          onTap: () => onTap!(starValue),
          child: icon,
        );
      }),
    );
  }
}

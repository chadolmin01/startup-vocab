import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CategoryBadge extends StatelessWidget {
  final String category;
  final double fontSize;

  const CategoryBadge({
    super.key,
    required this.category,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getCategoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          fontFamily: 'monospace',
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

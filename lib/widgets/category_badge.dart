import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CategoryBadge extends StatelessWidget {
  final String category;

  const CategoryBadge({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getCategoryColor(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        color: color.withValues(alpha: 0.08),
      ),
      child: Text(
        category.toUpperCase(),
        style: AppTextStyles.labelColored(color).copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

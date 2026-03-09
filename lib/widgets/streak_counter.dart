import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StreakCounter extends StatelessWidget {
  final int streak;

  const StreakCounter({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final isActive = streak > 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive
              ? AppColors.warning.withValues(alpha: 0.4)
              : AppColors.cardBorder,
        ),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        color: isActive ? AppColors.warning.withValues(alpha: 0.08) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 14,
            color: isActive ? AppColors.warning : AppColors.textMuted,
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            '${streak}D',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.warning : AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StreakCounter extends StatelessWidget {
  final int streak;

  const StreakCounter({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final isActive = streak > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? AppColors.warning.withValues(alpha: 0.4) : AppColors.cardBorder,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'STREAK',
            style: AppTextStyles.label.copyWith(
              color: isActive ? AppColors.warning : AppColors.textMuted,
              fontSize: 9,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 1,
            height: 12,
            color: AppColors.cardBorder,
          ),
          const SizedBox(width: 6),
          Text(
            '${streak}D',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isActive ? AppColors.warning : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

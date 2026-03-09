import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StreakCounter extends StatelessWidget {
  final int streak;

  const StreakCounter({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department,
          color: streak > 0 ? AppColors.warning : AppColors.textSecondary,
          size: 24,
        ),
        const SizedBox(width: 4),
        Text(
          '$streak일',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: streak > 0 ? AppColors.warning : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

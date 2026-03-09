import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../utils/constants.dart';

class ProgressBar extends StatelessWidget {
  final double percent;
  final String? label;
  final Color? progressColor;
  final double height;

  const ProgressBar({
    super.key,
    required this.percent,
    this.label,
    this.progressColor,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: height,
          percent: percent.clamp(0.0, 1.0),
          backgroundColor: AppColors.cardBorder,
          progressColor: progressColor ?? AppColors.accent,
          barRadius: Radius.circular(height / 2),
          animation: true,
          animationDuration: 500,
        ),
      ],
    );
  }
}

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
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!.toUpperCase(), style: AppTextStyles.label),
          const SizedBox(height: Spacing.xs),
        ],
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: height,
          percent: percent.clamp(0.0, 1.0),
          backgroundColor: AppColors.cardBorder,
          progressColor: progressColor ?? AppColors.accent,
          barRadius: const Radius.circular(2),
          animation: true,
          animationDuration: 400,
        ),
      ],
    );
  }
}

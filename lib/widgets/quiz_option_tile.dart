import 'package:flutter/material.dart';
import '../utils/constants.dart';

class QuizOptionTile extends StatelessWidget {
  final String text;
  final int index;
  final int? selectedAnswer;
  final int correctIndex;
  final VoidCallback onTap;

  const QuizOptionTile({
    super.key,
    required this.text,
    required this.index,
    required this.selectedAnswer,
    required this.correctIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedAnswer == index;
    final isCorrect = index == correctIndex;
    final hasAnswered = selectedAnswer != null;

    Color borderColor = AppColors.cardBorder;
    Color textColor = AppColors.textPrimary;
    Color bgColor = AppColors.cardBackground;
    Color indexColor = AppColors.textMuted;

    if (hasAnswered) {
      if (isCorrect) {
        borderColor = AppColors.success;
        textColor = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.08);
        indexColor = AppColors.success;
      } else if (isSelected) {
        borderColor = AppColors.error.withValues(alpha: 0.5);
        textColor = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.05);
        indexColor = AppColors.error;
      } else {
        textColor = AppColors.textMuted;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasAnswered ? null : onTap,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
              color: bgColor,
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(color: indexColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: indexColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ),
                if (hasAnswered && isCorrect)
                  const Icon(Icons.check, color: AppColors.success, size: 18),
                if (hasAnswered && isSelected && !isCorrect)
                  const Icon(Icons.close, color: AppColors.error, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

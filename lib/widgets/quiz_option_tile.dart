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

    Color backgroundColor = AppColors.cardBackground;
    Color borderColor = AppColors.cardBorder;
    Color indexColor = AppColors.textMuted;

    if (hasAnswered) {
      if (isCorrect) {
        backgroundColor = AppColors.success.withValues(alpha: 0.08);
        borderColor = AppColors.success;
        indexColor = AppColors.success;
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppColors.error.withValues(alpha: 0.08);
        borderColor = AppColors.error;
        indexColor = AppColors.error;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasAnswered ? null : onTap,
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: indexColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: AppColors.cardBorder,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasAnswered && isCorrect
                          ? AppColors.success
                          : hasAnswered && isSelected
                              ? AppColors.error
                              : AppColors.textPrimary,
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

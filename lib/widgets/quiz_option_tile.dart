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
    IconData? trailingIcon;

    if (hasAnswered) {
      if (isCorrect) {
        backgroundColor = AppColors.success.withValues(alpha: 0.15);
        borderColor = AppColors.success;
        trailingIcon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppColors.error.withValues(alpha: 0.15);
        borderColor = AppColors.error;
        trailingIcon = Icons.cancel;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: hasAnswered ? null : onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasAnswered && isCorrect
                            ? AppColors.success
                            : hasAnswered && isSelected
                                ? AppColors.error
                                : AppColors.textSecondary,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: hasAnswered && isCorrect
                              ? AppColors.success
                              : hasAnswered && isSelected
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 14,
                        color: hasAnswered && isCorrect
                            ? AppColors.success
                            : hasAnswered && isSelected
                                ? AppColors.error
                                : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (trailingIcon != null)
                    Icon(
                      trailingIcon,
                      color: isCorrect ? AppColors.success : AppColors.error,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

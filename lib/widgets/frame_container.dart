import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FrameContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final Color? backgroundColor;
  final String? label;

  const FrameContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.backgroundColor,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground,
        border: Border.all(color: borderColor ?? AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.sm,
              ),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Text(label!.toUpperCase(), style: AppTextStyles.label),
            ),
          Padding(
            padding: padding ?? const EdgeInsets.all(Spacing.lg),
            child: child,
          ),
        ],
      ),
    );
  }
}

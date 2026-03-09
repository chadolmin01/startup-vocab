import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Sharp-framed container — no glassmorphism, clean borders
class FrameContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final Color? backgroundColor;
  final String? label; // technical label top-left

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
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.cardBorder),
                ),
              ),
              child: Text(
                label!.toUpperCase(),
                style: AppTextStyles.label,
              ),
            ),
          Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }
}

// Keep GlassContainer as alias for backward compatibility during migration
typedef GlassContainer = FrameContainer;

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import '../models/term.dart';
import '../utils/constants.dart';
import 'glass_container.dart';

class TermCard extends StatelessWidget {
  final Term term;
  final GlobalKey<FlipCardState>? flipKey;

  const TermCard({
    super.key,
    required this.term,
    this.flipKey,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.5;

    return Semantics(
      label: '${term.termKo} 카드. 탭하여 뒤집기',
      child: FlipCard(
        key: flipKey,
        direction: FlipDirection.HORIZONTAL,
        speed: 300,
        front: _buildFront(cardHeight),
        back: _buildBack(cardHeight),
      ),
    );
  }

  Widget _buildFront(double cardHeight) {
    return FrameContainer(
      label: '${term.category} / Week ${term.week}',
      child: SizedBox(
        height: cardHeight - 60,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(term.termKo, style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: Spacing.md),
              Text(
                term.termEn,
                style: AppTextStyles.mono,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xxl),
              Text(
                'TAP TO FLIP',
                style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBack(double cardHeight) {
    return FrameContainer(
      label: 'DEFINITION',
      child: SizedBox(
        height: cardHeight - 60,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                term.definitionShort,
                style: AppTextStyles.h3.copyWith(height: 1.5),
              ),
              const SizedBox(height: Spacing.lg),
              Container(width: 24, height: 1, color: AppColors.cardBorder),
              const SizedBox(height: Spacing.lg),
              Text(term.definitionDetail, style: AppTextStyles.bodySecondary),
              const SizedBox(height: Spacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.lg),
                decoration: BoxDecoration(
                  border: const Border(
                    left: BorderSide(color: AppColors.accent, width: 2),
                  ),
                  color: AppColors.accent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(AppConstants.cardBorderRadius),
                    bottomRight: Radius.circular(AppConstants.cardBorderRadius),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EXAMPLE', style: AppTextStyles.labelColored(AppColors.accent)),
                    const SizedBox(height: Spacing.sm),
                    Text(term.example, style: AppTextStyles.small),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

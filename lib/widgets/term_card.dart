import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import '../models/term.dart';
import '../utils/constants.dart';
import 'category_badge.dart';
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
    final categoryColor = AppColors.getCategoryColor(term.category);
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.5;

    return FlipCard(
      key: flipKey,
      direction: FlipDirection.HORIZONTAL,
      speed: 300,
      front: _buildFront(categoryColor, cardHeight),
      back: _buildBack(categoryColor, cardHeight),
    );
  }

  Widget _buildFront(Color categoryColor, double cardHeight) {
    return FrameContainer(
      label: 'TERM // ${term.category}',
      borderColor: AppColors.cardBorder,
      child: SizedBox(
        height: cardHeight - 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CategoryBadge(category: term.category),
            const SizedBox(height: 28),
            Text(
              term.termKo,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              term.termEn,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: categoryColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 1,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  'TAP TO FLIP',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 1,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(Color categoryColor, double cardHeight) {
    return FrameContainer(
      label: 'DEFINITION // ${term.termEn}',
      borderColor: AppColors.cardBorder,
      child: SizedBox(
        height: cardHeight - 60,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryBadge(category: term.category),
              const SizedBox(height: 16),
              Text(
                term.definitionShort,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                term.definitionDetail,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 20),
              // Example box with sharp frame
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: categoryColor.withValues(alpha: 0.3)),
                        ),
                      ),
                      child: Text(
                        'CASE STUDY',
                        style: AppTextStyles.labelColored(categoryColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        term.example,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
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

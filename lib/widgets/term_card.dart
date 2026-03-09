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
    return GlassContainer(
      borderColor: categoryColor.withValues(alpha: 0.3),
      child: SizedBox(
        height: cardHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CategoryBadge(category: term.category),
            const SizedBox(height: 32),
            Text(
              term.termKo,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              term.termEn,
              style: TextStyle(
                fontSize: 16,
                color: categoryColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              '탭하여 뒤집기',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(Color categoryColor, double cardHeight) {
    return GlassContainer(
      borderColor: categoryColor.withValues(alpha: 0.3),
      child: SizedBox(
        height: cardHeight,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryBadge(category: term.category),
              const SizedBox(height: 16),
              Text(
                term.definitionShort,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                term.definitionDetail,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 16, color: categoryColor),
                        const SizedBox(width: 6),
                        Text(
                          '실제 사례',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      term.example,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
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

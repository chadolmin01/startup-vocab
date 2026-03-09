import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/term.dart';
import '../providers/progress_provider.dart';
import '../utils/constants.dart';
import '../widgets/term_card.dart';

class TermDetailScreen extends ConsumerWidget {
  final Term term;

  const TermDetailScreen({super.key, required this.term});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final isCompleted = progress.completedTermIds.contains(term.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(term.termKo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          child: Column(
            children: [
              Expanded(
                child: TermCard(term: term),
              ),
              const SizedBox(height: Spacing.lg),
              if (isCompleted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                    color: AppColors.success.withValues(alpha: 0.05),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check,
                          color: AppColors.success, size: 16),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'COMPLETED',
                        style: AppTextStyles.labelColored(AppColors.success),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(progressProvider.notifier)
                              .markCompleted(term.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('이해했어요'),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref
                              .read(progressProvider.notifier)
                              .markForReview(term.id);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          side: const BorderSide(color: AppColors.warning),
                        ),
                        child: const Text('다시 볼래요'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

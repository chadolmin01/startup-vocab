import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/terms_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/constants.dart';
import '../utils/app_date_utils.dart';
import '../widgets/term_card.dart';
import '../widgets/streak_counter.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTerm = ref.watch(todayTermProvider);
    final progress = ref.watch(progressProvider);
    final firstLaunch = ref.watch(firstLaunchDateProvider);
    final dayNumber = AppDateUtils.getDayNumber(firstLaunch);

    return Scaffold(
      body: SafeArea(
        child: todayTerm.when(
          data: (term) {
            final isCompleted = progress.completedTermIds.contains(term.id);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DAY $dayNumber',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.accent,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '오늘의 스타트업 용어',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      StreakCounter(streak: progress.streak),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Card
                  Expanded(
                    child: TermCard(term: term),
                  ),
                  const SizedBox(height: 16),
                  // Actions
                  if (isCompleted)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, color: AppColors.success, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'COMPLETED',
                            style: AppTextStyles.labelColored(AppColors.success).copyWith(fontSize: 11),
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
                            ),
                            child: const Text('이해했어요'),
                          ),
                        ),
                        const SizedBox(width: 8),
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
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('ERROR: $e',
                style: AppTextStyles.label.copyWith(color: AppColors.error)),
          ),
        ),
      ),
    );
  }
}

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Day $dayNumber',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      StreakCounter(streak: progress.streak),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '오늘의 스타트업 용어',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TermCard(term: term),
                  ),
                  const SizedBox(height: 16),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,
                              color: AppColors.success, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '오늘의 학습을 완료했어요!',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref
                                  .read(progressProvider.notifier)
                                  .markCompleted(term.id);
                            },
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('이해했어요'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ref
                                  .read(progressProvider.notifier)
                                  .markForReview(term.id);
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('다시 볼래요'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.warning,
                              side: const BorderSide(color: AppColors.warning),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
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
            child: Text('용어를 불러올 수 없습니다: $e',
                style: const TextStyle(color: AppColors.error)),
          ),
        ),
      ),
    );
  }
}

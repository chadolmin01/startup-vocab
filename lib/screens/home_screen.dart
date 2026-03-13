import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/term.dart';
import '../models/study_progress.dart';
import '../providers/terms_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/constants.dart';
import '../utils/app_date_utils.dart';
import '../widgets/term_card.dart';
import '../widgets/streak_counter.dart';
import '../widgets/progress_bar.dart';
import '../widgets/star_field.dart';
import '../widgets/celebration_overlay.dart';
import '../services/widget_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  bool _initialized = false;
  int? _lastWidgetTermId;
  bool _showCelebration = false;
  bool _wasGoalReached = false;

  List<Term> _getStudyQueue(List<Term> allTerms, Set<int> completedIds) {
    final firstLaunch = ref.read(firstLaunchDateProvider);
    final todayIndex = AppDateUtils.getTodayTermIndex(firstLaunch);

    final unlearned = <Term>[];
    for (int i = 0; i < allTerms.length; i++) {
      final idx = (todayIndex + i) % allTerms.length;
      if (!completedIds.contains(allTerms[idx].id)) {
        unlearned.add(allTerms[idx]);
      }
    }
    return unlearned;
  }

  @override
  Widget build(BuildContext context) {
    final termsAsync = ref.watch(termsProvider);
    final progress = ref.watch(progressProvider);
    final firstLaunch = ref.watch(firstLaunchDateProvider);
    final dayNumber = AppDateUtils.getDayNumber(firstLaunch);

    // Detect daily goal just reached
    if (progress.isDailyGoalReached && !_wasGoalReached) {
      _wasGoalReached = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _showCelebration = true);
        Future.delayed(const Duration(milliseconds: 1600), () {
          if (mounted) setState(() => _showCelebration = false);
        });
      });
    } else if (!progress.isDailyGoalReached) {
      _wasGoalReached = false;
    }

    return Scaffold(
      body: CelebrationOverlay(
        trigger: _showCelebration,
        child: StarField(
        starCount: 50,
        child: SafeArea(
          child: termsAsync.when(
          data: (allTerms) {
            final queue = _getStudyQueue(allTerms, progress.completedTermIds);

            if (!_initialized || _currentIndex >= queue.length) {
              _currentIndex = 0;
              _initialized = true;
            }

            if (queue.isEmpty) {
              return _buildAllComplete(progress, allTerms.length);
            }

            final term = queue[_currentIndex];
            final isCompleted = progress.completedTermIds.contains(term.id);

            // Update home widget (post-frame to avoid side effect in build)
            if (!kIsWeb && _lastWidgetTermId != term.id) {
              _lastWidgetTermId = term.id;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                WidgetService.updateWidget(term: term, dayNumber: dayNumber);
              });
            }

            return Padding(
              padding: const EdgeInsets.all(Spacing.screenPadding),
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
                            style: AppTextStyles.labelColored(AppColors.accent),
                          ),
                          const SizedBox(height: Spacing.xs),
                          const Text('오늘의 스타트업 용어', style: AppTextStyles.h2),
                        ],
                      ),
                      StreakCounter(streak: progress.streak),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  // Daily goal
                  _buildDailyGoal(progress),
                  const SizedBox(height: Spacing.md),
                  // Total progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${progress.totalCompleted} / ${allTerms.length} 전체 학습',
                        style: AppTextStyles.label,
                      ),
                      if (queue.length > 1)
                        Text(
                          '${queue.length}개 남음',
                          style: AppTextStyles.label,
                        ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  // Card
                  Expanded(
                    child: TermCard(key: ValueKey(term.id), term: term),
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Actions
                  if (isCompleted)
                    _buildNextButton(queue)
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            button: true,
                            label: '이해했어요 - 학습 완료로 표시',
                            child: ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(progressProvider.notifier)
                                    .markCompleted(term.id);
                                if (queue.length > 1) {
                                  Future.delayed(
                                    const Duration(milliseconds: 300),
                                    () {
                                      if (mounted) setState(() {});
                                    },
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('이해했어요'),
                            ),
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Semantics(
                            button: true,
                            label: '다시 볼래요 - 복습 목록에 추가',
                            child: OutlinedButton(
                              onPressed: () {
                                ref
                                    .read(progressProvider.notifier)
                                    .markForReview(term.id);
                                ScaffoldMessenger.of(context)
                                  ..clearSnackBars()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.bookmark_added,
                                              color: AppColors.warning, size: 18),
                                          const SizedBox(width: Spacing.sm),
                                          Text(
                                            '복습 목록에 추가했어요',
                                            style: AppTextStyles.body.copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: AppColors.cardBackground,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(milliseconds: 1500),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(color: AppColors.warning, width: 0.5),
                                      ),
                                    ),
                                  );
                                if (queue.length > 1) {
                                  setState(() {
                                    _currentIndex =
                                        (_currentIndex + 1) % queue.length;
                                  });
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.warning,
                                side: const BorderSide(color: AppColors.warning),
                              ),
                              child: const Text('다시 볼래요'),
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
            child: Text('ERROR: $e',
                style: AppTextStyles.label.copyWith(color: AppColors.error)),
          ),
        ),
      ),
      ),
      ),
    );
  }

  Widget _buildDailyGoal(StudyProgress progress) {
    final goalReached = progress.isDailyGoalReached;
    final color = goalReached ? AppColors.success : AppColors.accent;

    return GestureDetector(
      onTap: () => _showGoalPicker(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: goalReached
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.cardBorder,
          ),
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          color: goalReached
              ? AppColors.success.withValues(alpha: 0.05)
              : AppColors.cardBackground,
        ),
        child: Row(
          children: [
            Icon(
              goalReached ? Icons.check_circle : Icons.flag,
              color: color,
              size: 18,
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goalReached ? 'TODAY\'S GOAL REACHED!' : 'TODAY\'S GOAL',
                    style: AppTextStyles.labelColored(color),
                  ),
                  const SizedBox(height: Spacing.xs),
                  ProgressBar(
                    percent: progress.dailyGoalProgress,
                    progressColor: color,
                    height: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              '${progress.todayLearnedCount}/${progress.dailyGoal}',
              style: AppTextStyles.mono.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalPicker() {
    final progress = ref.read(progressProvider);
    int selected = progress.dailyGoal;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('일일 목표 설정', style: AppTextStyles.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$selected개',
                style: AppTextStyles.stat.copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: Spacing.lg),
              Slider(
                value: selected.toDouble(),
                min: 1,
                max: 20,
                divisions: 19,
                activeColor: AppColors.accent,
                inactiveColor: AppColors.cardBorder,
                onChanged: (v) {
                  setDialogState(() => selected = v.round());
                },
              ),
              Text('하루에 학습할 용어 수', style: AppTextStyles.small),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                ref.read(progressProvider.notifier).setDailyGoal(selected);
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(List<Term> queue) {
    if (queue.length <= 1) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        decoration: BoxDecoration(
          border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3)),
          borderRadius:
              BorderRadius.circular(AppConstants.cardBorderRadius),
          color: AppColors.success.withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check, color: AppColors.success, size: 16),
            const SizedBox(width: Spacing.sm),
            Text('COMPLETED',
                style: AppTextStyles.labelColored(AppColors.success)),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _currentIndex = (_currentIndex + 1) % queue.length;
          });
        },
        child: const Text('다음 용어'),
      ),
    );
  }

  Widget _buildAllComplete(StudyProgress progress, int total) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.screenPadding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 48, color: AppColors.warning),
            const SizedBox(height: Spacing.lg),
            const Text('축하합니다!', style: AppTextStyles.h1),
            const SizedBox(height: Spacing.sm),
            Text(
              '모든 $total개 용어를 학습했어요',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: Spacing.xl),
            Text(
              '퀴즈에 도전하거나 사전에서 복습해보세요',
              style: AppTextStyles.small,
            ),
          ],
        ),
      ),
    );
  }
}

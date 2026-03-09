import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/term.dart';
import '../models/study_progress.dart';
import '../providers/progress_provider.dart';
import '../providers/terms_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/radar_chart_widget.dart';
import '../widgets/progress_bar.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';
import 'term_detail_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final nickname = prefs.getString(SPKeys.nickname) ?? '사용자';
    final termsAsync = ref.watch(termsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                      color: AppColors.accent.withValues(alpha: 0.08),
                    ),
                    child: Center(
                      child: Text(
                        nickname.isNotEmpty ? nickname[0].toUpperCase() : '?',
                        style: AppTextStyles.h2.copyWith(color: AppColors.accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nickname, style: AppTextStyles.h3),
                        Text('ODYSSEY VENTURES', style: AppTextStyles.label),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined, size: 20),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),

              // Stats
              FrameContainer(
                label: 'DASHBOARD',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem(
                      value: '${progress.streak}D',
                      label: 'STREAK',
                      color: AppColors.warning,
                    ),
                    Container(width: 1, height: 40, color: AppColors.cardBorder),
                    _statItem(
                      value: '${progress.totalCompleted}',
                      label: 'LEARNED',
                      color: AppColors.success,
                    ),
                    Container(width: 1, height: 40, color: AppColors.cardBorder),
                    _statItem(
                      value: '${(progress.averageQuizAccuracy * 100).toInt()}%',
                      label: 'ACCURACY',
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Leaderboard
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                  child: const Text('LEADERBOARD'),
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // Radar chart
              Text('CATEGORY PROGRESS', style: AppTextStyles.labelBright),
              const SizedBox(height: Spacing.md),
              termsAsync.when(
                data: (terms) {
                  final categoryProgress =
                      _calculateCategoryProgress(terms, progress);
                  return Column(
                    children: [
                      FrameContainer(
                        child: RadarChartWidget(
                            categoryProgress: categoryProgress),
                      ),
                      const SizedBox(height: Spacing.lg),
                      ...categoryProgress.entries.map((e) {
                        final color = AppColors.getCategoryColor(e.key);
                        final termCount = terms
                            .where((t) => t.category == e.key)
                            .length;
                        final completed = terms
                            .where((t) =>
                                t.category == e.key &&
                                progress.completedTermIds.contains(t.id))
                            .length;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.md),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    e.key.toUpperCase(),
                                    style: AppTextStyles.labelColored(color),
                                  ),
                                  Text(
                                    '$completed / $termCount',
                                    style: AppTextStyles.label,
                                  ),
                                ],
                              ),
                              const SizedBox(height: Spacing.xs),
                              ProgressBar(
                                percent: e.value,
                                progressColor: color,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => const SizedBox(),
              ),
              const SizedBox(height: Spacing.xl),

              // Review terms
              _buildReviewSection(context, termsAsync, progress),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.stat.copyWith(color: color)),
        const SizedBox(height: Spacing.xs),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }

  Map<String, double> _calculateCategoryProgress(
    List<Term> terms,
    StudyProgress progress,
  ) {
    final categories = ['Start', 'Build', 'Scale', 'Invest', 'Final'];
    final result = <String, double>{};
    for (final cat in categories) {
      final catTerms = terms.where((t) => t.category == cat);
      if (catTerms.isEmpty) {
        result[cat] = 0.0;
        continue;
      }
      final completed = catTerms
          .where((t) => progress.completedTermIds.contains(t.id))
          .length;
      result[cat] = completed / catTerms.length;
    }
    return result;
  }

  Widget _buildReviewSection(BuildContext context,
      AsyncValue<List<Term>> termsAsync, StudyProgress progress) {
    if (progress.reviewTermIds.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('REVIEW LIST', style: AppTextStyles.labelColored(AppColors.warning)),
        const SizedBox(height: Spacing.md),
        termsAsync.when(
          data: (terms) {
            final reviewTerms = terms
                .where((t) => progress.reviewTermIds.contains(t.id))
                .toList();
            return Column(
              children: reviewTerms.map((term) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                    color: AppColors.cardBackground,
                  ),
                  child: ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Spacing.lg,
                      vertical: Spacing.xs,
                    ),
                    title: Text(
                      term.termKo,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(term.termEn, style: AppTextStyles.mono),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textMuted, size: 18),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TermDetailScreen(term: term),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const SizedBox(),
          error: (_, _) => const SizedBox(),
        ),
      ],
    );
  }

}

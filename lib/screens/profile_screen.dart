import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/term.dart';
import '../models/study_progress.dart';
import '../providers/progress_provider.dart';
import '../providers/terms_provider.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/radar_chart_widget.dart';
import '../widgets/progress_bar.dart';
import 'leaderboard_screen.dart';
import 'term_detail_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _notificationsEnabled =
        prefs.getBool(SPKeys.notificationEnabled) ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final nickname = prefs.getString(SPKeys.nickname) ?? '사용자';
    final termsAsync = ref.watch(termsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(4),
                      color: AppColors.accent.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Text(
                        nickname.isNotEmpty ? nickname[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              nickname,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _editNickname(prefs, nickname),
                              child: const Icon(Icons.edit,
                                  size: 14, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ODYSSEY VENTURES',
                          style: AppTextStyles.label,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
              const SizedBox(height: 12),

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
              const SizedBox(height: 24),

              // Radar chart
              Text('CATEGORY PROGRESS', style: AppTextStyles.labelBright),
              const SizedBox(height: 12),
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
                      const SizedBox(height: 16),
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
                          padding: const EdgeInsets.only(bottom: 10),
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
                                    style: AppTextStyles.label.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ProgressBar(
                                percent: e.value,
                                progressColor: color,
                                height: 3,
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
              const SizedBox(height: 24),

              // Review terms
              _buildReviewSection(termsAsync, progress),
              const SizedBox(height: 24),

              // Settings
              Text('SETTINGS', style: AppTextStyles.labelBright),
              const SizedBox(height: 12),
              FrameContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        '학습 리마인더 알림',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        'DAILY 09:00',
                        style: AppTextStyles.label.copyWith(fontSize: 9),
                      ),
                      value: _notificationsEnabled,
                      activeTrackColor: AppColors.accent,
                      onChanged: (value) async {
                        setState(() => _notificationsEnabled = value);
                        await prefs.setBool(
                            SPKeys.notificationEnabled, value);
                        if (value) {
                          await NotificationService.requestPermission();
                          await NotificationService.scheduleDailyReminder();
                        } else {
                          await NotificationService.cancelAll();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _confirmReset(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: const Text('학습 리셋'),
                ),
              ),
              const SizedBox(height: 32),
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
        Text(
          value,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.label.copyWith(fontSize: 9),
        ),
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

  Widget _buildReviewSection(
      AsyncValue<List<Term>> termsAsync, StudyProgress progress) {
    if (progress.reviewTermIds.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('REVIEW LIST', style: AppTextStyles.labelColored(AppColors.warning)),
        const SizedBox(height: 12),
        termsAsync.when(
          data: (terms) {
            final reviewTerms = terms
                .where((t) => progress.reviewTermIds.contains(t.id))
                .toList();
            return Column(
              children: reviewTerms.map((term) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.cardBackground,
                  ),
                  child: ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      term.termKo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      term.termEn,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textMuted, size: 16),
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

  void _editNickname(SharedPreferences prefs, String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('닉네임 수정', style: TextStyle(fontSize: 16)),
        content: TextField(
          controller: controller,
          maxLength: 10,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: '새 닉네임'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.length >= 2) {
                await prefs.setString(SPKeys.nickname, newName);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('학습 리셋', style: TextStyle(fontSize: 16)),
        content: const Text(
          '모든 학습 기록이 초기화됩니다.\n계속하시겠습니까?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(progressProvider.notifier).resetProgress();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('리셋'),
          ),
        ],
      ),
    );
  }
}

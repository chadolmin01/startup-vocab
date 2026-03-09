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
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.accent,
                    child: Text(
                      nickname.isNotEmpty ? nickname[0] : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  size: 16, color: AppColors.textSecondary),
                              onPressed: () => _editNickname(prefs, nickname),
                            ),
                          ],
                        ),
                        Text(
                          'Odyssey Ventures',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Dashboard stats
              GlassContainer(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem(
                          icon: Icons.local_fire_department,
                          value: '${progress.streak}일',
                          label: '연속 학습',
                          color: AppColors.warning,
                        ),
                        _statItem(
                          icon: Icons.book,
                          value: '${progress.totalCompleted}',
                          label: '학습 용어',
                          color: AppColors.success,
                        ),
                        _statItem(
                          icon: Icons.quiz,
                          value:
                              '${(progress.averageQuizAccuracy * 100).toInt()}%',
                          label: '퀴즈 정답률',
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Leaderboard button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.leaderboard, size: 18),
                  label: const Text('리더보드'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Radar chart
              const Text(
                '카테고리별 학습 현황',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              termsAsync.when(
                data: (terms) {
                  final categoryProgress =
                      _calculateCategoryProgress(terms, progress);
                  return Column(
                    children: [
                      GlassContainer(
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
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    e.key,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$completed / $termCount',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ProgressBar(
                                percent: e.value,
                                progressColor: color,
                                height: 8,
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
              const Text(
                '설정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        '학습 리마인더 알림',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textPrimary),
                      ),
                      subtitle: const Text(
                        '매일 오전 9시 알림',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmReset(),
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: const Text('학습 리셋'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
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
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
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
        const Text(
          '다시 볼래요',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        termsAsync.when(
          data: (terms) {
            final reviewTerms = terms
                .where((t) => progress.reviewTermIds.contains(t.id))
                .toList();
            return Column(
              children: reviewTerms.map((term) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.refresh,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    title: Text(
                      term.termKo,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      term.termEn,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
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
        backgroundColor: AppColors.cardBackground,
        title: const Text('닉네임 수정'),
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
        backgroundColor: AppColors.cardBackground,
        title: const Text('학습 리셋'),
        content: const Text(
          '모든 학습 기록이 초기화됩니다.\n계속하시겠습니까?',
          style: TextStyle(color: AppColors.textSecondary),
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

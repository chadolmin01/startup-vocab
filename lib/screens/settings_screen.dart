import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/progress_provider.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/star_field.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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
    final prefs = ref.watch(sharedPreferencesProvider);
    final progress = ref.watch(progressProvider);
    final nickname = prefs.getString(SPKeys.nickname) ?? '사용자';

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StarField(
        starCount: 30,
        showShootingStars: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === PROFILE ===
              Text('PROFILE', style: AppTextStyles.labelBright),
              const SizedBox(height: Spacing.md),
              FrameContainer(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _settingsTile(
                      icon: Icons.person_outline,
                      title: '닉네임',
                      trailing: Text(nickname, style: AppTextStyles.mono),
                      onTap: () => _editNickname(prefs, nickname),
                    ),
                    const Divider(height: 1, indent: 52),
                    _settingsTile(
                      icon: Icons.flag_outlined,
                      title: '일일 학습 목표',
                      trailing: Text(
                        '${progress.dailyGoal}개',
                        style: AppTextStyles.mono,
                      ),
                      onTap: () => _showGoalPicker(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // === NOTIFICATIONS ===
              Text('NOTIFICATION', style: AppTextStyles.labelBright),
              const SizedBox(height: Spacing.md),
              FrameContainer(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _settingsToggle(
                      icon: Icons.notifications_outlined,
                      title: '학습 리마인더',
                      subtitle: '하루 1회',
                      value: _notificationsEnabled,
                      onChanged: (value) async {
                        setState(() => _notificationsEnabled = value);
                        await prefs.setBool(
                            SPKeys.notificationEnabled, value);
                        if (kIsWeb) return;
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
              const SizedBox(height: Spacing.xl),

              // === DATA ===
              Text('DATA', style: AppTextStyles.labelBright),
              const SizedBox(height: Spacing.md),
              FrameContainer(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _settingsTile(
                      icon: Icons.bar_chart,
                      title: '학습 통계',
                      trailing: Text(
                        '${progress.totalCompleted}/${AppConstants.totalTerms}',
                        style: AppTextStyles.mono,
                      ),
                    ),
                    const Divider(height: 1, indent: 52),
                    _settingsTile(
                      icon: Icons.quiz_outlined,
                      title: '퀴즈 기록',
                      trailing: Text(
                        '${progress.totalQuizCount}회 / 평균 ${(progress.averageQuizAccuracy * 100).toInt()}%',
                        style: AppTextStyles.mono,
                      ),
                    ),
                    const Divider(height: 1, indent: 52),
                    _settingsTile(
                      icon: Icons.delete_outline,
                      title: '학습 데이터 초기화',
                      titleColor: AppColors.error,
                      onTap: () => _confirmReset(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // === ABOUT ===
              Text('ABOUT', style: AppTextStyles.labelBright),
              const SizedBox(height: Spacing.md),
              FrameContainer(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _settingsTile(
                      icon: Icons.rocket_launch_outlined,
                      title: 'Startup Bite',
                      trailing: Text('v1.0.0', style: AppTextStyles.mono),
                    ),
                    const Divider(height: 1, indent: 52),
                    _settingsTile(
                      icon: Icons.group_outlined,
                      title: 'Odyssey Ventures',
                      trailing: Text(
                        '한국외대',
                        style: AppTextStyles.small,
                      ),
                    ),
                    const Divider(height: 1, indent: 52),
                    _settingsTile(
                      icon: Icons.code,
                      title: '기술 스택',
                      trailing: Text(
                        'Flutter + Supabase',
                        style: AppTextStyles.mono,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: titleColor ?? AppColors.textMuted),
            const SizedBox(width: Spacing.lg),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: titleColor,
                ),
              ),
            ),
            ?trailing,
            if (onTap != null) ...[
              const SizedBox(width: Spacing.sm),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: titleColor ?? AppColors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _settingsToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body),
                Text(subtitle, style: AppTextStyles.label),
              ],
            ),
          ),
          SizedBox(
            height: 28,
            child: Switch(
              value: value,
              activeTrackColor: AppColors.accent,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _editNickname(SharedPreferences prefs, String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('닉네임 수정', style: AppTextStyles.h3),
        content: TextField(
          controller: controller,
          maxLength: 10,
          style: AppTextStyles.body,
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
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('저장'),
          ),
        ],
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

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('학습 데이터 초기화', style: AppTextStyles.h3),
        content: Text(
          '모든 학습 기록이 초기화됩니다.\n이 작업은 되돌릴 수 없습니다.',
          style: AppTextStyles.bodySecondary,
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
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }
}

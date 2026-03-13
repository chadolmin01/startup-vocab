import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/progress_provider.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);
    final userRank = ref.watch(userRankProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final myDeviceId = prefs.getString(SPKeys.deviceId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LEADERBOARD'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: !SupabaseService.isAvailable
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.screenPadding),
                  child: FrameContainer(
                    label: 'STATUS // OFFLINE',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off,
                            size: 32, color: AppColors.textMuted),
                        const SizedBox(height: Spacing.lg),
                        const Text(
                          '리더보드를 사용할 수 없습니다',
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          'SUPABASE CONNECTION REQUIRED',
                          style: AppTextStyles.label,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(leaderboardProvider);
                  ref.invalidate(userRankProvider);
                },
                child: Column(
                  children: [
                    // My rank
                    userRank.when(
                      data: (rank) {
                        if (rank == null) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.all(Spacing.screenPadding),
                          child: FrameContainer(
                            label: 'MY RANK',
                            borderColor: AppColors.accent,
                            child: Center(
                              child: Text(
                                '#$rank',
                                style: AppTextStyles.stat.copyWith(
                                  fontSize: 28,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (_, _) => const SizedBox(),
                    ),
                    // List
                    Expanded(
                      child: leaderboard.when(
                        data: (entries) {
                          if (entries.isEmpty) {
                            return Center(
                              child: Text('NO ENTRIES', style: AppTextStyles.label),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.screenPadding,
                            ),
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              final isMe = entry['device_id'] == myDeviceId;
                              return _buildRankTile(index + 1, entry, isMe);
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(
                          child: Text('ERROR: $e',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.error)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRankTile(int rank, Map<String, dynamic> entry, bool isMe) {
    final Color rankColor;
    if (rank == 1) {
      rankColor = AppColors.warning;
    } else if (rank <= 3) {
      rankColor = AppColors.textSecondary;
    } else {
      rankColor = AppColors.textMuted;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      decoration: BoxDecoration(
        border: Border.all(
          color: isMe ? AppColors.accent.withValues(alpha: 0.5) : AppColors.cardBorder,
        ),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        color: isMe ? AppColors.accent.withValues(alpha: 0.05) : AppColors.cardBackground,
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.xs,
        ),
        leading: SizedBox(
          width: 32,
          child: Text(
            '#$rank',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: rankColor,
            ),
          ),
        ),
        title: Text(
          entry['nickname'] ?? '???',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
            color: isMe ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'QUIZ ${entry['quiz_count'] ?? 0}',
          style: AppTextStyles.label,
        ),
        trailing: Text(
          '${entry['total_score'] ?? 0}',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isMe ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

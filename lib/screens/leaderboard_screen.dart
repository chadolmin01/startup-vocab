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
        title: const Text(
          '리더보드',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: !SupabaseService.isAvailable
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: GlassContainer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off,
                            size: 48, color: AppColors.textSecondary),
                        SizedBox(height: 16),
                        Text(
                          '리더보드를 사용할 수 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Supabase 설정이 필요합니다.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
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
                          padding: const EdgeInsets.all(16),
                          child: GlassContainer(
                            borderColor: AppColors.accent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.emoji_events,
                                    color: AppColors.accent),
                                const SizedBox(width: 8),
                                Text(
                                  '내 순위: $rank위',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (_, _) => const SizedBox(),
                    ),
                    // Leaderboard list
                    Expanded(
                      child: leaderboard.when(
                        data: (entries) {
                          if (entries.isEmpty) {
                            return const Center(
                              child: Text(
                                '아직 랭킹이 없습니다',
                                style: TextStyle(
                                    color: AppColors.textSecondary),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              final isMe =
                                  entry['device_id'] == myDeviceId;
                              return _buildRankTile(
                                  index + 1, entry, isMe);
                            },
                          );
                        },
                        loading: () => const Center(
                            child: CircularProgressIndicator()),
                        error: (e, _) => Center(
                          child: Text('불러오기 실패: $e',
                              style: const TextStyle(
                                  color: AppColors.error)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRankTile(
      int rank, Map<String, dynamic> entry, bool isMe) {
    final Color rankColor;
    final IconData? rankIcon;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
      rankIcon = Icons.emoji_events;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      rankIcon = Icons.emoji_events;
    } else {
      rankColor = AppColors.textSecondary;
      rankIcon = null;
    }

    return Card(
      color: isMe
          ? AppColors.accent.withValues(alpha: 0.15)
          : AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          child: rankIcon != null
              ? Icon(rankIcon, color: rankColor, size: 28)
              : Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                ),
        ),
        title: Text(
          entry['nickname'] ?? '???',
          style: TextStyle(
            fontSize: 15,
            fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
            color: isMe ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '퀴즈 ${entry['quiz_count'] ?? 0}회',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Text(
          '${entry['total_score'] ?? 0}점',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isMe ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

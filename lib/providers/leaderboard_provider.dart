import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';
import '../providers/progress_provider.dart';

final leaderboardProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return SupabaseService.fetchLeaderboard(
    limit: AppConstants.leaderboardTopN,
  );
});

final userRankProvider = FutureProvider<int?>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  final deviceId = prefs.getString(SPKeys.deviceId);
  if (deviceId == null) return null;
  return SupabaseService.fetchUserRank(deviceId);
});

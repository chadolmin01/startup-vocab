import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _initialized = false;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _initialized = true;
    } catch (e) {
      AppLogger.error('SupabaseService.initialize', e);
      _initialized = false;
    }
  }

  static bool get isAvailable =>
      _initialized &&
      AppConstants.supabaseUrl != 'YOUR_SUPABASE_URL';

  static SupabaseClient? get client => _client;

  static Future<void> submitScore({
    required String deviceId,
    required String nickname,
    required int totalScore,
    required int quizCount,
    required int streak,
  }) async {
    if (!isAvailable) return;
    try {
      await _client!.from('leaderboard').upsert(
        {
          'device_id': deviceId,
          'nickname': nickname,
          'total_score': totalScore,
          'quiz_count': quizCount,
          'streak': streak,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'device_id',
      );
    } catch (e) {
      AppLogger.error('SupabaseService.submitScore', e);
    }
  }

  static Future<List<Map<String, dynamic>>> fetchLeaderboard({
    int limit = 20,
  }) async {
    if (!isAvailable) return [];
    try {
      final response = await _client!
          .from('leaderboard')
          .select()
          .order('total_score', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('SupabaseService.fetchLeaderboard', e);
      rethrow;
    }
  }

  static Future<int?> fetchUserRank(String deviceId) async {
    if (!isAvailable) return null;
    try {
      final response = await _client!
          .from('leaderboard')
          .select()
          .order('total_score', ascending: false);
      final list = List<Map<String, dynamic>>.from(response);
      for (int i = 0; i < list.length; i++) {
        if (list[i]['device_id'] == deviceId) return i + 1;
      }
      return null;
    } catch (e) {
      AppLogger.error('SupabaseService.fetchUserRank', e);
      return null;
    }
  }
}

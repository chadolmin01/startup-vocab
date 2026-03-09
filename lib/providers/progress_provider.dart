import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_result.dart';
import '../models/study_progress.dart';
import '../utils/constants.dart';
import '../utils/app_date_utils.dart';
import '../services/supabase_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main.dart');
});

final progressProvider =
    StateNotifierProvider<ProgressNotifier, StudyProgress>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProgressNotifier(prefs);
});

class ProgressNotifier extends StateNotifier<StudyProgress> {
  final SharedPreferences _prefs;

  ProgressNotifier(this._prefs) : super(const StudyProgress()) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final completedIds = _prefs.getStringList(SPKeys.completedTermIds) ?? [];
    final reviewIds = _prefs.getStringList(SPKeys.reviewTermIds) ?? [];
    final quizJson = _prefs.getStringList(SPKeys.quizHistory) ?? [];
    final streak = _prefs.getInt(SPKeys.streak) ?? 0;
    final lastStudyStr = _prefs.getString(SPKeys.lastStudyDate);

    final lastStudy =
        lastStudyStr != null ? DateTime.tryParse(lastStudyStr) : null;

    final quizHistory = quizJson
        .map((s) {
          try {
            return QuizResult.fromJson(json.decode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<QuizResult>()
        .toList();

    final validStreak = AppDateUtils.calculateStreak(lastStudy, streak);

    state = StudyProgress(
      completedTermIds: completedIds.map(int.parse).toSet(),
      reviewTermIds: reviewIds.map(int.parse).toSet(),
      quizHistory: quizHistory,
      streak: validStreak,
      lastStudyDate: lastStudy,
    );

    if (validStreak != streak) {
      _saveToPrefs();
    }
  }

  Future<void> markCompleted(int termId) async {
    final newCompleted = {...state.completedTermIds, termId};
    final newReview = {...state.reviewTermIds}..remove(termId);
    final now = DateTime.now();
    final newStreak = _calculateNewStreak(now);

    state = state.copyWith(
      completedTermIds: newCompleted,
      reviewTermIds: newReview,
      streak: newStreak,
      lastStudyDate: now,
    );
    await _saveToPrefs();
  }

  Future<void> markForReview(int termId) async {
    final newReview = {...state.reviewTermIds, termId};
    final now = DateTime.now();
    final newStreak = _calculateNewStreak(now);

    state = state.copyWith(
      reviewTermIds: newReview,
      streak: newStreak,
      lastStudyDate: now,
    );
    await _saveToPrefs();
  }

  int _calculateNewStreak(DateTime now) {
    if (state.lastStudyDate == null) return 1;
    if (AppDateUtils.isToday(state.lastStudyDate!)) return state.streak;
    if (AppDateUtils.isYesterday(state.lastStudyDate!)) {
      return state.streak + 1;
    }
    return 1;
  }

  Future<void> addQuizResult(QuizResult result) async {
    final newHistory = [...state.quizHistory, result];
    state = state.copyWith(quizHistory: newHistory);
    await _saveToPrefs();

    // Submit to Supabase
    final deviceId = _prefs.getString(SPKeys.deviceId);
    final nickname = _prefs.getString(SPKeys.nickname);
    if (deviceId != null && nickname != null) {
      await SupabaseService.submitScore(
        deviceId: deviceId,
        nickname: nickname,
        totalScore: state.totalQuizScore,
        quizCount: state.totalQuizCount,
        streak: state.streak,
      );
    }
  }

  Future<void> resetProgress() async {
    state = const StudyProgress();
    await _prefs.remove(SPKeys.completedTermIds);
    await _prefs.remove(SPKeys.reviewTermIds);
    await _prefs.remove(SPKeys.quizHistory);
    await _prefs.setInt(SPKeys.streak, 0);
    await _prefs.remove(SPKeys.lastStudyDate);
  }

  Future<void> _saveToPrefs() async {
    await _prefs.setStringList(
      SPKeys.completedTermIds,
      state.completedTermIds.map((e) => e.toString()).toList(),
    );
    await _prefs.setStringList(
      SPKeys.reviewTermIds,
      state.reviewTermIds.map((e) => e.toString()).toList(),
    );
    await _prefs.setStringList(
      SPKeys.quizHistory,
      state.quizHistory.map((e) => json.encode(e.toJson())).toList(),
    );
    await _prefs.setInt(SPKeys.streak, state.streak);
    if (state.lastStudyDate != null) {
      await _prefs.setString(
        SPKeys.lastStudyDate,
        state.lastStudyDate!.toIso8601String(),
      );
    }
  }
}

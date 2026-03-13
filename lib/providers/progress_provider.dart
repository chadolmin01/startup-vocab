import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_result.dart';
import '../models/study_progress.dart';
import '../utils/constants.dart';
import '../utils/app_date_utils.dart';
import '../utils/logger.dart';
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

  static String _todayStr() => AppDateUtils.todayStr();

  void _loadFromPrefs() {
    final completedIds = _prefs.getStringList(SPKeys.completedTermIds) ?? [];
    final reviewIds = _prefs.getStringList(SPKeys.reviewTermIds) ?? [];
    final quizJson = _prefs.getStringList(SPKeys.quizHistory) ?? [];
    final streak = _prefs.getInt(SPKeys.streak) ?? 0;
    final lastStudyStr = _prefs.getString(SPKeys.lastStudyDate);
    final dailyGoal = _prefs.getInt(SPKeys.dailyGoal) ?? 5;
    final savedTodayDate = _prefs.getString(SPKeys.todayDate) ?? '';
    final savedTodayCount = _prefs.getInt(SPKeys.todayLearnedCount) ?? 0;
    final wrongIds = _prefs.getStringList(SPKeys.wrongTermIds) ?? [];

    // Load confidence map
    final confStr = _prefs.getString(SPKeys.termConfidence);
    final Map<int, int> confidence = {};
    if (confStr != null) {
      final decoded = json.decode(confStr) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        confidence[int.parse(entry.key)] = entry.value as int;
      }
    }

    final lastStudy =
        lastStudyStr != null ? DateTime.tryParse(lastStudyStr) : null;

    final quizHistory = quizJson
        .map((s) {
          try {
            return QuizResult.fromJson(json.decode(s) as Map<String, dynamic>);
          } catch (e) {
            AppLogger.error('ProgressNotifier:parseQuizHistory', e);
            return null;
          }
        })
        .whereType<QuizResult>()
        .toList();

    final validStreak = AppDateUtils.calculateStreak(lastStudy, streak);

    // Reset daily count if date changed
    final today = _todayStr();
    final todayCount = savedTodayDate == today ? savedTodayCount : 0;

    // Load next review dates
    final reviewDatesStr = _prefs.getString('next_review_dates');
    final Map<int, DateTime> nextReviewDates = {};
    if (reviewDatesStr != null) {
      final decoded = json.decode(reviewDatesStr) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        final dt = DateTime.tryParse(entry.value as String);
        if (dt != null) {
          nextReviewDates[int.parse(entry.key)] = dt;
        }
      }
    }

    state = StudyProgress(
      completedTermIds: completedIds.map((s) => int.tryParse(s)).whereType<int>().toSet(),
      reviewTermIds: reviewIds.map((s) => int.tryParse(s)).whereType<int>().toSet(),
      quizHistory: quizHistory,
      streak: validStreak,
      lastStudyDate: lastStudy,
      dailyGoal: dailyGoal,
      todayLearnedCount: todayCount,
      todayDate: today,
      termConfidence: confidence,
      nextReviewDates: nextReviewDates,
      wrongTermIds: wrongIds.map((s) => int.tryParse(s)).whereType<int>().toSet(),
    );

    if (validStreak != streak || savedTodayDate != today) {
      _saveToPrefs();
    }
  }

  Future<void> markCompleted(int termId) async {
    final newCompleted = {...state.completedTermIds, termId};
    final newReview = {...state.reviewTermIds}..remove(termId);
    final now = DateTime.now();
    final newStreak = _calculateNewStreak(now);
    final today = _todayStr();

    // Increment daily count only for newly completed terms
    final isNew = !state.completedTermIds.contains(termId);
    final newTodayCount = state.todayDate == today
        ? state.todayLearnedCount + (isNew ? 1 : 0)
        : (isNew ? 1 : 0);

    state = state.copyWith(
      completedTermIds: newCompleted,
      reviewTermIds: newReview,
      streak: newStreak,
      lastStudyDate: now,
      todayLearnedCount: newTodayCount,
      todayDate: today,
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

  Future<void> setDailyGoal(int goal) async {
    state = state.copyWith(dailyGoal: goal.clamp(AppConstants.minDailyGoal, AppConstants.maxDailyGoal));
    await _saveToPrefs();
  }

  Future<void> updateConfidence(int termId, bool correct) async {
    final newConf = Map<int, int>.from(state.termConfidence);
    final current = newConf[termId] ?? 0;
    if (correct) {
      newConf[termId] = (current + 1).clamp(0, AppConstants.maxConfidence);
    } else {
      newConf[termId] = (current - 1).clamp(0, AppConstants.maxConfidence);
    }

    final newWrong = Set<int>.from(state.wrongTermIds);
    if (!correct) {
      newWrong.add(termId);
    } else if (newConf[termId]! >= 2) {
      newWrong.remove(termId);
    }

    // Update SRS next review date
    final newReviewDates = Map<int, DateTime>.from(state.nextReviewDates);
    final interval = StudyProgress.srsInterval(newConf[termId]!);
    newReviewDates[termId] = DateTime.now().add(interval);

    state = state.copyWith(
      termConfidence: newConf,
      wrongTermIds: newWrong,
      nextReviewDates: newReviewDates,
    );
    await _saveToPrefs();
  }

  Future<void> clearWrongTerms() async {
    state = state.copyWith(wrongTermIds: {});
    await _saveToPrefs();
  }

  // Quick review: mark as "know" or "don't know"
  Future<void> reviewKnow(int termId) async {
    await updateConfidence(termId, true);
  }

  Future<void> reviewDontKnow(int termId) async {
    // Update confidence + add to review in one state change (single save)
    final newConf = Map<int, int>.from(state.termConfidence);
    final current = newConf[termId] ?? 0;
    newConf[termId] = (current - 1).clamp(0, AppConstants.maxConfidence);

    final newWrong = Set<int>.from(state.wrongTermIds)..add(termId);
    final newReview = {...state.reviewTermIds, termId};

    state = state.copyWith(
      termConfidence: newConf,
      wrongTermIds: newWrong,
      reviewTermIds: newReview,
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
    await _prefs.remove(SPKeys.termConfidence);
    await _prefs.remove(SPKeys.wrongTermIds);
    await _prefs.remove(SPKeys.todayLearnedCount);
    await _prefs.remove(SPKeys.todayDate);
    await _prefs.remove('next_review_dates');
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
    await _prefs.setInt(SPKeys.dailyGoal, state.dailyGoal);
    await _prefs.setInt(SPKeys.todayLearnedCount, state.todayLearnedCount);
    await _prefs.setString(SPKeys.todayDate, state.todayDate);
    await _prefs.setStringList(
      SPKeys.wrongTermIds,
      state.wrongTermIds.map((e) => e.toString()).toList(),
    );

    // Save confidence as JSON
    final confMap = state.termConfidence.map(
      (k, v) => MapEntry(k.toString(), v),
    );
    await _prefs.setString(SPKeys.termConfidence, json.encode(confMap));

    // Save next review dates
    final reviewDatesMap = state.nextReviewDates.map(
      (k, v) => MapEntry(k.toString(), v.toIso8601String()),
    );
    await _prefs.setString('next_review_dates', json.encode(reviewDatesMap));
  }
}

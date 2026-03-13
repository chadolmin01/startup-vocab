import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/term.dart';
import '../utils/constants.dart';

class WidgetService {
  static const _appGroupId = 'com.odysseyventures.startup_bite';
  static const _androidWidgetName = 'TermWidgetProvider';
  static const _termsCacheKey = 'cached_terms_json';

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    HomeWidget.registerInteractivityCallback(widgetInteractivityCallback);
  }

  /// Cache terms JSON into SharedPreferences so background callback can access it
  static Future<void> cacheTermsData(String termsJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_termsCacheKey, termsJson);
  }

  static Future<void> updateWidget({
    required Term term,
    required int dayNumber,
  }) async {
    await HomeWidget.saveWidgetData('term_ko', term.termKo);
    await HomeWidget.saveWidgetData('term_en', term.termEn);
    await HomeWidget.saveWidgetData('term_definition', term.definitionShort);
    await HomeWidget.saveWidgetData(
      'day_label',
      'DAY $dayNumber // ${term.category.toUpperCase()}',
    );
    await HomeWidget.saveWidgetData('current_term_id', term.id);
    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }
}

/// Top-level function for background interactivity callback.
/// Runs headless — no Flutter UI, no Riverpod. Direct SharedPreferences access.
@pragma('vm:entry-point')
Future<void> widgetInteractivityCallback(Uri? uri) async {
  if (uri == null) return;

  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();

  if (uri.host == 'markcomplete') {
    await _handleMarkComplete(prefs);
  } else if (uri.host == 'nextterm') {
    await _handleNextTerm(prefs);
  }
}

Future<void> _handleMarkComplete(SharedPreferences prefs) async {
  final currentTermId = await HomeWidget.getWidgetData<int>('current_term_id');
  if (currentTermId == null) return;

  final completedIds = prefs.getStringList(SPKeys.completedTermIds) ?? [];
  final idStr = currentTermId.toString();
  if (!completedIds.contains(idStr)) {
    completedIds.add(idStr);
    await prefs.setStringList(SPKeys.completedTermIds, completedIds);

    final today = _todayStr();
    final savedDate = prefs.getString(SPKeys.todayDate) ?? '';
    int count = savedDate == today
        ? (prefs.getInt(SPKeys.todayLearnedCount) ?? 0)
        : 0;
    count++;
    await prefs.setInt(SPKeys.todayLearnedCount, count);
    await prefs.setString(SPKeys.todayDate, today);

    await _updateStreak(prefs);
  }

  await _advanceWidgetTerm(prefs);
}

Future<void> _handleNextTerm(SharedPreferences prefs) async {
  await _advanceWidgetTerm(prefs);
}

Future<void> _advanceWidgetTerm(SharedPreferences prefs) async {
  final terms = _loadTermsFromCache(prefs);
  if (terms.isEmpty) return;

  final completedIds =
      (prefs.getStringList(SPKeys.completedTermIds) ?? []).toSet();
  final firstLaunchStr = prefs.getString(SPKeys.firstLaunchDate);
  final firstLaunch = firstLaunchStr != null
      ? (DateTime.tryParse(firstLaunchStr) ?? DateTime.now())
      : DateTime.now();

  final todayIndex = _getTodayTermIndex(firstLaunch);
  final currentWidgetIndex = prefs.getInt(SPKeys.widgetTermIndex) ?? 0;

  int nextIdx = -1;
  for (int i = 1; i <= terms.length; i++) {
    final checkIdx = (todayIndex + currentWidgetIndex + i) % terms.length;
    if (!completedIds.contains(terms[checkIdx]['id'].toString())) {
      nextIdx = (currentWidgetIndex + i) % terms.length;
      break;
    }
  }

  if (nextIdx == -1) {
    await HomeWidget.saveWidgetData('term_ko', '모두 완료!');
    await HomeWidget.saveWidgetData('term_en', 'ALL COMPLETE');
    await HomeWidget.saveWidgetData('term_definition', '축하합니다! 모든 용어를 학습했어요');
    await HomeWidget.saveWidgetData('day_label', 'STARTUP BITE');
  } else {
    final termIdx = (todayIndex + nextIdx) % terms.length;
    final term = terms[termIdx];
    final dayNumber = todayIndex + 1;

    await HomeWidget.saveWidgetData('term_ko', term['term_ko'] as String);
    await HomeWidget.saveWidgetData('term_en', term['term_en'] as String);
    await HomeWidget.saveWidgetData(
        'term_definition', term['definition_short'] as String);
    await HomeWidget.saveWidgetData(
      'day_label',
      'DAY $dayNumber // ${(term['category'] as String).toUpperCase()}',
    );
    await HomeWidget.saveWidgetData('current_term_id', term['id'] as int);
    await prefs.setInt(SPKeys.widgetTermIndex, nextIdx);
  }

  await HomeWidget.updateWidget(androidName: 'TermWidgetProvider');
}

/// Load terms from SharedPreferences cache (NOT rootBundle — unavailable in background)
List<Map<String, dynamic>> _loadTermsFromCache(SharedPreferences prefs) {
  try {
    final jsonString = prefs.getString(WidgetService._termsCacheKey);
    if (jsonString == null) return [];
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final termsList = jsonData['terms'] as List;
    return termsList.cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
}

int _getTodayTermIndex(DateTime firstLaunchDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = DateTime(
    firstLaunchDate.year,
    firstLaunchDate.month,
    firstLaunchDate.day,
  );
  final daysSinceStart = today.difference(start).inDays;
  return daysSinceStart % AppConstants.totalTerms;
}

String _todayStr() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

Future<void> _updateStreak(SharedPreferences prefs) async {
  final lastStudyStr = prefs.getString(SPKeys.lastStudyDate);
  final currentStreak = prefs.getInt(SPKeys.streak) ?? 0;
  final now = DateTime.now();

  int newStreak;
  if (lastStudyStr == null) {
    newStreak = 1;
  } else {
    final lastStudy = DateTime.tryParse(lastStudyStr);
    if (lastStudy == null) {
      newStreak = 1;
    } else {
      final lastDate =
          DateTime(lastStudy.year, lastStudy.month, lastStudy.day);
      final today = DateTime(now.year, now.month, now.day);
      final diff = today.difference(lastDate).inDays;

      if (diff == 0) {
        newStreak = currentStreak;
      } else if (diff == 1) {
        newStreak = currentStreak + 1;
      } else {
        newStreak = 1;
      }
    }
  }

  await prefs.setInt(SPKeys.streak, newStreak);
  await prefs.setString(SPKeys.lastStudyDate, now.toIso8601String());
}

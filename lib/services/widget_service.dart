import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/term.dart';
import '../utils/constants.dart';

class WidgetService {
  static const _appGroupId = 'com.odysseyventures.startup_bite';
  static const _androidWidgetName = 'TermWidgetProvider';

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    HomeWidget.registerInteractivityCallback(widgetInteractivityCallback);
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
  await prefs.reload(); // ensure fresh data

  if (uri.host == 'markcomplete') {
    await _handleMarkComplete(prefs);
  } else if (uri.host == 'nextterm') {
    await _handleNextTerm(prefs);
  }
}

/// Mark current widget term as completed, then advance to next
Future<void> _handleMarkComplete(SharedPreferences prefs) async {
  // current_term_id is stored in HomeWidgetPreferences, not regular prefs
  final currentTermId = await HomeWidget.getWidgetData<int>('current_term_id');
  if (currentTermId == null) return;

  // Add to completed set
  final completedIds =
      prefs.getStringList(SPKeys.completedTermIds) ?? [];
  final idStr = currentTermId.toString();
  if (!completedIds.contains(idStr)) {
    completedIds.add(idStr);
    await prefs.setStringList(SPKeys.completedTermIds, completedIds);

    // Increment daily count
    final today = _todayStr();
    final savedDate = prefs.getString(SPKeys.todayDate) ?? '';
    int count = savedDate == today
        ? (prefs.getInt(SPKeys.todayLearnedCount) ?? 0)
        : 0;
    count++;
    await prefs.setInt(SPKeys.todayLearnedCount, count);
    await prefs.setString(SPKeys.todayDate, today);

    // Update streak
    await _updateStreak(prefs);
  }

  // Advance to next term
  await _advanceWidgetTerm(prefs);
}

/// Move widget to next unlearned term
Future<void> _handleNextTerm(SharedPreferences prefs) async {
  await _advanceWidgetTerm(prefs);
}

/// Load terms from assets, find next unlearned, push to widget
Future<void> _advanceWidgetTerm(SharedPreferences prefs) async {
  final terms = await _loadTerms();
  if (terms.isEmpty) return;

  final completedIds =
      (prefs.getStringList(SPKeys.completedTermIds) ?? []).toSet();
  final firstLaunchStr = prefs.getString(SPKeys.firstLaunchDate);
  final firstLaunch = firstLaunchStr != null
      ? DateTime.parse(firstLaunchStr)
      : DateTime.now();

  final todayIndex = _getTodayTermIndex(firstLaunch);
  final currentWidgetIndex =
      prefs.getInt(SPKeys.widgetTermIndex) ?? 0;

  // Find next unlearned term starting from current+1
  int nextIdx = -1;
  for (int i = 1; i <= terms.length; i++) {
    final checkIdx = (todayIndex + currentWidgetIndex + i) % terms.length;
    if (!completedIds.contains(terms[checkIdx]['id'].toString())) {
      nextIdx = (currentWidgetIndex + i) % terms.length;
      break;
    }
  }

  if (nextIdx == -1) {
    // All complete
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

  await HomeWidget.updateWidget(
      androidName: 'TermWidgetProvider');
}

/// Load terms JSON directly (no Flutter engine rootBundle available in background)
Future<List<Map<String, dynamic>>> _loadTerms() async {
  try {
    final jsonString =
        await rootBundle.loadString('assets/data/terms.json');
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
  return daysSinceStart % 63;
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
    final lastStudy = DateTime.parse(lastStudyStr);
    final lastDate = DateTime(lastStudy.year, lastStudy.month, lastStudy.day);
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

  await prefs.setInt(SPKeys.streak, newStreak);
  await prefs.setString(SPKeys.lastStudyDate, now.toIso8601String());
}

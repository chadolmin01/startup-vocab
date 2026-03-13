import 'package:flutter_test/flutter_test.dart';
import 'package:startup_bite/utils/app_date_utils.dart';

void main() {
  group('AppDateUtils', () {
    group('getTodayTermIndex', () {
      test('returns 0 on first launch day', () {
        final today = DateTime.now();
        final firstLaunch = DateTime(today.year, today.month, today.day);
        expect(AppDateUtils.getTodayTermIndex(firstLaunch), 0);
      });

      test('returns day offset for subsequent days', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final fiveDaysAgo = today.subtract(const Duration(days: 5));
        expect(AppDateUtils.getTodayTermIndex(fiveDaysAgo), 5);
      });

      test('wraps around after 63 days', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final sixtyThreeDaysAgo = today.subtract(const Duration(days: 63));
        expect(AppDateUtils.getTodayTermIndex(sixtyThreeDaysAgo), 0);
      });

      test('wraps around at 64 days', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final sixtyFourDaysAgo = today.subtract(const Duration(days: 64));
        expect(AppDateUtils.getTodayTermIndex(sixtyFourDaysAgo), 1);
      });
    });

    group('getDayNumber', () {
      test('returns 1 on first day', () {
        final today = DateTime.now();
        final firstLaunch = DateTime(today.year, today.month, today.day);
        expect(AppDateUtils.getDayNumber(firstLaunch), 1);
      });
    });

    group('isToday', () {
      test('returns true for today', () {
        expect(AppDateUtils.isToday(DateTime.now()), isTrue);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(AppDateUtils.isToday(yesterday), isFalse);
      });
    });

    group('isYesterday', () {
      test('returns true for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(AppDateUtils.isYesterday(yesterday), isTrue);
      });

      test('returns false for today', () {
        expect(AppDateUtils.isYesterday(DateTime.now()), isFalse);
      });

      test('returns false for two days ago', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        expect(AppDateUtils.isYesterday(twoDaysAgo), isFalse);
      });
    });

    group('calculateStreak', () {
      test('returns 0 when lastStudyDate is null', () {
        expect(AppDateUtils.calculateStreak(null, 5), 0);
      });

      test('returns current streak if studied today', () {
        expect(AppDateUtils.calculateStreak(DateTime.now(), 5), 5);
      });

      test('returns current streak if studied yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(AppDateUtils.calculateStreak(yesterday, 5), 5);
      });

      test('resets to 0 if gap is 2+ days', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        expect(AppDateUtils.calculateStreak(threeDaysAgo, 5), 0);
      });
    });

    group('todayStr', () {
      test('returns formatted date string', () {
        final result = AppDateUtils.todayStr();
        expect(result, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      });
    });
  });
}

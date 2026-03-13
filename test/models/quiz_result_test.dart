import 'package:flutter_test/flutter_test.dart';
import 'package:startup_bite/models/quiz_result.dart';

void main() {
  group('QuizResult', () {
    test('toJson and fromJson round-trip', () {
      final original = QuizResult(
        date: DateTime(2026, 3, 13, 10, 30),
        correctCount: 7,
        totalCount: 10,
      );

      final json = original.toJson();
      final restored = QuizResult.fromJson(json);

      expect(restored.correctCount, 7);
      expect(restored.totalCount, 10);
      expect(restored.date.year, 2026);
      expect(restored.date.month, 3);
      expect(restored.date.day, 13);
    });

    test('accuracy calculation', () {
      final r = QuizResult(
        date: DateTime(2026, 1, 1),
        correctCount: 8,
        totalCount: 10,
      );
      expect(r.accuracy, closeTo(0.8, 0.001));
    });

    test('accuracy is 0 when totalCount is 0', () {
      final r = QuizResult(
        date: DateTime(2026, 1, 1),
        correctCount: 0,
        totalCount: 0,
      );
      expect(r.accuracy, 0.0);
    });
  });
}

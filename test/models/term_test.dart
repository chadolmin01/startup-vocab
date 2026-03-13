import 'package:flutter_test/flutter_test.dart';
import 'package:startup_bite/models/term.dart';

void main() {
  group('Term.fromJson', () {
    test('parses valid JSON correctly', () {
      final json = {
        'id': 1,
        'term_ko': '피벗',
        'term_en': 'Pivot',
        'category': 'Start',
        'week': 1,
        'definition_short': '사업 방향 전환',
        'definition_detail': '스타트업이 기존 전략을 변경하는 것',
        'example': '인스타그램은 Burbn에서 피벗했다.',
        'quiz_wrong_answers': ['투자 유치', '시장 조사', '팀 구성'],
      };

      final term = Term.fromJson(json);

      expect(term.id, 1);
      expect(term.termKo, '피벗');
      expect(term.termEn, 'Pivot');
      expect(term.category, 'Start');
      expect(term.week, 1);
      expect(term.definitionShort, '사업 방향 전환');
      expect(term.definitionDetail, '스타트업이 기존 전략을 변경하는 것');
      expect(term.example, '인스타그램은 Burbn에서 피벗했다.');
      expect(term.quizWrongAnswers, ['투자 유치', '시장 조사', '팀 구성']);
    });

    test('parses quiz_wrong_answers as list of strings', () {
      final json = {
        'id': 2,
        'term_ko': 'MVP',
        'term_en': 'Minimum Viable Product',
        'category': 'Build',
        'week': 2,
        'definition_short': '최소 기능 제품',
        'definition_detail': '핵심 기능만 갖춘 초기 제품',
        'example': 'MVP를 빠르게 출시하라.',
        'quiz_wrong_answers': [],
      };

      final term = Term.fromJson(json);
      expect(term.quizWrongAnswers, isEmpty);
    });

    test('throws on missing required field', () {
      final json = {
        'id': 1,
        'term_ko': '피벗',
        // missing term_en
      };

      expect(() => Term.fromJson(json), throwsA(isA<TypeError>()));
    });
  });
}

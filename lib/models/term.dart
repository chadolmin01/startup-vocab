class Term {
  final int id;
  final String termKo;
  final String termEn;
  final String category;
  final int week;
  final String definitionShort;
  final String definitionDetail;
  final String example;
  final List<String> quizWrongAnswers;

  const Term({
    required this.id,
    required this.termKo,
    required this.termEn,
    required this.category,
    required this.week,
    required this.definitionShort,
    required this.definitionDetail,
    required this.example,
    required this.quizWrongAnswers,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      id: json['id'] as int,
      termKo: json['term_ko'] as String,
      termEn: json['term_en'] as String,
      category: json['category'] as String,
      week: json['week'] as int,
      definitionShort: json['definition_short'] as String,
      definitionDetail: json['definition_detail'] as String,
      example: json['example'] as String,
      quizWrongAnswers: List<String>.from(json['quiz_wrong_answers'] as List),
    );
  }
}

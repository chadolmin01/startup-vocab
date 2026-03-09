import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/term.dart';
import '../models/quiz_result.dart';
import '../providers/terms_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/constants.dart';

enum QuizType { definitionToTerm, termToDefinition }

class QuizQuestion {
  final Term term;
  final QuizType type;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.term,
    required this.type,
    required this.options,
    required this.correctIndex,
  });

  String get questionText {
    if (type == QuizType.definitionToTerm) {
      return '다음 설명에 해당하는 용어는?';
    }
    return '"${term.termKo}"의 올바른 설명은?';
  }

  String get questionBody {
    if (type == QuizType.definitionToTerm) {
      return term.definitionShort;
    }
    return '';
  }
}

class QuizState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int correctCount;
  final int? selectedAnswer;
  final bool isFinished;

  const QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.correctCount = 0,
    this.selectedAnswer,
    this.isFinished = false,
  });

  QuizQuestion? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  int get totalQuestions => questions.length;

  double get progress =>
      totalQuestions > 0 ? (currentIndex) / totalQuestions : 0.0;

  QuizState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    int? correctCount,
    int? selectedAnswer,
    bool? isFinished,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      selectedAnswer: selectedAnswer,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

final quizProvider =
    StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(ref);
});

class QuizNotifier extends StateNotifier<QuizState> {
  final Ref _ref;
  final _random = Random();

  QuizNotifier(this._ref) : super(const QuizState());

  Future<void> generateQuiz() async {
    final termsAsync = _ref.read(termsProvider);
    final progress = _ref.read(progressProvider);

    final allTerms = termsAsync.valueOrNull;
    if (allTerms == null) return;

    final completedIds = progress.completedTermIds;
    if (completedIds.length < AppConstants.quizMinTerms) return;

    final studiedTerms =
        allTerms.where((t) => completedIds.contains(t.id)).toList();
    studiedTerms.shuffle(_random);

    final questionCount =
        min(AppConstants.quizQuestionCount, studiedTerms.length);
    final selectedTerms = studiedTerms.take(questionCount).toList();

    final questions = <QuizQuestion>[];
    for (final term in selectedTerms) {
      final type = _random.nextBool()
          ? QuizType.definitionToTerm
          : QuizType.termToDefinition;
      questions.add(_createQuestion(term, type));
    }

    state = QuizState(questions: questions);
  }

  QuizQuestion _createQuestion(Term term, QuizType type) {
    if (type == QuizType.definitionToTerm) {
      final correctAnswer = term.termKo;

      // For def→term type, use other term names as wrong answers
      final termsAsync = _ref.read(termsProvider);
      final allTerms = termsAsync.valueOrNull ?? [];
      final otherTerms = allTerms
          .where((t) => t.id != term.id)
          .map((t) => t.termKo)
          .toList();
      otherTerms.shuffle(_random);
      final wrongTermNames =
          otherTerms.take(3).toList();

      final options = [correctAnswer, ...wrongTermNames]..shuffle(_random);
      final correctIndex = options.indexOf(correctAnswer);
      return QuizQuestion(
        term: term,
        type: type,
        options: options,
        correctIndex: correctIndex,
      );
    } else {
      final correctAnswer = term.definitionShort;
      final wrongAnswers = List<String>.from(term.quizWrongAnswers);
      final options = [correctAnswer, ...wrongAnswers]..shuffle(_random);
      final correctIndex = options.indexOf(correctAnswer);
      return QuizQuestion(
        term: term,
        type: type,
        options: options,
        correctIndex: correctIndex,
      );
    }
  }

  void submitAnswer(int selectedIndex) {
    if (state.selectedAnswer != null) return;
    final isCorrect =
        selectedIndex == state.currentQuestion?.correctIndex;
    state = state.copyWith(
      selectedAnswer: selectedIndex,
      correctCount:
          isCorrect ? state.correctCount + 1 : state.correctCount,
    );
  }

  void nextQuestion() {
    if (state.currentIndex + 1 >= state.totalQuestions) {
      state = state.copyWith(isFinished: true);
      _saveResult();
    } else {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
      );
    }
  }

  void _saveResult() {
    final result = QuizResult(
      date: DateTime.now(),
      correctCount: state.correctCount,
      totalCount: state.totalQuestions,
    );
    _ref.read(progressProvider.notifier).addQuizResult(result);
  }

  void reset() {
    state = const QuizState();
  }
}

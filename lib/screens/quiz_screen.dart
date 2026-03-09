import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/quiz_provider.dart';
import '../providers/progress_provider.dart';
import '../models/study_progress.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../widgets/quiz_option_tile.dart';
import '../widgets/progress_bar.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final quizState = ref.watch(quizProvider);
    final canTakeQuiz =
        progress.completedTermIds.length >= AppConstants.quizMinTerms;

    if (!canTakeQuiz) {
      return _buildNotEnoughTerms(progress);
    }

    if (!_started) {
      return _buildStartScreen(progress);
    }

    if (quizState.isFinished) {
      return _buildResultScreen(quizState);
    }

    return _buildQuizQuestion(quizState);
  }

  Widget _buildNotEnoughTerms(StudyProgress progress) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('QUIZ', style: AppTextStyles.labelColored(AppColors.accent)),
              const SizedBox(height: Spacing.xs),
              const Text('퀴즈 모드', style: AppTextStyles.h2),
              const SizedBox(height: Spacing.lg),
              Expanded(
                child: FrameContainer(
                  label: 'STATUS // LOCKED',
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline, size: 32, color: AppColors.textMuted),
                        const SizedBox(height: Spacing.lg),
                        Text(
                          '용어를 ${AppConstants.quizMinTerms}개 이상 학습하면\n퀴즈에 도전할 수 있어요',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary,
                        ),
                        const SizedBox(height: Spacing.xl),
                        Text(
                          '${progress.completedTermIds.length} / ${AppConstants.quizMinTerms}',
                          style: AppTextStyles.stat.copyWith(color: AppColors.accent),
                        ),
                        const SizedBox(height: Spacing.sm),
                        ProgressBar(
                          percent: progress.completedTermIds.length / AppConstants.quizMinTerms,
                          progressColor: AppColors.accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartScreen(StudyProgress progress) {
    final hasWrongTerms = progress.wrongTermIds.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('QUIZ', style: AppTextStyles.labelColored(AppColors.accent)),
              const SizedBox(height: Spacing.xs),
              const Text('퀴즈 모드', style: AppTextStyles.h2),
              const SizedBox(height: Spacing.lg),
              Expanded(
                child: FrameContainer(
                  label: 'STATUS // READY',
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded, size: 36, color: AppColors.accent),
                        const SizedBox(height: Spacing.lg),
                        Text(
                          '학습한 ${progress.completedTermIds.length}개 용어 중\n최대 ${AppConstants.quizQuestionCount}문제가 출제됩니다',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary,
                        ),
                        if (hasWrongTerms) ...[
                          const SizedBox(height: Spacing.md),
                          Text(
                            '오답 용어 ${progress.wrongTermIds.length}개',
                            style: AppTextStyles.labelColored(AppColors.error),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(quizProvider.notifier).generateQuiz();
                    setState(() => _started = true);
                  },
                  child: const Text('퀴즈 시작'),
                ),
              ),
              if (hasWrongTerms) ...[
                const SizedBox(height: Spacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(quizProvider.notifier).generateQuiz(
                            mode: QuizMode.wrongOnly,
                          );
                      setState(() => _started = true);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('오답 노트 퀴즈'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizQuestion(QuizState quizState) {
    final question = quizState.currentQuestion;
    if (question == null) return const SizedBox();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Q${quizState.currentIndex + 1} / ${quizState.totalQuestions}',
                    style: AppTextStyles.labelBright,
                  ),
                  Text(
                    '${quizState.correctCount} CORRECT',
                    style: AppTextStyles.labelColored(AppColors.success),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              ProgressBar(
                percent: (quizState.currentIndex + 1) /
                    quizState.totalQuestions,
                progressColor: AppColors.accent,
              ),
              const SizedBox(height: Spacing.lg),
              // Question
              FrameContainer(
                label: question.questionBody.isEmpty
                    ? 'QUESTION'
                    : 'QUESTION // ${question.term.termKo}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(question.questionText, style: AppTextStyles.h3),
                    if (question.questionBody.isNotEmpty) ...[
                      const SizedBox(height: Spacing.md),
                      Text(question.questionBody, style: AppTextStyles.bodySecondary),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),
              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    return QuizOptionTile(
                      text: question.options[index],
                      index: index,
                      selectedAnswer: quizState.selectedAnswer,
                      correctIndex: question.correctIndex,
                      onTap: () {
                        ref.read(quizProvider.notifier).submitAnswer(index);
                      },
                    );
                  },
                ),
              ),
              if (quizState.selectedAnswer != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(quizProvider.notifier).nextQuestion();
                    },
                    child: Text(
                      quizState.currentIndex + 1 >= quizState.totalQuestions
                          ? '결과 보기'
                          : '다음 문제',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(QuizState quizState) {
    final accuracy = quizState.totalQuestions > 0
        ? quizState.correctCount / quizState.totalQuestions
        : 0.0;
    final resultColor = accuracy >= 0.7 ? AppColors.success : AppColors.warning;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('QUIZ', style: AppTextStyles.labelColored(AppColors.accent)),
              const SizedBox(height: Spacing.xs),
              const Text('퀴즈 결과', style: AppTextStyles.h2),
              const SizedBox(height: Spacing.lg),
              Expanded(
                child: FrameContainer(
                  label: 'RESULT // ${(accuracy * 100).toInt()}%',
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularPercentIndicator(
                          radius: 56,
                          lineWidth: 6,
                          percent: accuracy,
                          center: Text(
                            '${(accuracy * 100).toInt()}%',
                            style: AppTextStyles.stat.copyWith(color: resultColor),
                          ),
                          progressColor: resultColor,
                          backgroundColor: AppColors.cardBorder,
                          circularStrokeCap: CircularStrokeCap.round,
                          animation: true,
                        ),
                        const SizedBox(height: Spacing.lg),
                        Text(
                          '${quizState.correctCount} / ${quizState.totalQuestions} 정답',
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(quizProvider.notifier).reset();
                    setState(() => _started = false);
                  },
                  child: const Text('다시 도전'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

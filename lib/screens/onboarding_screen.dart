import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../widgets/star_field.dart';
import '../widgets/glass_container.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _steps = [
    _OnboardingStep(
      icon: Icons.touch_app_rounded,
      title: '카드를 탭해서 뒤집기',
      description: '앞면에서 용어를 확인하고\n탭하면 뜻과 예시를 볼 수 있어요',
      label: 'STEP 01 // FLIP',
    ),
    _OnboardingStep(
      icon: Icons.swipe_rounded,
      title: '이해 / 복습 선택',
      description: '이해했으면 완료 처리하고\n아직이면 복습 목록에 추가해요',
      label: 'STEP 02 // REVIEW',
    ),
    _OnboardingStep(
      icon: Icons.quiz_rounded,
      title: '퀴즈에 도전하기',
      description: '4개 이상 학습하면 퀴즈가 열려요\nSRS 기반으로 약한 부분을 집중 출제해요',
      label: 'STEP 03 // QUIZ',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarField(
        starCount: 40,
        showShootingStars: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.screenPadding),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ONBOARDING',
                      style: AppTextStyles.labelColored(AppColors.accent),
                    ),
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        'SKIP',
                        style: AppTextStyles.labelColored(AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return FrameContainer(
                        label: step.label,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(step.icon, size: 48, color: AppColors.accent),
                              const SizedBox(height: Spacing.xl),
                              Text(
                                step.title,
                                style: AppTextStyles.h2,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: Spacing.lg),
                              Text(
                                step.description,
                                style: AppTextStyles.bodySecondary,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) {
                    return Container(
                      width: _currentPage == i ? 16 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? AppColors.accent
                            : AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: Spacing.lg),
                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _currentPage == _steps.length - 1
                        ? _finish
                        : () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                    child: Text(
                      _currentPage == _steps.length - 1 ? '시작하기' : '다음',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final IconData icon;
  final String title;
  final String description;
  final String label;

  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.label,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/progress_provider.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/review_screen.dart';
import 'screens/dictionary_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/nickname_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

class StartupBiteApp extends ConsumerWidget {
  const StartupBiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: '스타트업 한 입',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routes: {
        '/main': (_) => const MainShell(),
      },
      home: const _SplashGate(),
    );
  }
}

/// Shows splash → then routes to nickname or main
class _SplashGate extends ConsumerStatefulWidget {
  const _SplashGate();

  @override
  ConsumerState<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<_SplashGate> {
  bool _splashDone = false;
  bool _showOnboarding = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return SplashScreen(
        onComplete: () {
          if (mounted) setState(() => _splashDone = true);
        },
      );
    }

    final prefs = ref.watch(sharedPreferencesProvider);
    final hasNickname = prefs.getString(SPKeys.nickname) != null;

    if (!hasNickname) {
      return const NicknameScreen();
    }

    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    if (!onboardingDone && !_showOnboarding) {
      // Show onboarding for users who haven't seen it
      return OnboardingScreen(
        onComplete: () {
          if (mounted) setState(() => _showOnboarding = true);
        },
      );
    }

    return const MainShell();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    QuizScreen(),
    ReviewScreen(),
    DictionaryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: '학습',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_rounded),
            label: '퀴즈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.replay_rounded),
            label: '복습',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: '사전',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: '마이',
          ),
        ],
      ),
    );
  }
}

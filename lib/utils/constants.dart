import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ─── Design Tokens ───────────────────────────────────────────

class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double screenPadding = 20;
}

class AppColors {
  static const background = Color(0xFF000000);
  static const cardBackground = Color(0xFF0A0A0A);
  static const cardBorder = Color(0xFF1A1A1A);
  static const surface = Color(0xFF111111);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF999999);
  static const textMuted = Color(0xFF666666);

  static const accent = Color(0xFF60A5FA);
  static const success = Color(0xFF34D399);
  static const error = Color(0xFFF87171);
  static const warning = Color(0xFFFBBF24);

  static const Map<String, Color> categoryColors = {
    'Start': Color(0xFF60A5FA),
    'Build': Color(0xFF34D399),
    'Scale': Color(0xFFA78BFA),
    'Invest': Color(0xFFFBBF24),
    'Final': Color(0xFFF87171),
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? accent;
  }
}

// ─── Typography ──────────────────────────────────────────────

class AppTextStyles {
  static const h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const h3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const bodySecondary = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static const small = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const label = TextStyle(
    fontFamily: 'monospace',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.0,
    color: AppColors.textMuted,
  );

  static const labelBright = TextStyle(
    fontFamily: 'monospace',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.0,
    color: AppColors.textSecondary,
  );

  static TextStyle labelColored(Color color) => TextStyle(
    fontFamily: 'monospace',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.0,
    color: color,
  );

  static const mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    color: AppColors.textMuted,
    letterSpacing: 1,
  );

  static const stat = TextStyle(
    fontFamily: 'monospace',
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );
}

// ─── Shared Preferences Keys ─────────────────────────────────

class SPKeys {
  static const String nickname = 'nickname';
  static const String deviceId = 'device_id';
  static const String completedTermIds = 'completed_term_ids';
  static const String reviewTermIds = 'review_term_ids';
  static const String quizHistory = 'quiz_history';
  static const String streak = 'streak';
  static const String lastStudyDate = 'last_study_date';
  static const String firstLaunchDate = 'first_launch_date';
  static const String notificationEnabled = 'notification_enabled';
  static const String totalQuizScore = 'total_quiz_score';
  static const String totalQuizCount = 'total_quiz_count';
  static const String dailyGoal = 'daily_goal';
  static const String todayLearnedCount = 'today_learned_count';
  static const String todayDate = 'today_date';
  static const String termConfidence = 'term_confidence';
  static const String wrongTermIds = 'wrong_term_ids';
  static const String widgetTermIndex = 'widget_term_index';
}

// ─── App Constants ───────────────────────────────────────────

class AppConstants {
  static const int totalTerms = 63;
  static const int termsPerWeek = 7;
  static const int totalWeeks = 9;
  static const int quizMinTerms = 4;
  static const int quizQuestionCount = 10;
  static const int leaderboardTopN = 20;
  static const double cardBorderRadius = 4.0;
  static const Duration flipDuration = Duration(milliseconds: 300);

  // Quiz / SRS constants
  static const int maxConfidence = 3;
  static const int minDailyGoal = 1;
  static const int maxDailyGoal = 20;
  static const int quizWrongAnswerCount = 3;

  // Supabase — loaded from .env
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL';
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY';
}

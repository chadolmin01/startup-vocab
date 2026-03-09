import 'package:flutter/material.dart';

class AppColors {
  // Cosmic dark palette
  static const background = Color(0xFF0A0A0F);
  static const cardBackground = Color(0xFF12121A);
  static const cardBorder = Color(0xFF1E1E2E);
  static const surface = Color(0xFF16161F);
  static const textPrimary = Color(0xFFF0F0F0);
  static const textSecondary = Color(0xFF6B6B80);
  static const textMuted = Color(0xFF3A3A4A);

  // Accent - cosmic blue-violet
  static const accent = Color(0xFF7B68EE);
  static const accentDim = Color(0xFF4A3CB0);

  // Status
  static const success = Color(0xFF34D399);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFFBBF24);

  // Category colors - slightly muted for dark theme
  static const Map<String, Color> categoryColors = {
    'Start': Color(0xFF8B7CF6),  // violet
    'Build': Color(0xFF3B82F6),  // blue
    'Scale': Color(0xFF34D399),  // emerald
    'Invest': Color(0xFFFBBF24), // amber
    'Final': Color(0xFFF97316),  // orange
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? accent;
  }
}

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
}

class AppConstants {
  static const int totalTerms = 63;
  static const int termsPerWeek = 7;
  static const int totalWeeks = 9;
  static const int quizMinTerms = 4;
  static const int quizQuestionCount = 10;
  static const int leaderboardTopN = 20;
  static const double cardBorderRadius = 4.0; // sharp corners
  static const Duration flipDuration = Duration(milliseconds: 300);

  static const String supabaseUrl = 'https://kqevvmzxaatpjzfyecul.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtxZXZ2bXp4YWF0cGp6ZnllY3VsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwMzg5NTAsImV4cCI6MjA4ODYxNDk1MH0.DLRNGQDC3t3pzh-QyuvINQTj5q6Sk9ZJL5xBsSejf0Y';
}

/// Technical label text style - mono, uppercase, tracking
class AppTextStyles {
  static const label = TextStyle(
    fontFamily: 'monospace',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  static const labelBright = TextStyle(
    fontFamily: 'monospace',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle labelColored(Color color) => TextStyle(
    fontFamily: 'monospace',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: color,
  );
}

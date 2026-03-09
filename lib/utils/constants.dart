import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF1A1A2E);
  static const cardBackground = Color(0xFF16213E);
  static const cardBorder = Color(0xFF1F3460);
  static const surface = Color(0xFF0F3460);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0C0);
  static const accent = Color(0xFF6C5CE7);
  static const success = Color(0xFF00B894);
  static const error = Color(0xFFE17055);
  static const warning = Color(0xFFFDCB6E);

  static const Map<String, Color> categoryColors = {
    'Start': Color(0xFF6C5CE7),
    'Build': Color(0xFF0984E3),
    'Scale': Color(0xFF00B894),
    'Invest': Color(0xFFFDCB6E),
    'Final': Color(0xFFE17055),
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
  static const double cardBorderRadius = 20.0;
  static const Duration flipDuration = Duration(milliseconds: 300);

  static const String supabaseUrl = 'https://kqevvmzxaatpjzfyecul.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtxZXZ2bXp4YWF0cGp6ZnllY3VsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwMzg5NTAsImV4cCI6MjA4ODYxNDk1MH0.DLRNGQDC3t3pzh-QyuvINQTj5q6Sk9ZJL5xBsSejf0Y';
}

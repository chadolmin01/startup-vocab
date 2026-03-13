import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/progress_provider.dart';
import 'providers/terms_provider.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';
import 'services/widget_service.dart';
import 'utils/constants.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Initialize Supabase (graceful failure)
  if (AppConstants.supabaseUrl != 'YOUR_SUPABASE_URL') {
    await SupabaseService.initialize();
  }

  if (!kIsWeb) {
    // Initialize home widget + cache terms for background callback
    try {
      await WidgetService.initialize();
      final termsJson =
          await rootBundle.loadString('assets/data/terms.json');
      await WidgetService.cacheTermsData(termsJson);
    } catch (_) {}

    // Initialize notifications
    await NotificationService.initialize();
    final notifEnabled = prefs.getBool(SPKeys.notificationEnabled) ?? true;
    if (notifEnabled) {
      await NotificationService.scheduleDailyReminder();
    }
  }

  // Get or set first launch date
  final firstLaunchStr = prefs.getString(SPKeys.firstLaunchDate);
  final firstLaunchDate = firstLaunchStr != null
      ? (DateTime.tryParse(firstLaunchStr) ?? DateTime.now())
      : DateTime.now();
  if (firstLaunchStr == null) {
    await prefs.setString(
        SPKeys.firstLaunchDate, firstLaunchDate.toIso8601String());
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        firstLaunchDateProvider.overrideWithValue(firstLaunchDate),
      ],
      child: const StartupBiteApp(),
    ),
  );
}

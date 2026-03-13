import 'package:flutter/foundation.dart';

class AppLogger {
  static void error(String context, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $context: $error');
      if (stackTrace != null) {
        debugPrint('$stackTrace');
      }
    }
  }

  static void warn(String context, String message) {
    if (kDebugMode) {
      debugPrint('[WARN] $context: $message');
    }
  }

  static void info(String context, String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $context: $message');
    }
  }
}

import 'dart:async';
import 'dart:ui';
import 'package:wakey/features/alarm/alarm_storage.dart';
import 'package:wakey/features/alarm/alarm_notifications.dart';

class AlarmBackgroundService {
  /// Initialize background task
  static Future<void> init() async {
    // Register callback dispatcher
    CallbackHandle? callback = PluginUtilities.getCallbackHandle(_backgroundTask);
    if (callback != null) {
      // Handle background tasks
    }
  }

  /// Background task handler
  static Future<void> _backgroundTask() async {
    try {
      // Initialize services
      await AlarmStorage.init();
      await AlarmNotifications.init();
      
      // Reschedule active alarms
      await AlarmStorage.rescheduleAllAlarms();
      
      // Clean up expired alarms
      await AlarmStorage.cleanupExpiredAlarms();
      
    } catch (e) {
      // Log error but don't crash
    }
  }
}

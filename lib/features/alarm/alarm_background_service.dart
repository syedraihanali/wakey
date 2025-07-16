import 'dart:async';
import 'dart:ui';
import 'package:wakey/features/alarm/alarm_storage.dart';
import 'package:wakey/features/alarm/alarm_notification_service.dart';

class AlarmBackgroundService {
  /// Initialize background task
  static Future<void> init() async {
    // Register callback dispatcher
    CallbackHandle? callback = PluginUtilities.getCallbackHandle(_backgroundTask);
    if (callback != null) {
      // Handle background tasks
      print('Background task callback registered');
    }
  }

  /// Background task handler
  static Future<void> _backgroundTask() async {
    print('Background task started');
    
    try {
      // Initialize services
      await AlarmStorage.init();
      await AlarmNotificationService.init();
      
      // Reschedule active alarms
      await AlarmStorage.rescheduleAllAlarms();
      
      // Clean up expired alarms
      await AlarmStorage.cleanupExpiredAlarms();
      
      print('Background task completed successfully');
    } catch (e) {
      print('Background task error: $e');
    }
  }
  
  /// Check if alarms are properly scheduled
  static Future<void> debugScheduledAlarms() async {
    final pending = await AlarmNotificationService.getPendingNotifications();
    print('Pending notifications: ${pending.length}');
    
    for (final notification in pending) {
      print('  ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
    }
    
    final alarms = AlarmStorage.getAllAlarms();
    print('Stored alarms: ${alarms.length}');
    
    for (final alarm in alarms) {
      print('  ID: ${alarm.id}, Active: ${alarm.isActive}, Time: ${alarm.dateTime}');
    }
  }
}

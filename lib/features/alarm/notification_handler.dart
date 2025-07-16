import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakey/features/alarm/alarm_notifications.dart';
import 'package:wakey/features/alarm/alarm_storage.dart';
import 'package:wakey/features/alarm/alarm.dart';

class NotificationHandler {
  /// Initialize notification handler
  static Future<void> init() async {
    await AlarmNotifications.init();
  }

  /// Handle alarm creation notification
  static Future<void> handleAlarmCreated(Alarm alarm) async {
    await AlarmNotifications.scheduleAlarm(alarm);
    
    // Show success notification
    Get.snackbar(
      'Alarm Set 🔔',
      'Your alarm has been set for ${alarm.formattedTime}',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Handle alarm deletion notification
  static Future<void> handleAlarmDeleted(String alarmId) async {
    await AlarmNotifications.cancelAlarm(alarmId);
    
    Get.snackbar(
      'Alarm Deleted 🗑️',
      'Your alarm has been deleted',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Handle alarm toggle notification
  static Future<void> handleAlarmToggled(Alarm alarm) async {
    if (alarm.isActive) {
      await AlarmNotifications.scheduleAlarm(alarm);
      Get.snackbar(
        'Alarm Enabled ✅',
        'Your alarm is now active',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      await AlarmNotifications.cancelAlarm(alarm.id);
      Get.snackbar(
        'Alarm Disabled ❌',
        'Your alarm has been turned off',
        backgroundColor: Colors.grey,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Handle permission request result
  static Future<void> handlePermissionResult(bool granted) async {
    if (granted) {
      Get.snackbar(
        'Permissions Granted ✅',
        'Notifications are now enabled for alarms',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Permissions Required ⚠️',
        'Please enable notifications in settings for alarms to work',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () => AlarmNotifications.requestPermissions(),
          child: const Text('Enable', style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  /// Show test notification
  static Future<void> showTestNotification() async {
    await AlarmNotifications.showTestNotification();
  }

  /// Reschedule all alarms
  static Future<void> rescheduleAllAlarms() async {
    final alarms = AlarmStorage.getAllAlarms();
    await AlarmNotifications.rescheduleAllAlarms(alarms);
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    return await AlarmNotifications.areNotificationsEnabled();
  }

  /// Request permissions
  static Future<bool> requestPermissions() async {
    return await AlarmNotifications.requestPermissions();
  }
}

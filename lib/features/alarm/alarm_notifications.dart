import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:wakey/features/alarm/alarm.dart';
import 'package:wakey/features/alarm/alarm_storage.dart';

class AlarmNotifications {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static const String _channelId = 'alarm_channel';
  static const String _channelName = 'Alarm Notifications';
  static const String _reminderChannelId = 'reminder_channel';
  static const String _reminderChannelName = 'Alarm Reminders';

  /// Initialize the notification service
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Android initialization
      const AndroidInitializationSettings androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings iOSInitSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: true,
      );

      // Combined initialization
      const InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iOSInitSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      // Create notification channels for Android
      await _createNotificationChannels();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing AlarmNotifications: $e');
      rethrow;
    }
  }

  /// Create notification channels for Android
  static Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Main alarm channel
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: 'Critical alarm notifications that wake you up',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            ledColor: Colors.red,
            showBadge: true,
          ),
        );

        // Reminder channel
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _reminderChannelId,
            _reminderChannelName,
            description: 'Reminder notifications for upcoming alarms',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );
      }
    }
  }

  /// Handle notification tap responses
  static void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    final actionId = response.actionId;

    if (payload != null) {
      switch (actionId) {
        case 'dismiss':
          _handleDismissAction(payload);
          break;
        case 'snooze_5':
          _handleSnoozeAction(payload, 5);
          break;
        case 'snooze_10':
          _handleSnoozeAction(payload, 10);
          break;
        case 'snooze_15':
          _handleSnoozeAction(payload, 15);
          break;
        default:
          _handleDefaultTap(payload);
          break;
      }
    }
  }

  /// Handle dismiss action
  static void _handleDismissAction(String alarmId) {
    try {
      cancelAlarm(alarmId);
      // Mark alarm as dismissed in storage
      final alarm = AlarmStorage.getAlarmById(alarmId);
      if (alarm != null) {
        alarm.isActive = false;
        AlarmStorage.updateAlarm(alarm);
      }
    } catch (e) {
      debugPrint('Error handling dismiss action: $e');
    }
  }

  /// Handle snooze action
  static void _handleSnoozeAction(String alarmId, int minutes) {
    try {
      final alarm = AlarmStorage.getAlarmById(alarmId);
      if (alarm != null) {
        // Create a new alarm for snooze
        final snoozeAlarm = alarm.copyWith(
          id: '${alarmId}_snooze_${DateTime.now().millisecondsSinceEpoch}',
          dateTime: DateTime.now().add(Duration(minutes: minutes)),
        );
        
        // Save and schedule the snooze alarm
        AlarmStorage.saveAlarm(snoozeAlarm);
        scheduleAlarm(snoozeAlarm);
        
        // Show snooze confirmation
        showSnoozeConfirmation(minutes);
      }
    } catch (e) {
      debugPrint('Error handling snooze action: $e');
    }
  }

  /// Handle default notification tap
  static void _handleDefaultTap(String alarmId) {
    // Open the app when notification is tapped
    debugPrint('Alarm notification tapped: $alarmId');
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    bool permissionGranted = false;

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        permissionGranted = await androidPlugin.requestNotificationsPermission() ?? false;
        await androidPlugin.requestExactAlarmsPermission();
      }
    } else if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iOSPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iOSPlugin != null) {
        final bool? iosPermission = await iOSPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true,
        );
        permissionGranted = iosPermission ?? false;
      }
    }

    return permissionGranted;
  }

  /// Schedule an alarm notification
  static Future<void> scheduleAlarm(Alarm alarm) async {
    if (!alarm.dateTime.isAfter(DateTime.now())) {
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      alarm.id.hashCode,
      'Wakey Alarm 🔔',
      _getAlarmMessage(alarm),
      tz.TZDateTime.from(alarm.dateTime, tz.local),
      _getAlarmNotificationDetails(alarm),
      payload: alarm.id,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // Schedule reminder notification (5 minutes before)
    await _scheduleReminderNotification(alarm);
  }

  /// Schedule a reminder notification before the alarm
  static Future<void> _scheduleReminderNotification(Alarm alarm) async {
    final reminderTime = alarm.dateTime.subtract(const Duration(minutes: 5));
    
    if (reminderTime.isAfter(DateTime.now())) {
      await _notificationsPlugin.zonedSchedule(
        '${alarm.id}_reminder'.hashCode,
        'Upcoming Alarm ⏰',
        'Your alarm "${alarm.label ?? 'Alarm'}" will ring in 5 minutes',
        tz.TZDateTime.from(reminderTime, tz.local),
        _getReminderNotificationDetails(),
        payload: '${alarm.id}_reminder',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  /// Get alarm notification details
  static NotificationDetails _getAlarmNotificationDetails(Alarm alarm) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Critical alarm notifications',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('alarm_sound'),
        ticker: 'Your alarm is ringing!',
        visibility: NotificationVisibility.public,
        autoCancel: false,
        ongoing: true,
        timeoutAfter: 300000, // 5 minutes
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'dismiss',
            'Dismiss',
            cancelNotification: true,
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'snooze_5',
            'Snooze 5m',
            cancelNotification: true,
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'snooze_10',
            'Snooze 10m',
            cancelNotification: true,
            showsUserInterface: true,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'alarm_category',
        threadIdentifier: 'alarm_thread',
        subtitle: 'Time to wake up!',
        interruptionLevel: InterruptionLevel.critical,
        sound: 'alarm_sound.wav',
        badgeNumber: 1,
      ),
    );
  }

  /// Get reminder notification details
  static NotificationDetails _getReminderNotificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _reminderChannelId,
        _reminderChannelName,
        channelDescription: 'Reminder notifications for upcoming alarms',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        showWhen: true,
        autoCancel: true,
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'dismiss',
            'OK',
            cancelNotification: true,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'reminder_category',
        threadIdentifier: 'reminder_thread',
        interruptionLevel: InterruptionLevel.active,
        sound: 'default',
      ),
    );
  }

  /// Get personalized alarm message
  static String _getAlarmMessage(Alarm alarm) {
    final hour = alarm.dateTime.hour;
    String timeGreeting;

    if (hour >= 5 && hour < 12) {
      timeGreeting = 'Good morning!';
    } else if (hour >= 12 && hour < 17) {
      timeGreeting = 'Good afternoon!';
    } else if (hour >= 17 && hour < 21) {
      timeGreeting = 'Good evening!';
    } else {
      timeGreeting = 'Time to wake up!';
    }

    String locationMessage = '';
    if (alarm.locationName.isNotEmpty) {
      locationMessage = ' in ${alarm.locationName}';
    }

    return '$timeGreeting Your alarm is ringing$locationMessage.';
  }

  /// Show snooze confirmation notification
  static Future<void> showSnoozeConfirmation(int minutes) async {
    await _notificationsPlugin.show(
      999999, // Unique ID for snooze confirmation
      'Alarm Snoozed ⏰',
      'Your alarm has been snoozed for $minutes minutes',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannelId,
          _reminderChannelName,
          importance: Importance.low,
          priority: Priority.low,
          autoCancel: true,
          timeoutAfter: 10000, // Auto dismiss after 10 seconds
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
          interruptionLevel: InterruptionLevel.passive,
        ),
      ),
    );
  }

  /// Cancel an alarm notification
  static Future<void> cancelAlarm(String alarmId) async {
    await _notificationsPlugin.cancel(alarmId.hashCode);
    // Also cancel reminder notification
    await _notificationsPlugin.cancel('${alarmId}_reminder'.hashCode);
  }

  /// Cancel all notifications
  static Future<void> cancelAllAlarms() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Reschedule all active alarms
  static Future<void> rescheduleAllAlarms(List<Alarm> alarms) async {
    await cancelAllAlarms();

    for (final alarm in alarms) {
      if (alarm.isActive && alarm.dateTime.isAfter(DateTime.now())) {
        await scheduleAlarm(alarm);
      }
    }
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        return await androidPlugin.areNotificationsEnabled() ?? false;
      }
    } else if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iOSPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iOSPlugin != null) {
        final permissions = await iOSPlugin.checkPermissions();
        return permissions?.isEnabled ?? false;
      }
    }

    return false;
  }

  /// Show a test notification
  static Future<void> showTestNotification() async {
    await _notificationsPlugin.show(
      888888,
      'Test Notification 🔔',
      'This is a test notification to verify the alarm system works correctly.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'dismiss',
              'Dismiss',
              cancelNotification: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
    );
  }
}
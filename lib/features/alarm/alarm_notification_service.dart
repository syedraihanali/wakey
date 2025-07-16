import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:wakey/features/alarm/alarm.dart';

class AlarmNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize the notification service
  static Future<void> init() async {
    if (_isInitialized) return;

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

    _isInitialized = true;
  }

  /// Handle notification tap
  static void _onNotificationResponse(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    print('Action ID: ${response.actionId}');
    
    if (response.actionId == 'dismiss') {
      // Handle dismiss action
      print('Alarm dismissed');
    } else if (response.actionId == 'snooze') {
      // Handle snooze action - could implement snooze logic here
      print('Alarm snoozed');
    }
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    bool permissionGranted = false;
    
    // Handle Android permissions
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Request basic notification permission
      permissionGranted = await androidPlugin.requestNotificationsPermission() ?? false;
      
      // Request exact alarm permission for Android 12+
      final bool? exactAlarmPermission = await androidPlugin.requestExactAlarmsPermission();
      print('Exact alarm permission: $exactAlarmPermission');
    }

    // Handle iOS permissions
    final IOSFlutterLocalNotificationsPlugin? iOSPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iOSPlugin != null) {
      final bool? iosPermission = await iOSPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: true,
        provisional: false,
      );
      permissionGranted = iosPermission ?? false;
      print('iOS notification permission: $iosPermission');
      
      // Check current permission status
      final permissions = await iOSPlugin.checkPermissions();
      print('iOS permissions status: ${permissions?.toString()}');
    }

    return permissionGranted;
  }

  /// Check if notification permissions are granted
  static Future<bool> areNotificationsEnabled() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      return await androidPlugin.areNotificationsEnabled() ?? false;
    }

    final IOSFlutterLocalNotificationsPlugin? iOSPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iOSPlugin != null) {
      final permissions = await iOSPlugin.checkPermissions();
      return permissions?.isEnabled ?? false;
    }

    return false;
  }

  /// Get detailed permission status for iOS
  static Future<Map<String, bool>> getDetailedPermissionStatus() async {
    Map<String, bool> permissionStatus = {};
    
    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iOSPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iOSPlugin != null) {
        final permissions = await iOSPlugin.checkPermissions();
        
        permissionStatus['isEnabled'] = permissions?.isEnabled ?? false;
        // Note: Other detailed permissions may not be available in current version
        print('iOS notification permissions: ${permissions?.toString()}');
      }
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final enabled = await androidPlugin.areNotificationsEnabled() ?? false;
        permissionStatus['isEnabled'] = enabled;
        
        // Check exact alarm permission
        final exactAlarmPermission = await androidPlugin.canScheduleExactNotifications() ?? false;
        permissionStatus['hasExactAlarm'] = exactAlarmPermission;
      }
    }
    
    return permissionStatus;
  }

  /// Schedule an alarm notification
  static Future<void> scheduleAlarm(Alarm alarm) async {
    // Don't schedule if the alarm time is in the past
    if (!alarm.dateTime.isAfter(DateTime.now())) {
      print('Alarm time is in the past, not scheduling: ${alarm.dateTime}');
      return;
    }

    print('Scheduling alarm for: ${alarm.dateTime}');
    print('Current time: ${DateTime.now()}');
    print('Time until alarm: ${alarm.dateTime.difference(DateTime.now())}');
    
    await _notificationsPlugin.zonedSchedule(
      alarm.id.hashCode, // Use alarm ID hash as notification ID
      'Wakey Alarm 🔔',
      'Time to wake up! Your alarm is ringing.',
      tz.TZDateTime.from(alarm.dateTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarm Notifications',
          channelDescription: 'Critical alarm notifications',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alarm_sound'),
          ticker: 'Alarm is ringing!',
          visibility: NotificationVisibility.public,
          autoCancel: false,
          ongoing: true,
          timeoutAfter: 300000, // 5 minutes timeout
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'dismiss',
              'Dismiss',
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              'snooze',
              'Snooze 5 min',
              cancelNotification: false,
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          categoryIdentifier: 'alarm_category',
          threadIdentifier: 'alarm_thread',
          subtitle: 'Wake up time!',
          attachments: [],
          interruptionLevel: InterruptionLevel.critical,
          sound: 'default',
          badgeNumber: 1,
        ),
      ),
      payload: alarm.id,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    
    print('Alarm scheduled successfully with ID: ${alarm.id.hashCode}');
    
    // Verify the alarm was scheduled
    final pending = await getPendingNotifications();
    final scheduledAlarm = pending.firstWhere(
      (notification) => notification.id == alarm.id.hashCode,
      orElse: () => throw Exception('Alarm not found in pending notifications'),
    );
    print('Verified alarm in pending notifications: ${scheduledAlarm.id}');
  }

  /// Cancel an alarm notification
  static Future<void> cancelAlarm(String alarmId) async {
    await _notificationsPlugin.cancel(alarmId.hashCode);
  }

  /// Cancel all alarm notifications
  static Future<void> cancelAllAlarms() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Reschedule all active alarms
  static Future<void> rescheduleAllAlarms(List<Alarm> alarms) async {
    // Cancel all existing notifications
    await cancelAllAlarms();

    // Schedule active future alarms
    for (final alarm in alarms) {
      if (alarm.isActive && alarm.dateTime.isAfter(DateTime.now())) {
        await scheduleAlarm(alarm);
      }
    }
  }

  /// Open system settings for notification permissions
  static Future<void> openNotificationSettings() async {
    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iOSPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      
      if (iOSPlugin != null) {
        // On iOS, we can only request permissions again
        await iOSPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true,
        );
      }
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }
    }
  }

  /// Show a detailed permission status (useful for debugging)
  static Future<void> showPermissionStatus() async {
    print('=== ALARM DEBUGGING INFO ===');
    
    final status = await getDetailedPermissionStatus();
    print('Permission Status:');
    status.forEach((key, value) {
      print('  $key: $value');
    });
    
    final enabled = await areNotificationsEnabled();
    print('Notifications enabled: $enabled');
    
    final pending = await getPendingNotifications();
    print('Pending notifications: ${pending.length}');
    
    for (final notification in pending) {
      print('  - ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
    }
    
    // Check timezone
    final now = DateTime.now();
    final tzNow = tz.TZDateTime.from(now, tz.local);
    print('Current time: $now');
    print('Current timezone time: $tzNow');
    print('Local timezone: ${tz.local.name}');
    
    print('=== END DEBUGGING INFO ===');
  }

  /// Automatically disable past alarms
  static Future<void> disablePastAlarms(List<Alarm> alarms) async {
    final now = DateTime.now();
    
    for (final alarm in alarms) {
      if (alarm.isActive && alarm.dateTime.isBefore(now)) {
        // Disable the alarm
        alarm.isActive = false;
        print('Automatically disabled past alarm: ${alarm.id} at ${alarm.dateTime}');
        
        // Cancel any pending notifications for this alarm
        await cancelAlarm(alarm.id);
      }
    }
  }

  /// Check if an alarm time is in the past
  static bool isAlarmInPast(Alarm alarm) {
    return alarm.dateTime.isBefore(DateTime.now());
  }
}

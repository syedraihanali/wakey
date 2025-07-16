import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wakey/features/alarm/alarm.dart';
import 'package:wakey/features/alarm/alarm_notifications.dart';

class AlarmStorage {
  static const String _boxName = 'alarms';
  static Box<Alarm>? _box;

  /// Initialize Hive and open the alarms box
  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      
      // Register the alarm adapter
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(AlarmAdapter());
      }
      
      // Open the box
      _box = await Hive.openBox<Alarm>(_boxName);
      
      // Validate the box
      if (!_box!.isOpen) {
        throw Exception('Failed to open alarm storage box');
      }
      
    } catch (e) {
      debugPrint('Error initializing AlarmStorage: $e');
      rethrow;
    }
  }

  /// Get the alarms box
  static Box<Alarm> get _alarmBox {
    if (_box == null) {
      throw Exception('AlarmStorage not initialized. Call AlarmStorage.init() first.');
    }
    
    if (!_box!.isOpen) {
      throw Exception('AlarmStorage box is closed. Reinitialize AlarmStorage.');
    }
    
    return _box!;
  }

  /// Save an alarm to local storage
  static Future<void> saveAlarm(Alarm alarm) async {
    try {
      // Validate alarm data
      if (alarm.id.isEmpty) {
        throw Exception('Alarm ID cannot be empty');
      }
      
      // Check if alarm time is valid
      if (alarm.dateTime.isBefore(DateTime(2000))) {
        throw Exception('Alarm dateTime is invalid');
      }
      
      // Save to local storage
      await _alarmBox.put(alarm.id, alarm);
      
      // Schedule notification if alarm is active and in the future
      if (alarm.isActive && alarm.dateTime.isAfter(DateTime.now())) {
        try {
          await AlarmNotifications.scheduleAlarm(alarm);
        } catch (notificationError) {
          debugPrint('Error scheduling notification: $notificationError');
        }
      }
      
    } catch (e) {
      debugPrint('Error saving alarm: $e');
      rethrow;
    }
  }

  /// Get all alarms from local storage
  static List<Alarm> getAllAlarms() {
    try {
      final alarms = _alarmBox.values.toList();
      final now = DateTime.now();
      
      // Check for past alarms and disable them
      for (final alarm in alarms) {
        if (alarm.isActive && alarm.dateTime.isBefore(now)) {
          try {
            alarm.isActive = false;
            _alarmBox.put(alarm.id, alarm);
            AlarmNotifications.cancelAlarm(alarm.id);
          } catch (e) {
            debugPrint('Error auto-disabling past alarm ${alarm.id}: $e');
          }
        }
      }
      
      // Sort by datetime
      alarms.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      return alarms;
    } catch (e) {
      debugPrint('Error getting alarms: $e');
      return [];
    }
  }

  /// Get an alarm by ID
  static Alarm? getAlarmById(String id) {
    return _alarmBox.get(id);
  }

  /// Update an alarm
  static Future<void> updateAlarm(Alarm alarm) async {
    try {
      // Validate alarm data
      if (alarm.id.isEmpty) {
        throw Exception('Alarm ID cannot be empty');
      }
      
      // Save to local storage
      await _alarmBox.put(alarm.id, alarm);
      
      // Cancel existing notification
      try {
        await AlarmNotifications.cancelAlarm(alarm.id);
      } catch (e) {
        debugPrint('Error cancelling notification: $e');
      }
      
      // Schedule new notification if alarm is active and in the future
      if (alarm.isActive && alarm.dateTime.isAfter(DateTime.now())) {
        try {
          await AlarmNotifications.scheduleAlarm(alarm);
        } catch (notificationError) {
          debugPrint('Error rescheduling notification: $notificationError');
        }
      }
      
    } catch (e) {
      debugPrint('Error updating alarm: $e');
      rethrow;
    }
  }

  /// Delete an alarm by ID
  static Future<void> deleteAlarm(String id) async {
    await _alarmBox.delete(id);
    
    // Cancel the notification
    await AlarmNotifications.cancelAlarm(id);
  }

  /// Get all active alarms
  static List<Alarm> getActiveAlarms() {
    return getAllAlarms().where((alarm) => alarm.isActive).toList();
  }

  /// Get future alarms only (not expired)
  static List<Alarm> getFutureAlarms() {
    final now = DateTime.now();
    return getAllAlarms().where((alarm) => alarm.dateTime.isAfter(now)).toList();
  }

  /// Get active future alarms
  static List<Alarm> getActiveFutureAlarms() {
    final now = DateTime.now();
    return getAllAlarms()
        .where((alarm) => alarm.isActive && alarm.dateTime.isAfter(now))
        .toList();
  }

  /// Clear all alarms
  static Future<void> clearAllAlarms() async {
    await _alarmBox.clear();
  }

  /// Close the storage
  static Future<void> close() async {
    await _box?.close();
  }

  /// Listen to alarm changes
  static Stream<List<Alarm>> watchAlarms() {
    return _alarmBox.watch().map((_) => getAllAlarms());
  }

  /// Reschedule all active alarms (useful after app restart)
  static Future<void> rescheduleAllAlarms() async {
    final alarms = getAllAlarms();
    await AlarmNotifications.rescheduleAllAlarms(alarms);
  }

  /// Clean up expired alarms
  static Future<void> cleanupExpiredAlarms() async {
    final now = DateTime.now();
    final allAlarms = getAllAlarms();
    
    for (final alarm in allAlarms) {
      if (alarm.dateTime.isBefore(now)) {
        // Mark expired alarms as inactive
        alarm.isActive = false;
        await _alarmBox.put(alarm.id, alarm);
        
        // Cancel any pending notifications for expired alarms
        await AlarmNotifications.cancelAlarm(alarm.id);
      }
    }
  }

  /// Validate storage initialization
  static bool isInitialized() {
    return _box != null && _box!.isOpen;
  }

  /// Get storage status for debugging
  static Map<String, dynamic> getStorageStatus() {
    return {
      'isInitialized': isInitialized(),
      'boxLength': _box?.length ?? 0,
      'boxPath': _box?.path ?? 'Not initialized',
      'isOpen': _box?.isOpen ?? false,
    };
  }
}

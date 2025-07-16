import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wakey/features/alarm/alarm.dart';
import 'package:wakey/features/alarm/alarm_notification_service.dart';

class AlarmStorage {
  static const String _boxName = 'alarms';
  static Box<Alarm>? _box;

  /// Initialize Hive and open the alarms box
  static Future<void> init() async {
    try {
      print('Initializing AlarmStorage...');
      
      await Hive.initFlutter();
      print('Hive initialized successfully');
      
      // Register the alarm adapter
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(AlarmAdapter());
        print('Alarm adapter registered');
      } else {
        print('Alarm adapter already registered');
      }
      
      // Open the box
      _box = await Hive.openBox<Alarm>(_boxName);
      print('Alarm box opened successfully');
      print('Existing alarms count: ${_box!.length}');
      
      // Validate the box
      if (!_box!.isOpen) {
        throw Exception('Failed to open alarm storage box');
      }
      
      print('AlarmStorage initialization completed successfully');
    } catch (e) {
      print('Error initializing AlarmStorage: $e');
      print('Stack trace: ${StackTrace.current}');
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
      print('Attempting to save alarm: ${alarm.id}');
      print('Alarm details: ${alarm.toString()}');
      
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
      print('Alarm saved to local storage successfully');
      
      // Schedule notification if alarm is active and in the future
      if (alarm.isActive && alarm.dateTime.isAfter(DateTime.now())) {
        try {
          await AlarmNotificationService.scheduleAlarm(alarm);
          print('Alarm saved and scheduled: ${alarm.id} at ${alarm.dateTime}');
        } catch (notificationError) {
          print('Error scheduling notification: $notificationError');
          // Still keep the alarm saved even if notification fails
        }
      } else {
        print('Alarm saved but not scheduled (inactive or past): ${alarm.id}');
        print('  IsActive: ${alarm.isActive}');
        print('  DateTime: ${alarm.dateTime}');
        print('  Now: ${DateTime.now()}');
      }
      
      print('Alarm save operation completed successfully');
    } catch (e) {
      print('Error saving alarm: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow; // Re-throw to let UI handle the error
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
            // Save the updated alarm asynchronously
            _alarmBox.put(alarm.id, alarm);
            // Cancel notification
            AlarmNotificationService.cancelAlarm(alarm.id);
            print('Auto-disabled past alarm: ${alarm.id}');
          } catch (e) {
            print('Error auto-disabling past alarm ${alarm.id}: $e');
          }
        }
      }
      
      // Sort by datetime
      alarms.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      return alarms;
    } catch (e) {
      print('Error getting alarms: $e');
      return []; // Return empty list on error
    }
  }

  /// Get an alarm by ID
  static Alarm? getAlarmById(String id) {
    return _alarmBox.get(id);
  }

  /// Update an alarm
  static Future<void> updateAlarm(Alarm alarm) async {
    try {
      print('Updating alarm: ${alarm.id}');
      
      // Validate alarm data
      if (alarm.id.isEmpty) {
        throw Exception('Alarm ID cannot be empty');
      }
      
      // Save to local storage
      await _alarmBox.put(alarm.id, alarm);
      print('Alarm updated in local storage');
      
      // Cancel existing notification
      try {
        await AlarmNotificationService.cancelAlarm(alarm.id);
        print('Cancelled existing notification for alarm: ${alarm.id}');
      } catch (e) {
        print('Error cancelling notification: $e');
      }
      
      // Schedule new notification if alarm is active and in the future
      if (alarm.isActive && alarm.dateTime.isAfter(DateTime.now())) {
        try {
          await AlarmNotificationService.scheduleAlarm(alarm);
          print('Alarm rescheduled: ${alarm.id} at ${alarm.dateTime}');
        } catch (notificationError) {
          print('Error rescheduling notification: $notificationError');
        }
      } else {
        print('Alarm updated but not scheduled (inactive or past): ${alarm.id}');
      }
      
      print('Alarm update operation completed successfully');
    } catch (e) {
      print('Error updating alarm: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Delete an alarm by ID
  static Future<void> deleteAlarm(String id) async {
    await _alarmBox.delete(id);
    
    // Cancel the notification
    await AlarmNotificationService.cancelAlarm(id);
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
    await AlarmNotificationService.rescheduleAllAlarms(alarms);
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
        await AlarmNotificationService.cancelAlarm(alarm.id);
        
        print('Disabled expired alarm: ${alarm.id} at ${alarm.dateTime}');
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

  /// Test alarm creation (for debugging)
  static Future<void> testAlarmCreation() async {
    try {
      print('Testing alarm creation...');
      
      // Create a test alarm
      final testAlarm = Alarm(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        dateTime: DateTime.now().add(const Duration(minutes: 1)),
        latitude: 0.0,
        longitude: 0.0,
        locationName: 'Test Location',
        isActive: true,
        label: 'Test Alarm',
      );
      
      print('Test alarm created: ${testAlarm.toString()}');
      
      // Save the test alarm
      await saveAlarm(testAlarm);
      print('Test alarm saved successfully');
      
      // Verify it was saved
      final savedAlarm = getAlarmById(testAlarm.id);
      if (savedAlarm != null) {
        print('Test alarm verified in storage: ${savedAlarm.toString()}');
      } else {
        print('ERROR: Test alarm not found in storage');
      }
      
      // Clean up test alarm
      await deleteAlarm(testAlarm.id);
      print('Test alarm deleted');
      
    } catch (e) {
      print('Error during alarm creation test: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakey/features/onboarding/screens/onboarding.dart';
import 'package:wakey/features/alarm/alarm_storage.dart';
import 'package:wakey/features/alarm/alarm_notification_service.dart';
import 'package:wakey/features/alarm/alarm_background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive storage
    await AlarmStorage.init();
    print('AlarmStorage initialized successfully');
    
    // Print storage status
    final storageStatus = AlarmStorage.getStorageStatus();
    print('Storage status: $storageStatus');
    
    // Initialize notification service
    await AlarmNotificationService.init();
    print('AlarmNotificationService initialized successfully');
    
    // Initialize background service
    await AlarmBackgroundService.init();
    print('AlarmBackgroundService initialized successfully');
    
    // Clean up expired alarms
    await AlarmStorage.cleanupExpiredAlarms();
    print('Expired alarms cleaned up');
    
    // Reschedule all existing alarms
    await AlarmStorage.rescheduleAllAlarms();
    print('All alarms rescheduled');
    
    // Debug scheduled alarms
    await AlarmBackgroundService.debugScheduledAlarms();
    
    // Test alarm creation
    await AlarmStorage.testAlarmCreation();
    
  } catch (e) {
    print('Error during initialization: $e');
    print('Stack trace: ${StackTrace.current}');
  }
  
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Reschedule alarms when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _rescheduleAlarms();
    }
  }

  Future<void> _rescheduleAlarms() async {
    try {
      await AlarmStorage.rescheduleAllAlarms();
      print('Alarms rescheduled on app resume');
    } catch (e) {
      print('Error rescheduling alarms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Wakey App',
      home: const OnBoarding(),
    );
  }
}

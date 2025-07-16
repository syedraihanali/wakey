import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakey/features/splash/splash_screen.dart';
import 'package:wakey/features/alarm/alarm_storage.dart';
import 'package:wakey/features/alarm/alarm_notifications.dart';
import 'package:wakey/features/alarm/notification_handler.dart';
import 'package:wakey/features/alarm/alarm_background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize core services
    await AlarmStorage.init();
    await AlarmNotifications.init();
    await NotificationHandler.init();
    await AlarmBackgroundService.init();
    
    // Clean up and reschedule existing alarms
    await AlarmStorage.cleanupExpiredAlarms();
    await NotificationHandler.rescheduleAllAlarms();
    
  } catch (e) {
    // Log error in production, but don't prevent app startup
    debugPrint('Error during initialization: $e');
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
      await NotificationHandler.rescheduleAllAlarms();
    } catch (e) {
      debugPrint('Error rescheduling alarms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Wakey',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Oxygen',
      ),
      home: const SplashScreen(),
    );
  }
}

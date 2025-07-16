import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakey/constants/text_theme.dart';
import 'package:wakey/features/alarm/alarm.dart';
import 'package:wakey/features/alarm/alarm_storage.dart';
import 'package:wakey/features/alarm/alarm_notification_service.dart';

class AlarmStatusWidget extends StatefulWidget {
  const AlarmStatusWidget({super.key});

  @override
  State<AlarmStatusWidget> createState() => _AlarmStatusWidgetState();
}

class _AlarmStatusWidgetState extends State<AlarmStatusWidget> {
  List<Alarm> _activeAlarms = [];
  List<PendingNotificationRequest> _pendingNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final activeAlarms = AlarmStorage.getActiveFutureAlarms();
      final pendingNotifications = await AlarmNotificationService.getPendingNotifications();
      
      setState(() {
        _activeAlarms = activeAlarms;
        _pendingNotifications = pendingNotifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alarm Status',
                  style: TextStyle(
                    fontSize: AppTextTheme.displayMedium(context),
                    fontFamily: AppTextTheme.fontFamily,
                    fontWeight: AppTextTheme.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadStatus,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              icon: Icons.alarm,
              title: 'Active Alarms',
              value: '${_activeAlarms.length}',
              color: _activeAlarms.isNotEmpty ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 8),
            _buildStatusItem(
              icon: Icons.notifications,
              title: 'Scheduled Notifications',
              value: '${_pendingNotifications.length}',
              color: _pendingNotifications.isNotEmpty ? Colors.blue : Colors.grey,
            ),
            if (_activeAlarms.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Next Alarm:',
                style: TextStyle(
                  fontSize: AppTextTheme.bodyMedium(context),
                  fontFamily: AppTextTheme.fontFamily,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              _buildNextAlarmInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: AppTextTheme.bodyMedium(context),
              fontFamily: AppTextTheme.fontFamily,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: AppTextTheme.bodySmall(context),
              fontFamily: AppTextTheme.fontFamily,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextAlarmInfo() {
    if (_activeAlarms.isEmpty) return const SizedBox();

    final nextAlarm = _activeAlarms.first;
    final now = DateTime.now();
    final duration = nextAlarm.dateTime.difference(now);
    
    String timeUntil;
    if (duration.inDays > 0) {
      timeUntil = '${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m';
    } else if (duration.inHours > 0) {
      timeUntil = '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      timeUntil = '${duration.inMinutes}m';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${nextAlarm.formattedDate} at ${nextAlarm.formattedTime}',
            style: TextStyle(
              fontSize: AppTextTheme.bodyMedium(context),
              fontFamily: AppTextTheme.fontFamily,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'In $timeUntil',
            style: TextStyle(
              fontSize: AppTextTheme.bodySmall(context),
              fontFamily: AppTextTheme.fontFamily,
              color: Colors.blue,
            ),
          ),
          if (nextAlarm.label != null) ...[
            const SizedBox(height: 4),
            Text(
              nextAlarm.label!,
              style: TextStyle(
                fontSize: AppTextTheme.bodySmall(context),
                fontFamily: AppTextTheme.fontFamily,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

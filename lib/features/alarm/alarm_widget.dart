import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakey/constants/text_theme.dart';

class AlarmWidget extends StatelessWidget {
  final String time;
  final String date;
  final bool isActive;
  final Function(bool)? onToggle;
  final VoidCallback? onDelete;
  final DateTime? alarmDateTime; // Add this to check if alarm is in past

  const AlarmWidget({
    super.key,
    required this.time,
    required this.date,
    this.isActive = true,
    this.onToggle,
    this.onDelete,
    this.alarmDateTime, // Add this parameter
  });

  /// Check if alarm time is in the past
  bool _isAlarmInPast() {
    if (alarmDateTime == null) return false;
    return alarmDateTime!.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTextTheme.specialButton,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppTextTheme.primaryButton.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: AppTextTheme.titleMediumStyle(context).copyWith(
                    color: isActive ? Colors.white : Colors.white60,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: AppTextTheme.bodySmallStyle(context).copyWith(
                    color: isActive ? Colors.white60 : Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isActive ? AppTextTheme.primaryButton.withOpacity(0.1) : Colors.transparent,
                ),
                child: Switch(
                  value: isActive,
                  onChanged: _isAlarmInPast() ? null : (value) {
                    if (onToggle != null) {
                      onToggle!(value);
                    } else {
                      Get.snackbar(
                        'Info',
                        'Alarm toggle functionality will be implemented later',
                        backgroundColor: AppTextTheme.primaryButton,
                        colorText: Colors.white,
                      );
                    }
                  },
                  activeColor: Colors.white,
                  activeTrackColor: AppTextTheme.primaryButton,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: _isAlarmInPast() ? Colors.white12 : Colors.white24,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.white54,
                    size: 20,
                  ),
                  onPressed: () {
                    _showDeleteConfirmation(context);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTextTheme.backgroundColor,
          title: Text(
            'Delete Alarm',
            style: AppTextTheme.titleMediumStyle(context).copyWith(
              color: Colors.white,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this alarm?',
            style: AppTextTheme.bodyMediumStyle(context).copyWith(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTextTheme.bodyMediumStyle(context).copyWith(
                  color: AppTextTheme.secondaryButton,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onDelete != null) {
                  onDelete!();
                }
              },
              child: Text(
                'Delete',
                style: AppTextTheme.bodyMediumStyle(context).copyWith(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

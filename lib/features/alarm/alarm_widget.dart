import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakey/constants/text_theme.dart';

class AlarmWidget extends StatelessWidget {
  final String time;
  final String date;
  final bool isActive;
  final Function(bool)? onToggle;
  final VoidCallback? onDelete;

  const AlarmWidget({
    super.key,
    required this.time,
    required this.date,
    this.isActive = true,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTextTheme.specialButton,
        borderRadius: BorderRadius.circular(12),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: AppTextTheme.bodySmallStyle(context).copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Switch(
                value: isActive,
                onChanged: (value) {
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
                activeColor: AppTextTheme.primaryButton,
                inactiveThumbColor: Colors.white38,
                inactiveTrackColor: Colors.white12,
              ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white54),
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

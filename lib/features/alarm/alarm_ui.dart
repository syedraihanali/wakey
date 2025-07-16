// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakey/constants/text_theme.dart';
import 'package:wakey/features/alarm/alarm_widget.dart';

class AlarmUI extends StatefulWidget {
  const AlarmUI({super.key});

  @override
  _AlarmUIState createState() => _AlarmUIState();
}

class _AlarmUIState extends State<AlarmUI> {
  List<AlarmData> alarms = [
    AlarmData(time: '7:10 pm', date: 'Fri 21 Mar 2025', isActive: true),
    AlarmData(time: '6:55 pm', date: 'Fri 28 Mar 2025', isActive: true),
    AlarmData(time: '7:00 pm', date: 'Apr 04 Mar 2025', isActive: false),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTextTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTextTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Alarms',
          style: AppTextTheme.titleLargeStyle(context).copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              
              // Add New Alarm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showAddAlarmDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTextTheme.primaryButton,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.018,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Add New Alarm',
                    style: AppTextTheme.titleSmallStyle(context).copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Alarms List
              Expanded(
                child: ListView.builder(
                  itemCount: alarms.length,
                  itemBuilder: (context, index) {
                    final alarm = alarms[index];
                    return AlarmWidget(
                      time: alarm.time,
                      date: alarm.date,
                      isActive: alarm.isActive,
                      onToggle: (value) {
                        setState(() {
                          alarms[index].isActive = value;
                        });
                      },
                      onDelete: () {
                        setState(() {
                          alarms.removeAt(index);
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAlarmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlarmPickerDialog(
          onAlarmSet: (DateTime alarmDateTime) {
            _addAlarm(alarmDateTime);
          },
        );
      },
    );
  }

  void _addAlarm(DateTime alarmDateTime) {
    String timeString = _formatTime(alarmDateTime);
    String dateString = _formatDate(alarmDateTime);
    
    setState(() {
      alarms.add(AlarmData(
        time: timeString,
        date: dateString,
        isActive: true,
      ));
    });
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = hour >= 12 ? 'pm' : 'am';
    
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    
    return '${hour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime dateTime) {
    List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    String weekday = weekdays[dateTime.weekday - 1];
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = months[dateTime.month - 1];
    String year = dateTime.year.toString();
    
    return '$weekday $day $month $year';
  }
}

class AlarmData {
  String time;
  String date;
  bool isActive;

  AlarmData({required this.time, required this.date, required this.isActive});
}

class AlarmPickerDialog extends StatefulWidget {
  final Function(DateTime) onAlarmSet;

  const AlarmPickerDialog({super.key, required this.onAlarmSet});

  @override
  _AlarmPickerDialogState createState() => _AlarmPickerDialogState();
}

class _AlarmPickerDialogState extends State<AlarmPickerDialog> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: AppTextTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set Alarm',
              style: AppTextTheme.titleLargeStyle(context).copyWith(
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            
            // Date Picker Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _selectDate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTextTheme.specialButton,
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: AppTextTheme.bodyMediumStyle(context).copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.015),

            // Time Picker Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _selectTime(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTextTheme.specialButton,
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  selectedTime.format(context),
                  style: AppTextTheme.bodyMediumStyle(context).copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTextTheme.secondaryButton,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextTheme.bodyMediumStyle(context).copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final alarmDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      widget.onAlarmSet(alarmDateTime);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTextTheme.primaryButton,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Set Alarm',
                      style: AppTextTheme.bodyMediumStyle(context).copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTextTheme.primaryButton,
              surface: AppTextTheme.backgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTextTheme.primaryButton,
              surface: AppTextTheme.backgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }
}

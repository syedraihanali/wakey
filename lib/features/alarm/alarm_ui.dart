// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakey/constants/text_theme.dart';
import 'package:wakey/features/alarm/alarm_widget.dart';
import 'package:wakey/features/alarm/alarm.dart';
import 'package:wakey/features/alarm/alarm_storage.dart';
import 'package:wakey/features/alarm/alarm_notification_service.dart';

class AlarmUI extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? locationName;

  const AlarmUI({
    super.key,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  @override
  _AlarmUIState createState() => _AlarmUIState();
}

class _AlarmUIState extends State<AlarmUI> {
  List<Alarm> alarms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  void _loadAlarms() {
    setState(() {
      isLoading = true;
    });
    
    try {
      final loadedAlarms = AlarmStorage.getAllAlarms();
      setState(() {
        alarms = loadedAlarms;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      Get.snackbar(
        'Error',
        'Failed to load alarms: ${e.toString()}',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Check if location is available
    final bool hasLocation = widget.latitude != null && 
                           widget.longitude != null && 
                           widget.locationName != null;

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
              
              // Location info (if available)
              if (hasLocation)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: AppTextTheme.specialButton,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white54, size: 16),
                      SizedBox(width: 8),
                      Text(
                        widget.locationName!,
                        style: AppTextTheme.bodyMediumStyle(context).copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (hasLocation) SizedBox(height: screenHeight * 0.02),
              
              // Add New Alarm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hasLocation 
                      ? () => _showAddAlarmDialog(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasLocation 
                        ? AppTextTheme.specialButton
                        : AppTextTheme.secondaryButton,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.018,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Add Alarm',
                    style: AppTextTheme.titleSmallStyle(context).copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              if (!hasLocation) ...[
                SizedBox(height: screenHeight * 0.02),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Location access is required to set alarms. Please enable location and try again.',
                          style: AppTextTheme.bodySmallStyle(context).copyWith(
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: screenHeight * 0.04),

              // Alarms Title
              Text(
                'Alarms',
                style: AppTextTheme.titleLargeStyle(context).copyWith(
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              
              // Status section
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStatusRow('Active Alarms', alarms.where((a) => a.isActive).length.toString()),
                    const SizedBox(height: 8),
                    _buildStatusRow('Total Alarms', alarms.length.toString()),
                    if (alarms.where((a) => a.isActive && a.dateTime.isAfter(DateTime.now())).isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Next Alarm:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getNextAlarmText(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Alarms List
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppTextTheme.primaryButton,
                        ),
                      )
                    : alarms.isEmpty
                        ? Center(
                            child: Text(
                              'No alarms set',
                              style: AppTextTheme.bodyMediumStyle(context).copyWith(
                                color: Colors.white54,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: alarms.length,
                            itemBuilder: (context, index) {
                              final alarm = alarms[index];
                              return AlarmWidget(
                                time: alarm.formattedTime,
                                date: alarm.formattedDate,
                                isActive: alarm.isActive,
                                onToggle: (value) async {
                                  await _toggleAlarm(index, value);
                                },
                                onDelete: () async {
                                  await _deleteAlarm(index);
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
          latitude: widget.latitude!,
          longitude: widget.longitude!,
          locationName: widget.locationName!,
          onAlarmSet: (Alarm alarm) {
            _addAlarm(alarm);
          },
        );
      },
    );
  }

  void _addAlarm(Alarm alarm) async {
    try {
      // Check if permissions are already granted
      bool permissionGranted = await AlarmNotificationService.areNotificationsEnabled();
      
      if (!permissionGranted) {
        // Request notification permissions
        permissionGranted = await AlarmNotificationService.requestPermissions();
        
        if (!permissionGranted) {
          Get.snackbar(
            'Permission Required',
            'Notification permissions are required for alarms to work properly. Please enable them in Settings.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            mainButton: TextButton(
              onPressed: () => AlarmNotificationService.openNotificationSettings(),
              child: const Text('Settings', style: TextStyle(color: Colors.white)),
            ),
          );
          // Still save the alarm even if notification permission is denied
        }
      }
      
      await AlarmStorage.saveAlarm(alarm);
      _loadAlarms(); // Reload alarms from storage
      
      // Return success to home screen
      Get.back(result: true);
      
      Get.snackbar(
        'Success',
        'Alarm set successfully',
        backgroundColor: AppTextTheme.primaryButton,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save alarm: ${e.toString()}',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _toggleAlarm(int index, bool value) async {
    try {
      final alarm = alarms[index];
      final updatedAlarm = alarm.copyWith(isActive: value);
      
      await AlarmStorage.updateAlarm(updatedAlarm);
      
      setState(() {
        alarms[index] = updatedAlarm;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update alarm: ${e.toString()}',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _deleteAlarm(int index) async {
    try {
      final alarm = alarms[index];
      await AlarmStorage.deleteAlarm(alarm.id);
      
      setState(() {
        alarms.removeAt(index);
      });
      
      Get.snackbar(
        'Success',
        'Alarm deleted',
        backgroundColor: AppTextTheme.primaryButton,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete alarm: ${e.toString()}',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildStatusRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getNextAlarmText() {
    final nextAlarm = alarms
        .where((a) => a.isActive && a.dateTime.isAfter(DateTime.now()))
        .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    if (nextAlarm.isEmpty) return 'No upcoming alarms';
    
    final alarm = nextAlarm.first;
    final duration = alarm.dateTime.difference(DateTime.now());
    
    String timeUntil;
    if (duration.inDays > 0) {
      timeUntil = '${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m';
    } else if (duration.inHours > 0) {
      timeUntil = '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      timeUntil = '${duration.inMinutes}m';
    }
    
    return '${alarm.formattedDate} at ${alarm.formattedTime} (in $timeUntil)';
  }
}

class AlarmPickerDialog extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;
  final Function(Alarm) onAlarmSet;

  const AlarmPickerDialog({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.onAlarmSet,
  });

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

    // Combine date and time
    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final bool isInFuture = selectedDateTime.isAfter(DateTime.now());

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
            SizedBox(height: screenHeight * 0.02),
            
            // Location info
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.01,
              ),
              decoration: BoxDecoration(
                color: AppTextTheme.specialButton,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white54, size: 16),
                  SizedBox(width: 8),
                  Text(
                    widget.locationName,
                    style: AppTextTheme.bodySmallStyle(context).copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
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

            SizedBox(height: screenHeight * 0.02),

            // Future time validation
            if (!isInFuture)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Please select a future time',
                      style: AppTextTheme.bodySmallStyle(context).copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: screenHeight * 0.02),

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
                    onPressed: isInFuture ? () => _createAlarm() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInFuture
                          ? AppTextTheme.primaryButton
                          : AppTextTheme.secondaryButton,
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

  void _createAlarm() {
    final alarmDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final alarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: alarmDateTime,
      latitude: widget.latitude,
      longitude: widget.longitude,
      locationName: widget.locationName,
      isActive: true,
    );

    widget.onAlarmSet(alarm);
    Navigator.of(context).pop();
  }
}

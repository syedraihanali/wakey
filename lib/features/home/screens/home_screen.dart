// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:wakey/constants/text_theme.dart';
import 'package:wakey/constants/image_strings.dart';
import 'package:wakey/features/alarm/alarm_widget.dart';
import 'package:wakey/features/alarm/alarm_ui.dart';
import 'package:wakey/features/alarm/alarm_storage.dart';
import 'package:wakey/features/alarm/alarm.dart';

class HomeScreen extends StatefulWidget {
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;

  const HomeScreen({
    super.key,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _city;
  String? _country;
  bool _isLoadingLocation = false;
  List<Alarm> _alarms = [];

  @override
  void initState() {
    super.initState();
    _city = widget.city;
    _country = widget.country;
    _loadAlarms();
  }

  void _loadAlarms() {
    setState(() {
      _alarms = AlarmStorage.getAllAlarms();
    });
  }

  Future<void> _enableLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw 'Location permission denied.';
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      Placemark place = placemarks[0];

      setState(() {
        _city = place.locality;
        _country = place.country;
      });
    } catch (e) {
      Get.snackbar(
        'Location Error',
        'Unable to get location. Please try again.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload alarms when coming back from other screens
    _loadAlarms();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool locationAvailable = _city != null && _country != null;
    final String locationText = locationAvailable
        ? '$_city, $_country'
        : 'Please enable location permission';

    return Scaffold(
      backgroundColor: AppTextTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.06),

              // Selected Location Title
              Text(
                'Selected Location',
                style: AppTextTheme.titleMediumStyle(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),

              // Location Details Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    ImageStrings.locator,
                    width: screenWidth * 0.05,
                    height: screenWidth * 0.05,
                    color: Colors.white,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Text(
                      locationText,
                      style: AppTextTheme.bodySmallStyle(context).copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.025),

              // Action Button (Add Alarm or Enable Location)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: locationAvailable
                      ? () async {
                          // Navigate to Alarm UI with location data
                          final result = await Get.to(() => AlarmUI(
                            latitude: widget.latitude,
                            longitude: widget.longitude,
                            locationName: '$_city, $_country',
                          ));
                          
                          // Reload alarms when returning from AlarmUI
                          if (result != null) {
                            _loadAlarms();
                          }
                        }
                      : _isLoadingLocation
                          ? null
                          : _enableLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTextTheme.specialButton,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.018,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _isLoadingLocation
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          locationAvailable ? 'Add Alarm' : 'Enable Location',
                          style: AppTextTheme.titleSmallStyle(context).copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Alarms Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alarms',
                    style: AppTextTheme.titleLargeStyle(context).copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${_alarms.length} alarm${_alarms.length != 1 ? 's' : ''}',
                    style: AppTextTheme.bodySmallStyle(context).copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.02),

              // Alarm Cards List
              Expanded(
                child: _alarms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.alarm_off,
                              size: 64,
                              color: Colors.white30,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No alarms set',
                              style: AppTextTheme.titleMediumStyle(context).copyWith(
                                color: Colors.white60,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              locationAvailable 
                                  ? 'Tap "Add Alarm" to create your first alarm'
                                  : 'Enable location to start adding alarms',
                              textAlign: TextAlign.center,
                              style: AppTextTheme.bodySmallStyle(context).copyWith(
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          _loadAlarms();
                        },
                        backgroundColor: AppTextTheme.specialButton,
                        color: AppTextTheme.primaryButton,
                        child: ListView.builder(
                          itemCount: _alarms.length,
                          itemBuilder: (context, index) {
                            final alarm = _alarms[index];
                            return AlarmWidget(
                              time: alarm.formattedTime,
                              date: alarm.formattedDate,
                              isActive: alarm.isActive,
                              alarmDateTime: alarm.dateTime, // Pass the alarm DateTime
                              onToggle: (bool value) async {
                                await AlarmStorage.updateAlarm(alarm.copyWith(isActive: value));
                                _loadAlarms();
                              },
                              onDelete: () async {
                                await AlarmStorage.deleteAlarm(alarm.id);
                                _loadAlarms();
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

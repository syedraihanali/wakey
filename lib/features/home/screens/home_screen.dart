// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:wakey/constants/text_theme.dart';
import 'package:wakey/constants/image_strings.dart';
import 'package:wakey/features/alarm/alarm_widget.dart';
import 'package:wakey/features/alarm/alarm_ui.dart';

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

  @override
  void initState() {
    super.initState();
    _city = widget.city;
    _country = widget.country;
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
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoadingLocation = false);
    }
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
                      ? () {
                          // Navigate to Alarm UI
                          Get.to(() => const AlarmUI());
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
              Text(
                'Alarms',
                style: AppTextTheme.titleLargeStyle(context).copyWith(
                  color: Colors.white,
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Alarm Cards List
              Expanded(
                child: ListView(
                  children: const [
                    AlarmWidget(time: '7:10 pm', date: 'Fri 21 Mar 2025'),
                    AlarmWidget(time: '6:55 pm', date: 'Fri 28 Mar 2025'),
                    AlarmWidget(time: '7:00 pm', date: 'Apr 04 Mar 2025'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:wakey/constants/image_strings.dart';
import 'package:wakey/constants/text_theme.dart';
import 'package:wakey/helpers/helper_func.dart';
import 'package:wakey/features/home/screens/home_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isCheckingPermission = false;

  Future<void> _requestLocationPermission() async {
    setState(() => _isCheckingPermission = true);

    try {
      // Step 1: Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        throw 'Location services are disabled.';
      }

      // Step 2: Request permissions if needed
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw 'Location permission denied.';
      }

      // Step 3: Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Step 4: Reverse geocoding to get city & country
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];

      // Step 5: Navigate to home with location info
      Get.off(() => HomeScreen(
            latitude: position.latitude,
            longitude: position.longitude,
            city: place.locality ?? '',
            country: place.country ?? '',
          ));
    } catch (e) {
      Get.snackbar("Location Error", e.toString());
      Get.off(() => const HomeScreen());
    } finally {
      setState(() => _isCheckingPermission = false);
    }
  }

  void _navigateToHome() {
    Get.off(() => const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTextTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(HelperFunctions.screenWidth(context) * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: HelperFunctions.screenHeight(context) * 0.04),

              Text(
                'Welcome! Your\nPersonalized Alarm',
                style: TextStyle(
                  fontFamily: 'Oxygen',
                  fontSize: HelperFunctions.screenWidth(context) * 0.075,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.left,
              ),

              SizedBox(height: HelperFunctions.screenHeight(context) * 0.02),

              Text(
                'Allow us to sync your sunset alarm\nbased on your location.',
                style: TextStyle(
                  fontFamily: 'Oxygen',
                  fontSize: HelperFunctions.screenWidth(context) * 0.04,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.4,
                ),
                textAlign: TextAlign.left,
              ),

              Expanded(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      HelperFunctions.screenWidth(context) * 0.02,
                    ),
                    child: Image.asset(
                      ImageStrings.locationAccess,
                      width: HelperFunctions.screenWidth(context) * 0.8,
                      height: HelperFunctions.screenWidth(context) * 0.8,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

                // Use Current Location Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isCheckingPermission ? null : _requestLocationPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTextTheme.specialButton,
                      padding: EdgeInsets.symmetric(
                        vertical: HelperFunctions.screenHeight(context) * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          HelperFunctions.screenWidth(context) * 0.03,
                        ),
                      ),
                    ),
                    child: _isCheckingPermission
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Use Current Location',
                                style: TextStyle(
                                  fontFamily: 'Oxygen',
                                  fontSize: HelperFunctions.screenWidth(context) * 0.042,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: HelperFunctions.screenWidth(context) * 0.02),
                              Image.asset(
                                ImageStrings.locator,
                                width: HelperFunctions.screenWidth(context) * 0.07,
                                height: HelperFunctions.screenWidth(context) * 0.07,
                                color: Colors.white,
                                colorBlendMode: BlendMode.srcIn,
                              ),
                            ],
                          ),
                  ),
                ),

                SizedBox(height: HelperFunctions.screenHeight(context) * 0.01),

                // Go to Home Without Location
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTextTheme.specialButton,
                      padding: EdgeInsets.symmetric(
                        vertical: HelperFunctions.screenHeight(context) * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          HelperFunctions.screenWidth(context) * 0.03,
                        ),
                      ),
                    ),
                    child: Text(
                      'Home',
                      style: TextStyle(
                        fontFamily: 'Oxygen',
                        fontSize: HelperFunctions.screenWidth(context) * 0.042,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: HelperFunctions.screenHeight(context) * 0.02),
              ],
            ),
          ),
        ),
      
    );
  }
}

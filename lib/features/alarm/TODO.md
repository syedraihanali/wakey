# Alarm Feature TODO List

## Core Requirements
- [x] Require location access before allowing alarm creation
- [x] Implement regular alarm system (date + time picker)
- [x] Display alarms with time and date as shown in design
- [x] Store alarms in local database
- [x] Show notifications when alarms go off

## UI Design
- [x] Create alarm UI layout matching the design
- [x] Add date and time picker for setting alarms
- [x] Display alarm list with time and date format
- [x] Show location requirement message when location not available
- [x] Add alarm toggle and delete functionality

## Functionality
- [x] Implement alarm creation with date and time selection
- [x] Calculate and store alarm times
- [x] Implement logic for deleting alarms
- [x] Implement logic for toggling alarm activation
- [x] Validate alarm times (future dates/times only)

## Local Storage
- [x] Set up Hive for storing alarms
- [x] Generate Hive adapter for the `Alarm` class
- [x] Save alarms to local storage
- [x] Retrieve alarms from local storage
- [x] Store location data with each alarm

## Notifications
- [x] Set up Flutter Local Notifications
- [x] Schedule notifications for alarm times
- [x] Handle notification actions (e.g., dismiss or snooze)
- [x] Show notification when alarm goes off
- [x] Handle app in background/foreground scenarios

## Location Integration
- [x] Ensure location is required for alarm creation
- [x] Handle location permission denied scenarios
- [x] Show appropriate messages when location unavailable
- [x] Store location coordinates with each alarm

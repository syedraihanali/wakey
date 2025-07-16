# Sunset Alarm Feature TODO List

## Core Logic
- [ ] Implement sunset time calculation based on location and date
- [ ] Add sunset time API/library integration (e.g., sunrise_sunset API)
- [ ] Validate that selected date is in the future
- [ ] Prevent alarm creation without location access

## UI Design
- [x] Create the alarm UI layout
- [ ] Update date picker to only allow future dates
- [ ] Remove time picker (sunset time is automatic)
- [ ] Display calculated sunset time for selected date
- [ ] Show location-based sunset preview
- [ ] Update alarm display to show "Sunset" instead of specific time

## Functionality
- [ ] Implement sunset alarm creation (date only)
- [ ] Calculate and store sunset time for each alarm
- [ ] Implement logic for deleting sunset alarms
- [ ] Implement logic for toggling sunset alarm activation
- [ ] Update alarm on location change

## Local Storage
- [ ] Set up Hive for storing sunset alarms
- [ ] Generate Hive adapter for the `SunsetAlarm` class
- [ ] Save sunset alarms to local storage
- [ ] Retrieve sunset alarms from local storage
- [ ] Store location data with each alarm

## Notifications
- [ ] Set up Flutter Local Notifications
- [ ] Schedule notifications for calculated sunset times
- [ ] Handle notification actions (e.g., dismiss or snooze)
- [ ] Update notification times when location changes

## Location Integration
- [ ] Ensure location is required for alarm creation
- [ ] Recalculate sunset times when location changes
- [ ] Handle location permission denied scenarios
- [ ] Store location coordinates with each alarm

## Testing
- [ ] Write unit tests for sunset calculation logic
- [ ] Write integration tests for sunset alarm notifications
- [ ] Write widget tests for sunset alarm UI

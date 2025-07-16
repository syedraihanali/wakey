# Wakey - Release Build Scripts

## Android Release Build
```bash
flutter build apk --release
```

## iOS Release Build
```bash
flutter build ios --release
```

## Web Release Build
```bash
flutter build web --release
```

## Build for All Platforms
```bash
flutter build apk --release
flutter build ios --release
flutter build web --release
```

## Pre-release Checks
1. Run tests: `flutter test`
2. Analyze code: `flutter analyze`
3. Check for unused dependencies: `flutter pub deps`
4. Format code: `flutter format .`

## Release Notes v1.0.0

- Complete onboarding flow with skip functionality
- Location-based alarm personalization
- Advanced notification system with multiple actions
- Snooze functionality (5min, 10min, 15min options)
- Reminder notifications (5 minutes before alarm)
- Local storage with Hive database
- Background service for alarm management
- Automatic cleanup of expired alarms
- Clean, modern UI matching design specifications
- Production-ready splash screen
- Comprehensive error handling

## Production Features

- No debug prints in release mode
- Advanced notification system with rich actions
- Proper error handling throughout the app
- Optimized performance with background processing
- Clean architecture with separation of concerns
- Responsive design for all screen sizes
- Smart permission handling for location and notifications
- Automatic alarm rescheduling on app resume

import 'package:hive/hive.dart';

part 'alarm.g.dart';

@HiveType(typeId: 0)
class Alarm extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime dateTime;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final String locationName;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  final String? label;

  Alarm({
    required this.id,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.isActive,
    this.label,
  });

  /// Create a copy with updated values
  Alarm copyWith({
    String? id,
    DateTime? dateTime,
    double? latitude,
    double? longitude,
    String? locationName,
    bool? isActive,
    String? label,
  }) {
    return Alarm(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      isActive: isActive ?? this.isActive,
      label: label ?? this.label,
    );
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'isActive': isActive,
      'label': label,
    };
  }

  /// Create from Map
  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      dateTime: DateTime.parse(map['dateTime']),
      latitude: map['latitude'],
      longitude: map['longitude'],
      locationName: map['locationName'],
      isActive: map['isActive'],
      label: map['label'],
    );
  }

  /// Format time for display
  String get formattedTime {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = hour >= 12 ? 'pm' : 'am';
    
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    
    return '${hour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Format date for display
  String get formattedDate {
    List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    String weekday = weekdays[dateTime.weekday - 1];
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = months[dateTime.month - 1];
    String year = dateTime.year.toString();
    
    return '$weekday $day $month $year';
  }

  /// Check if alarm is in the future
  bool get isInFuture {
    return dateTime.isAfter(DateTime.now());
  }

  @override
  String toString() {
    return 'Alarm(id: $id, dateTime: $dateTime, location: $locationName, isActive: $isActive)';
  }
}

class SunsetAlarm {
  final String id;
  final DateTime date;
  final DateTime sunsetTime;
  final double latitude;
  final double longitude;
  final String locationName;
  final bool isActive;

  SunsetAlarm({
    required this.id,
    required this.date,
    required this.sunsetTime,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.isActive,
  });

  /// Create a copy with updated values
  SunsetAlarm copyWith({
    String? id,
    DateTime? date,
    DateTime? sunsetTime,
    double? latitude,
    double? longitude,
    String? locationName,
    bool? isActive,
  }) {
    return SunsetAlarm(
      id: id ?? this.id,
      date: date ?? this.date,
      sunsetTime: sunsetTime ?? this.sunsetTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'sunsetTime': sunsetTime.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'isActive': isActive,
    };
  }

  /// Create from Map
  factory SunsetAlarm.fromMap(Map<String, dynamic> map) {
    return SunsetAlarm(
      id: map['id'],
      date: DateTime.parse(map['date']),
      sunsetTime: DateTime.parse(map['sunsetTime']),
      latitude: map['latitude'],
      longitude: map['longitude'],
      locationName: map['locationName'],
      isActive: map['isActive'],
    );
  }

  @override
  String toString() {
    return 'SunsetAlarm(id: $id, date: $date, sunsetTime: $sunsetTime, location: $locationName, isActive: $isActive)';
  }
}

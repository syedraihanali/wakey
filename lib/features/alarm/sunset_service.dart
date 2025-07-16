import 'dart:math' as math;

class SunsetService {
  /// Calculate sunset time for a given date and location
  static DateTime calculateSunsetTime({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) {
    // Use simplified sunset calculation algorithm
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    
    // Calculate solar declination
    final declination = 23.45 * math.sin(_degToRad(360 * (284 + dayOfYear) / 365));
    
    // Calculate hour angle
    final hourAngle = math.acos(-math.tan(_degToRad(latitude)) * math.tan(_degToRad(declination)));
    
    // Calculate sunset time (in hours from noon)
    final sunsetHour = 12 + (_radToDeg(hourAngle) / 15);
    
    // Convert to DateTime
    final hour = sunsetHour.floor();
    final minute = ((sunsetHour - hour) * 60).round();
    
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
  
  /// Convert degrees to radians
  static double _degToRad(double degrees) {
    return degrees * math.pi / 180;
  }
  
  /// Convert radians to degrees
  static double _radToDeg(double radians) {
    return radians * 180 / math.pi;
  }
  
  /// Validate if the selected date is in the future
  static bool isDateInFuture(DateTime selectedDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    return selected.isAfter(today) || selected.isAtSameMomentAs(today);
  }
  
  /// Get sunset time as formatted string
  static String formatSunsetTime(DateTime sunsetTime) {
    int hour = sunsetTime.hour;
    int minute = sunsetTime.minute;
    String period = hour >= 12 ? 'PM' : 'AM';
    
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    
    return '${hour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }
  
  /// Format date for display
  static String formatDate(DateTime dateTime) {
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

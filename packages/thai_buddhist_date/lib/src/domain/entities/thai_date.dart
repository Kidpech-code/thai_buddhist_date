import '../value_objects/era.dart';

/// Core entity representing a Thai Buddhist date
/// Immutable and contains business logic for era conversion
class ThaiDate {
  const ThaiDate({
    required this.year,
    required this.month,
    required this.day,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
    this.millisecond = 0,
    this.microsecond = 0,
    this.era = Era.be,
  })  : assert(month >= 1 && month <= 12),
        assert(day >= 1 && day <= 31),
        assert(hour >= 0 && hour <= 23),
        assert(minute >= 0 && minute <= 59),
        assert(second >= 0 && second <= 59),
        assert(millisecond >= 0 && millisecond <= 999),
        assert(microsecond >= 0 && microsecond <= 999);

  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int second;
  final int millisecond;
  final int microsecond;
  final Era era;

  /// Create from DateTime in CE era
  factory ThaiDate.fromDateTime(DateTime dateTime, {Era era = Era.be}) {
    return ThaiDate(
      year: era.fromCE(dateTime.year),
      month: dateTime.month,
      day: dateTime.day,
      hour: dateTime.hour,
      minute: dateTime.minute,
      second: dateTime.second,
      millisecond: dateTime.millisecond,
      microsecond: dateTime.microsecond,
      era: era,
    );
  }

  /// Create current date/time
  factory ThaiDate.now({Era era = Era.be}) {
    return ThaiDate.fromDateTime(DateTime.now(), era: era);
  }

  /// Convert to DateTime (always in CE)
  DateTime toDateTime() {
    return DateTime(
      era.toCE(year),
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  /// Convert to different era
  ThaiDate toEra(Era targetEra) {
    if (era == targetEra) return this;

    final ceYear = era.toCE(year);
    final targetYear = targetEra.fromCE(ceYear);

    return copyWith(year: targetYear, era: targetEra);
  }

  /// Create copy with modified properties
  ThaiDate copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
    Era? era,
  }) {
    return ThaiDate(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      millisecond: millisecond ?? this.millisecond,
      microsecond: microsecond ?? this.microsecond,
      era: era ?? this.era,
    );
  }

  /// Check if date is valid
  bool get isValid {
    try {
      toDateTime();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get year in CE
  int get ceYear => era.toCE(year);

  /// Get year in BE
  int get beYear => Era.be.fromCE(era.toCE(year));

  /// Date only comparison
  bool isSameDate(ThaiDate other) {
    return ceYear == other.ceYear && month == other.month && day == other.day;
  }

  /// Add days
  ThaiDate addDays(int days) {
    final dateTime = toDateTime().add(Duration(days: days));
    return ThaiDate.fromDateTime(dateTime, era: era);
  }

  /// Subtract days
  ThaiDate subtractDays(int days) => addDays(-days);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThaiDate &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month &&
          day == other.day &&
          hour == other.hour &&
          minute == other.minute &&
          second == other.second &&
          millisecond == other.millisecond &&
          microsecond == other.microsecond &&
          era == other.era;

  @override
  int get hashCode => Object.hash(
        year,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
        era,
      );

  @override
  String toString() =>
      'ThaiDate($year-$month-$day $hour:$minute:$second.$millisecond $era)';
}

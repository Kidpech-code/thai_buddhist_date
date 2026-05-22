import '../value_objects/era.dart';

/// Immutable entity representing a Thai Buddhist (or Common Era) date.
///
/// All field validation is enforced in both debug and release builds.
/// Use [ThaiDate.fromDateTime] or [ThaiDate.now] for convenient construction.
class ThaiDate implements Comparable<ThaiDate> {
  /// Creates a [ThaiDate].
  ///
  /// Field ranges are validated with `assert` (active in debug builds).
  /// For release-mode validation that throws [ArgumentError], use [ThaiDate.safe].
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
  })  : assert(month >= 1 && month <= 12, 'month must be in range 1–12'),
        assert(day >= 1 && day <= 31, 'day must be in range 1–31'),
        assert(hour >= 0 && hour <= 23, 'hour must be in range 0–23'),
        assert(minute >= 0 && minute <= 59, 'minute must be in range 0–59'),
        assert(second >= 0 && second <= 59, 'second must be in range 0–59'),
        assert(millisecond >= 0 && millisecond <= 999,
            'millisecond must be in range 0–999'),
        assert(microsecond >= 0 && microsecond <= 999,
            'microsecond must be in range 0–999');

  /// Creates a validated [ThaiDate] that throws [ArgumentError] in both
  /// debug **and** release builds.
  ///
  /// Prefer this factory when constructing dates from untrusted input.
  factory ThaiDate.safe({
    required int year,
    required int month,
    required int day,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
    Era era = Era.be,
  }) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'must be in range 1–12');
    }
    if (day < 1 || day > 31) {
      throw ArgumentError.value(day, 'day', 'must be in range 1–31');
    }
    if (hour < 0 || hour > 23) {
      throw ArgumentError.value(hour, 'hour', 'must be in range 0–23');
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(minute, 'minute', 'must be in range 0–59');
    }
    if (second < 0 || second > 59) {
      throw ArgumentError.value(second, 'second', 'must be in range 0–59');
    }
    if (millisecond < 0 || millisecond > 999) {
      throw ArgumentError.value(
          millisecond, 'millisecond', 'must be in range 0–999');
    }
    if (microsecond < 0 || microsecond > 999) {
      throw ArgumentError.value(
          microsecond, 'microsecond', 'must be in range 0–999');
    }
    return ThaiDate(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      millisecond: millisecond,
      microsecond: microsecond,
      era: era,
    );
  }

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

  /// Compares this date to [other] chronologically.
  ///
  /// Returns a negative integer if this is before [other], zero if equal,
  /// or a positive integer if this is after [other].
  @override
  int compareTo(ThaiDate other) {
    final thisCE = ceYear;
    final otherCE = other.ceYear;
    if (thisCE != otherCE) return thisCE.compareTo(otherCE);
    if (month != other.month) return month.compareTo(other.month);
    if (day != other.day) return day.compareTo(other.day);
    if (hour != other.hour) return hour.compareTo(other.hour);
    if (minute != other.minute) return minute.compareTo(other.minute);
    if (second != other.second) return second.compareTo(other.second);
    if (millisecond != other.millisecond) {
      return millisecond.compareTo(other.millisecond);
    }
    return microsecond.compareTo(other.microsecond);
  }

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
